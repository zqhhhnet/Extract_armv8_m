// Copyright (c) 2016-2018 Runtime Verification, Inc. (RV-Match team). All Rights Reserved.
package org.kframework.backend.ocaml;

import org.kframework.compile.ConfigurationInfo;
import org.kframework.compile.ConfigurationInfoFromModule;
import org.kframework.compile.ConvertDataStructureToLookup;
import org.kframework.compile.LabelInfo;
import org.kframework.compile.LabelInfoFromModule;
import org.kframework.definition.Module;
import org.kframework.definition.Rule;
import org.kframework.definition.Sentence;
import org.kframework.kore.Assoc;
import org.kframework.kore.FoldK;
import org.kframework.kore.K;
import org.kframework.kore.KApply;
import org.kframework.kore.KLabel;
import org.kframework.kore.KRewrite;
import org.kframework.kore.KVariable;
import org.kframework.kore.TransformK;
import org.kframework.compile.RewriteAwareTransformer;
import org.kframework.compile.RewriteToTop;
import org.kframework.utils.errorsystem.KEMException;
import scala.Tuple3;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.kframework.definition.Constructors.*;
import static org.kframework.kore.KORE.*;

/**
 * Created by dwightguth on 2/25/16.
 */
public class SplitThreadsCell {

    public SplitThreadsCell(Module m) {
        collectionFor = ConvertDataStructureToLookup.collectionFor(m);
        this.m = m;
        this.info = new LabelInfoFromModule(m);
        this.configInfo = new ConfigurationInfoFromModule(m);
    }

    private final Module m;
    private final Map<KLabel, KLabel> collectionFor;
    private final LabelInfo info;
    private final ConfigurationInfo configInfo;

    public Sentence convert(Sentence s) {
        if (s instanceof Rule) {
            return convert((Rule) s);
        } else {
            return s;
        }
    }

    private Rule convert(Rule rule) {
        if(rule.body() instanceof KRewrite) {
            KRewrite rew = (KRewrite)rule.body();
            if(rew.left() instanceof KApply) {
                KApply kapp = (KApply)rew.left();
                if (m.attributesFor().apply(kapp.klabel()).contains("noThread")) {
                    // we don't want to split this rule.
                    return rule;
                }
            }
        }
        K newBody = new RewriteAwareTransformer(true) {
            @Override
            public K apply(KApply k) {
                if (k.klabel().equals(configInfo.getCellLabel(configInfo.getRootCell()))) {
                    if (isLHS() && isRHS()) {
                        K lhs = RewriteToTop.toLeft(k);
                        K rhs = RewriteToTop.toRight(k);
                        Optional<KApply> threadsCellLeft = getThreadsCell(lhs);
                        Optional<KApply> threadsCellRight = getThreadsCell(rhs);
                        if (threadsCellLeft.isPresent() && threadsCellRight.isPresent()) {
                            Tuple3<K, K, K> splitLeft = splitSide(threadsCellLeft.get());
                            Tuple3<K, K, K> splitRight = splitSide(threadsCellRight.get());
                            K global = replaceThreadLocal(k);
                            return KApply(KLabel("#Thread"), global,
                                    KRewrite(splitLeft._1(), splitRight._1()),
                                    KRewrite(splitLeft._2(), splitRight._2()),
                                    KRewrite(splitLeft._3(), splitRight._3()));
                        } else if (threadsCellLeft.isPresent() || threadsCellRight.isPresent()) {
                            throw KEMException.compilerError("Failed to split thread cell: not found on both left hand side and right hand side.", k);
                        } else {
                            // these should be variable names not used anywhere else in the rule since only anonymous variables
                            // can begin with _ in a user rule and only _0, _1, _2, etc are generated by ResolveAnonVar
                            return KApply(KLabel("#Thread"), k, KVariable("_A"), KVariable("_B"), KVariable("_C"));
                        }
                    } else if (isLHS()) {
                        Optional<KApply> threadsCell = getThreadsCell(k);
                        if (threadsCell.isPresent()) {
                            Tuple3<K, K, K> split = splitSide(threadsCell.get());
                            K global = replaceThreadLocal(k);
                            return KApply(KLabel("#Thread"), global,
                                    split._1(),
                                    split._2(),
                                    split._3());
                        }else {
                            // these should be variable names not used anywhere else in the rule since only anonymous variables
                            // can begin with _ in a user rule and only _0, _1, _2, etc are generated by ResolveAnonVar
                            return KApply(KLabel("#Thread"), k, KVariable("_A"), KVariable("_B"), KVariable("_C"));
                        }
                    } else {
                        Optional<KApply> threadsCell = getThreadsCell(k);
                        if (threadsCell.isPresent()) {
                            Tuple3<K, K, K> split = splitSide(threadsCell.get());
                            K global = replaceThreadLocal(k);
                            return KApply(KLabel("#Thread"), global,
                                    split._1(),
                                    split._2(),
                                    split._3());
                        }else {
                            // these should be variable names not used anywhere else in the rule since only anonymous variables
                            // can begin with _ in a user rule and only _0, _1, _2, etc are generated by ResolveAnonVar
                            return KApply(KLabel("#Thread"), k, KVariable("_A"), KVariable("_B"), KVariable("_C"));
                        }
                    }
                } else {
                    return super.apply(k);
                }
            }
        }.apply(rule.body());
        return Rule(newBody, rule.requires(), rule.ensures(), rule.att());
    }

