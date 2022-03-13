// Copyright (c) 2015-2019 K Team. All Rights Reserved.
package org.kframework.parser.concrete2kore;

import com.google.common.collect.Sets;
import org.kframework.attributes.Source;
import org.kframework.definition.Module;
import org.kframework.kore.K;
import org.kframework.kore.Sort;
import org.kframework.parser.Term;
import org.kframework.parser.TreeNodesToKORE;
import org.kframework.parser.concrete2kore.disambiguation.*;
import org.kframework.parser.concrete2kore.kernel.Grammar;
import org.kframework.parser.concrete2kore.kernel.KSyntax2GrammarStatesFilter;
import org.kframework.parser.concrete2kore.kernel.Parser;
import org.kframework.parser.concrete2kore.kernel.Scanner;
import org.kframework.parser.outer.Outer;
import org.kframework.utils.errorsystem.KException;
import org.kframework.utils.errorsystem.KEMException;
import org.kframework.utils.errorsystem.ParseFailedException;
import org.kframework.utils.file.FileUtil;
import scala.Tuple2;
import scala.util.Either;
import scala.util.Left;
import scala.util.Right;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Serializable;
import java.io.Writer;
import java.util.Collections;
import java.util.Set;

/**
 * A wrapper that takes a module and one can call the parser
 * for that module in thread safe way.
 * Declarative disambiguation filters are also applied.
 */
public class ParseInModule implements Serializable, AutoCloseable {
    private final Module seedModule;
    private final Module extensionModule;
    /**
     * The module in which parsing will be done.
     * Note that this module will be used for disambiguation, and the parsing module can be different.
     * This allows for grammar rewriting and more flexibility in the implementation.
     */
    private final Module disambModule;
    /**
     * The exact module used for parsing. This can contain productions and sorts that are not
     * necessarily representable in KORE (sorts like Ne#Ids, to avoid name collisions).
     * In this case the modified production will be annotated with the information from the
     * original production, so disambiguation can be done safely.
     */
    private final Module parsingModule;
    private volatile Grammar grammar = null;
    private final boolean strict;
    private final boolean profileRules;
    private final FileUtil files;
    public ParseInModule(Module seedModule) {
        this(seedModule, seedModule, seedModule, seedModule, true, false, null);
    }

    public ParseInModule(Module seedModule, Module extensionModule, Module disambModule, Module parsingModule, boolean strict, boolean profileRules, FileUtil files) {
        this.seedModule = seedModule;
        this.extensionModule = extensionModule;
        this.disambModule = disambModule;
        this.parsingModule = parsingModule;
        this.strict = strict;
        this.profileRules = profileRules;
        this.files = files;
        if (profileRules) {
            try {
                timing = new BufferedWriter(new FileWriter(files.resolveKompiled("timing" + Thread.currentThread().getId() + ".log"), true));
            } catch (IOException e) {
                throw KEMException.internalError("Failed to open timing.log", e);
            }
        }
    }

    /**
     * The original module, which includes all the marker/flags imports.
     * This can be used to invalidate caches.
     * @return Module given by the user.
     */
    public Module seedModule() {
        return seedModule;
    }

    /**
     * An extension module of the seedModule which includes all productions, unmodified, and in addition,
     * contains extra productions auto-defined, like casts.
     * @return Module with extra productions defined during parser generator.
     */
    public Module getExtensionModule() {
        return extensionModule;
    }

    public Module getParsingModule() { return parsingModule; }

    public void initialize() {
       disambModule.definedSorts();
       disambModule.subsorts();
       disambModule.priorities();
       disambModule.leftAssoc();
       disambModule.rightAssoc();
       disambModule.productionsFor();
       disambModule.overloads();
    }

    /**
     * Parse as input the given string and start symbol using the module stored in the object.
     * @param input          the string to parse.
     * @param startSymbol    the start symbol from which to parse.
     * @return the Term representation of the parsed input.
     */
    public Tuple2<Either<Set<ParseFailedException>, K>, Set<ParseFailedException>>
            parseString(String input, Sort startSymbol, Source source) {
        try (Scanner scanner = getScanner()) {
            return parseString(input, startSymbol, scanner, source, 1, 1, true, false);
        }
    }