    /**
     *
     * @param threadsCell
     * @return A tuple containing: (1) the current thread id, (2) the current thread to match on, and (3) a list of other threads to match on
     */
    private Tuple3<K, K, K> splitSide(KApply threadsCell) {
        K threadsCellSet = threadsCell.items().get(0);
        if (threadsCellSet instanceof KApply) {
            KLabel collectionLabel = collectionFor.get(((KApply)threadsCellSet).klabel());
            KLabel unitLabel = KLabel(m.attributesFor().get(collectionLabel).get().get("unit"));
            List<K> threads = Assoc.flatten(collectionLabel, Collections.singletonList(threadsCellSet), unitLabel);
            K firstConcreteThread = null;
            List<K> otherThreadComponents = new ArrayList<>();
            for (K thread : threads) {
                if (!(thread instanceof KVariable) && firstConcreteThread == null) {
                    firstConcreteThread = thread;
                } else {
                    otherThreadComponents.add(thread);
                }
            }
            if (firstConcreteThread == null) {
                return Tuple3.apply(KApply(KLabel("#Bottom")), KApply(KLabel("#Bottom")), threadsCellSet);
            } else {
                if (!(firstConcreteThread instanceof KApply)) {
                    throw KEMException.compilerError("Found something other than a thread inside the thread set.", firstConcreteThread);
                }
                KApply kapp = (KApply)firstConcreteThread;
                return Tuple3.apply(kapp.items().get(0), kapp, otherThreadComponents.stream().reduce((k1, k2) -> KApply(collectionLabel, k1, k2)).orElse(KApply(unitLabel)));
            }
        } else {
            return Tuple3.apply(KApply(KLabel("#Bottom")), KApply(KLabel("#Bottom")), threadsCellSet);
        }

    }

    /**
     * Takes a k term and replaces the contents of the threads cell with a ThreadLocal placeholder.
     * @param body
     * @return
     */
    private K replaceThreadLocal(K body) {
        return new TransformK() {
            @Override
            public K apply(KApply k) {
                if (m.attributesFor().apply(k.klabel()).contains("thread")) {
                    return KApply(k.klabel(), KApply(KLabel("#ThreadLocal")));
                }
                return super.apply(k);
            }
        }.apply(body);
    }

    /**
     * Takes a k term and returns the threads cell if it exists, otherwise Optional.empty()
     * @param lhs
     * @return
     */
    private Optional<KApply> getThreadsCell(K lhs) {
        return new FoldK<Optional<KApply>>() {
            @Override
            public Optional<KApply> apply(KApply k) {
                if (k.klabel() instanceof KVariable) {
                    return super.apply(k);
                }
                if (m.attributesFor().apply(k.klabel()).contains("thread")) {
                    return Optional.of(k);
                }
                return super.apply(k);
            }

            @Override
            public Optional<KApply> unit() {
                return Optional.empty();
            }

            @Override
            public Optional<KApply> merge(Optional<KApply> a, Optional<KApply> b) {
                if (a.isPresent())
                    return a;
                if (b.isPresent())
                    return b;
                return Optional.empty();
            }
        }.apply(lhs);
    }
}