    private Scanner getGrammar(Scanner scanner) {
        Grammar g = grammar;
        if (g == null) {
            g = KSyntax2GrammarStatesFilter.getGrammar(this.parsingModule, scanner);
            grammar = g;
        }
        return scanner;
    }

    private Scanner scanner;

    public Scanner getScanner() {
        if (scanner == null) {
            scanner = new Scanner(this);
        }
        return scanner;
    }

    public Tuple2<Either<Set<ParseFailedException>, K>, Set<ParseFailedException>>
        parseString(String input, Sort startSymbol, Scanner scanner, Source source, int startLine, int startColumn, boolean inferSortChecks, boolean isAnywhere) {
        //modified by hhh
        //System.out.println("11111177777777\n");
        final Tuple2<Either<Set<ParseFailedException>, Term>, Set<ParseFailedException>> result
                = parseStringTerm(input, startSymbol, scanner, source, startLine, startColumn, inferSortChecks, isAnywhere);
        //modified by hhh
        //System.out.println("11111188888888\n");
        Either<Set<ParseFailedException>, K> parseInfo;
        if (result._1().isLeft()) {
            parseInfo = Left.apply(result._1().left().get());
            //modified by hhh
            //System.out.println("1111199999999999\n");
        } else {
            parseInfo = Right.apply(new TreeNodesToKORE(Outer::parseSort, inferSortChecks && strict).apply(result._1().right().get()));
            //modified by hhh
            //System.out.println("22222220000000\n");
        }
        return new Tuple2<>(parseInfo, result._2());
    }

    private Writer timing;

    /**
     * Parse the given input. This function is private because the final disambiguation
     * in {@link AmbFilter} eliminates ambiguities that will be equivalent only after
     * calling {@link TreeNodesToKORE#apply(Term)}, but returns a result that is
     * somewhat arbitrary as an actual parser {@link Term}.
     * Fortunately all callers want the result as a K, and can use the public
     * version of this method.
     * @param input
     * @param startSymbol
     * @param source
     * @param startLine
     * @param startColumn
     * @return
     */
    private Tuple2<Either<Set<ParseFailedException>, Term>, Set<ParseFailedException>>
            parseStringTerm(String input, Sort startSymbol, Scanner scanner, Source source, int startLine, int startColumn, boolean inferSortChecks, boolean isAnywhere) {
        scanner = getGrammar(scanner);
        //modified by hhh
        //System.out.println("22222221111111\n");

        long start = 0;
        if (profileRules) {
            start = System.nanoTime();
        }

        try {
            Grammar.NonTerminal startSymbolNT = grammar.get(startSymbol.toString());
            Set<ParseFailedException> warn = Sets.newHashSet();
            //modified by hhh
            //System.out.println("222222233333333\n");
            if (startSymbolNT == null) {
                String msg = "Could not find start symbol: " + startSymbol;
                KException kex = new KException(KException.ExceptionType.ERROR, KException.KExceptionGroup.CRITICAL, msg);
                return new Tuple2<>(Left.apply(Sets.newHashSet(new ParseFailedException(kex))), warn);
            }

            Term parsed;
            try {
                //modified by hhh
                //System.out.println("2222222444444444\n");
                Parser parser = new Parser(input, scanner, source, startLine, startColumn);
                parsed = parser.parse(startSymbolNT, 0);
            } catch (ParseFailedException e) {
                return Tuple2.apply(Left.apply(Collections.singleton(e)), Collections.emptySet());
            }

            //modified by hhh
            //System.out.println("2222222666666666\n");
            Either<Set<ParseFailedException>, Term> rez = new TreeCleanerVisitor().apply(parsed);
            if (rez.isLeft())
                return new Tuple2<>(rez, warn);
            rez = new CorrectRewritePriorityVisitor().apply(rez.right().get());
            if (rez.isLeft())
                return new Tuple2<>(rez, warn);
            rez = new CorrectKSeqPriorityVisitor().apply(rez.right().get());
            if (rez.isLeft())
                return new Tuple2<>(rez, warn);
            rez = new CorrectCastPriorityVisitor().apply(rez.right().get());
            if (rez.isLeft())
                return new Tuple2<>(rez, warn);
            rez = new PriorityVisitor(disambModule.priorities(), disambModule.leftAssoc(), disambModule.rightAssoc()).apply(rez.right().get());
            if (rez.isLeft())
                return new Tuple2<>(rez, warn);
            Term rez3 = new PushTopAmbiguityUp().apply(rez.right().get());
            rez = new ApplyTypeCheckVisitor(disambModule.subsorts(), isAnywhere).apply(rez3);
            if (rez.isLeft())
                return new Tuple2<>(rez, warn);
            Tuple2<Either<Set<ParseFailedException>, Term>, Set<ParseFailedException>> rez2 = new VariableTypeInferenceFilter(disambModule.subsorts(), disambModule.definedSorts(), disambModule.productionsFor(), strict && inferSortChecks, true, isAnywhere).apply(rez.right().get());
            if (rez2._1().isLeft())
                return rez2;
            warn = rez2._2();

            rez = new ResolveOverloadedTerminators(disambModule.overloads()).apply(rez2._1().right().get());
            if (rez.isLeft())
                return new Tuple2<>(rez, warn);
            rez3 = new PushAmbiguitiesDownAndPreferAvoid(disambModule.overloads()).apply(rez.right().get());
            rez2 = new AmbFilter(strict && inferSortChecks).apply(rez3);
            warn = Sets.union(rez2._2(), warn);
            rez2 = new AddEmptyLists(disambModule).apply(rez2._1().right().get());
            warn = Sets.union(rez2._2(), warn);
            if (rez2._1().isLeft())
                return rez2;
            rez3 = new RemoveBracketVisitor().apply(rez2._1().right().get());

            //modified by hhh
            //System.out.println("22222227777777777\n");

            return new Tuple2<>(Right.apply(rez3), warn);
        } finally {
            //modified by hhh
            //System.out.println("22222228888888888\n");
            if (profileRules) {
                long stop = System.nanoTime();
                try {
                    //modified by hhh
                    //System.out.println("22222229999999\n");
                    Writer t = timing;
                    synchronized(t) {
                        t.write(source.toString());
                        t.write(':');
                        t.write(Integer.toString(startLine));
                        t.write(':');
                        t.write(Integer.toString(startColumn));
                        t.write(' ');
                        t.write(Double.toString((stop - start) / 1000000000.0));
                        t.write('\n');
                    }
                } catch (IOException e) {
                    //modified by hhh
                    //System.out.println("22222221110000000\n");
                  throw KEMException.internalError("Could not write to timing.log", e);
                }
            }
        }
    }

    public void close() {
        if (scanner != null) {
            scanner.close();
        }
        Writer t = timing;
        if (t != null) {
            synchronized(t) {
                try {
                    t.close();
                } catch (IOException e) {
                    throw KEMException.internalError("Could not close timing.log", e);
                }
            }
        }
    }

    public static Term disambiguateForUnparse(Module mod, Term ambiguity) {
        Term rez3 = new PushTopAmbiguityUp().apply(ambiguity);
        Either<Set<ParseFailedException>, Term> rez = new ApplyTypeCheckVisitor(mod.subsorts(), false).apply(rez3);
        Tuple2<Either<Set<ParseFailedException>, Term>, Set<ParseFailedException>> rez2;
        if (rez.isLeft()) {
            rez2 = new AmbFilter(false).apply(rez3);
            return rez2._1().right().get();
        }
        rez2 = new VariableTypeInferenceFilter(mod.subsorts(), mod.definedSorts(), mod.productionsFor(), false, false, false).apply(rez.right().get());
        if (rez2._1().isLeft()) {
            rez2 = new AmbFilter(false).apply(rez.right().get());
            return rez2._1().right().get();
        }
        rez3 = new PushAmbiguitiesDownAndPreferAvoid(mod.overloads()).apply(rez2._1().right().get());
        rez2 = new AmbFilter(false).apply(rez3);
        return rez2._1().right().get();
    }
}
