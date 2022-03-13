// Copyright (c) 2015-2019 K Team. All Rights Reserved.
package org.kframework.kompile;

import com.google.common.collect.Lists;
import com.google.common.collect.Sets;
import org.apache.commons.collections15.ListUtils;
import org.kframework.Collections;
import org.kframework.attributes.Location;
import org.kframework.attributes.Source;
import org.kframework.builtin.BooleanUtils;
import org.kframework.definition.Bubble;
import org.kframework.definition.Context;
import org.kframework.definition.ContextAlias;
import org.kframework.definition.Definition;
import org.kframework.definition.DefinitionTransformer;
import org.kframework.definition.Module;
import org.kframework.definition.Rule;
import org.kframework.definition.Sentence;
import org.kframework.kore.K;
import org.kframework.kore.KApply;
import org.kframework.kore.Sort;
import org.kframework.parser.TreeNodesToKORE;
import org.kframework.parser.concrete2kore.ParseCache;
import org.kframework.parser.concrete2kore.ParseCache.ParsedSentence;
import org.kframework.parser.concrete2kore.ParseInModule;
import org.kframework.parser.concrete2kore.ParserUtils;
import org.kframework.parser.concrete2kore.generator.RuleGrammarGenerator;
import org.kframework.parser.concrete2kore.kernel.Scanner;
import org.kframework.parser.outer.Outer;
import org.kframework.utils.BinaryLoader;
import org.kframework.utils.StringUtil;
import org.kframework.utils.errorsystem.KEMException;
import org.kframework.utils.errorsystem.KExceptionManager;
import org.kframework.utils.errorsystem.ParseFailedException;
import org.kframework.utils.errorsystem.KException.ExceptionType;
import org.kframework.utils.file.FileUtil;
import scala.Option;
import scala.Tuple2;
import scala.collection.Set;
import scala.util.Either;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ForkJoinPool;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static org.kframework.Collections.*;
import static org.kframework.definition.Constructors.*;
import static org.kframework.kore.KORE.*;

/**
 * A bundle of code doing various aspects of definition parsing.
 * TODO: In major need of refactoring.
 * @cos refactored this code out of Kompile but none (or close to none) of it was originally written by him.
 */
public class DefinitionParsing {
    public static final Sort START_SYMBOL = Sort("#RuleContent");
    private final File cacheFile;
    private boolean autoImportDomains;
    private boolean kore;

    private final KExceptionManager kem;
    private final FileUtil files;
    private final ParserUtils parser;
    private final boolean cacheParses;
    private final BinaryLoader loader;

    public final AtomicInteger parsedBubbles = new AtomicInteger(0);
    public final AtomicInteger cachedBubbles = new AtomicInteger(0);
    private final boolean isStrict;
    private final boolean profileRules;
    private final List<File> lookupDirectories;

    public DefinitionParsing(
            List<File> lookupDirectories,
            boolean isStrict,
            boolean profileRules,
            KExceptionManager kem,
            FileUtil files,
            ParserUtils parser,
            boolean cacheParses,
            File cacheFile,
            boolean autoImportDomains,
            boolean kore) {
        this.lookupDirectories = lookupDirectories;
        this.kem = kem;
        this.files = files;
        this.parser = parser;
        this.cacheParses = cacheParses;
        this.cacheFile = cacheFile;
        this.autoImportDomains = autoImportDomains;
        this.kore = kore;
        this.loader = new BinaryLoader(this.kem);
        this.isStrict = isStrict;
        this.profileRules = profileRules;
    }

    public java.util.Set<Module> parseModules(CompiledDefinition definition, String mainModule, File definitionFile) {
        Definition def = parser.loadDefinition(
                mainModule,
                mutable(definition.getParsedDefinition().modules()),
                "require " + StringUtil.enquoteCString(definitionFile.getPath()),
                Source.apply(definitionFile.getAbsolutePath()),
                definitionFile.getParentFile(),
                ListUtils.union(lookupDirectories,
                        Lists.newArrayList(Kompile.BUILTIN_DIRECTORY)),
                kore);

        errors = java.util.Collections.synchronizedSet(Sets.newHashSet());
        caches = new HashMap<>();

        if (cacheParses) {
            try {
                caches = loader.load(Map.class, cacheFile);
            } catch (FileNotFoundException e) {
            } catch (IOException | ClassNotFoundException e) {
                kem.registerInternalHiddenWarning("Invalidating serialized cache due to corruption.", e);
            }
        }

        //modified by hhh
        //System.out.println("HHHHHHHHHHH\n");

        Module modWithConfig;
        ResolveConfig resolveConfig = new ResolveConfig(definition.getParsedDefinition(), isStrict, kore, this::parseBubble, this::getParser);
        gen = new RuleGrammarGenerator(definition.getParsedDefinition());

        //modified by hhh
        //System.out.println("IIIIIIIIIII\n");

        try {
            def = DefinitionTransformer.from(resolveConfig::apply, "parse config bubbles").apply(def);
        } catch (KEMException e) {
            errors.add(e);
            throwExceptionIfThereAreErrors();
            throw new AssertionError("should not reach this statement");
        }

        //modified by hhh
        //System.out.println("JJJJJJJJJJJJ\n");

        def = resolveNonConfigBubbles(def, gen);

        //modified by hhh
        //System.out.println("KKKKKKKKKKKK\n");

        saveCachesAndReportParsingErrors();
        return mutable(def.entryModules());
    }

    private void saveCachesAndReportParsingErrors() {
        saveCaches();
        throwExceptionIfThereAreErrors();
    }

    private void saveCaches() {
        if (cacheParses) {
            loader.saveOrDie(cacheFile, caches);
        }
    }

    public Definition parseDefinitionAndResolveBubbles(File definitionFile, String mainModuleName, String mainProgramsModule, java.util.Set<String> excludedModuleTags) {
        Definition parsedDefinition = parseDefinition(definitionFile, mainModuleName, mainProgramsModule);
        Stream<Module> modules = Stream.of(parsedDefinition.mainModule());
        modules = Stream.concat(modules, stream(parsedDefinition.mainModule().importedModules()));
        Option<Module> syntaxModule = parsedDefinition.getModule(mainProgramsModule);
        if (syntaxModule.isDefined()) {
            modules = Stream.concat(modules, Stream.of(syntaxModule.get()));
            modules = Stream.concat(modules, stream(syntaxModule.get().importedModules()));
        }
        modules = Stream.concat(modules, Stream.of(parsedDefinition.getModule("K-REFLECTION").get()));
        modules = Stream.concat(modules, Stream.of(parsedDefinition.getModule("STDIN-STREAM").get()));
        modules = Stream.concat(modules, Stream.of(parsedDefinition.getModule("STDOUT-STREAM").get()));
        modules = Stream.concat(modules,
                stream(parsedDefinition.entryModules()).filter(m -> !stream(m.sentences()).anyMatch(s -> s instanceof Bubble)));
        Definition trimmed = Definition(parsedDefinition.mainModule(), modules.collect(Collections.toSet()),
                parsedDefinition.att());
        trimmed = Kompile.excludeModulesByTag(excludedModuleTags).apply(trimmed);
        Definition afterResolvingConfigBubbles = resolveConfigBubbles(trimmed, parsedDefinition.getModule("DEFAULT-CONFIGURATION").get());
        RuleGrammarGenerator gen = new RuleGrammarGenerator(afterResolvingConfigBubbles);
        Definition afterResolvingAllOtherBubbles = resolveNonConfigBubbles(afterResolvingConfigBubbles, gen);
        saveCachesAndReportParsingErrors();
        return afterResolvingAllOtherBubbles;
    }

    private void throwExceptionIfThereAreErrors() {
        if (!errors.isEmpty()) {
            kem.addAllKException(errors.stream().map(e -> e.exception).collect(Collectors.toList()));
            throw KEMException.compilerError("Had " + errors.size() + " parsing errors.");
        }
    }

    public Definition parseDefinition(File definitionFile, String mainModuleName, String mainProgramsModule) {
        Definition definition = parser.loadDefinition(
                mainModuleName,
                mainProgramsModule, FileUtil.load(definitionFile),
                definitionFile,
                definitionFile.getParentFile(),
                ListUtils.union(lookupDirectories,
                        Lists.newArrayList(Kompile.BUILTIN_DIRECTORY)),
                autoImportDomains,
                kore);
        return definition;
    }

    protected Definition resolveConfigBubbles(Definition definition, Module defaultConfiguration) {
        boolean hasConfigDecl = stream(definition.mainModule().sentences())
                .filter(s -> s instanceof Bubble)
                .map(b -> (Bubble) b)
                .filter(b -> b.sentenceType().equals("config"))
                .findFirst().isPresent();

        Definition definitionWithConfigBubble;
        if (!hasConfigDecl) {
            definitionWithConfigBubble = DefinitionTransformer.from(mod -> {
                if (mod == definition.mainModule()) {
                    java.util.Set<Module> imports = mutable(mod.imports());
                    imports.add(defaultConfiguration);
                    return Module(mod.name(), (Set<Module>) immutable(imports), mod.localSentences(), mod.att());
                }
                return mod;
            }, "adding default configuration").apply(definition);
        } else {
            definitionWithConfigBubble = definition;
        }

        errors = java.util.Collections.synchronizedSet(Sets.newHashSet());
        caches = new HashMap<>();

        if (cacheParses) {
            try {
                caches = loader.load(Map.class, cacheFile);
            } catch (FileNotFoundException e) {
            } catch (IOException | ClassNotFoundException e) {
                kem.registerInternalHiddenWarning("Invalidating serialized cache due to corruption.", e);
            }
        }

        ResolveConfig resolveConfig = new ResolveConfig(definitionWithConfigBubble, isStrict, kore, this::parseBubble, this::getParser);
        gen = new RuleGrammarGenerator(definitionWithConfigBubble);

        try {
            Definition defWithConfig = DefinitionTransformer.from(resolveConfig::apply, "parsing configurations").apply(definitionWithConfigBubble);
            return defWithConfig;
        } catch (KEMException e) {
            errors.add(e);
            throwExceptionIfThereAreErrors();
            throw new AssertionError("should not reach this statement");
        }
    }

    Map<String, ParseCache> caches;
    private java.util.Set<KEMException> errors;
    RuleGrammarGenerator gen;

    public java.util.Set<KEMException> errors() {
        return errors;
    }

    public Definition resolveNonConfigBubbles(Definition defWithConfig, RuleGrammarGenerator gen) {
        Module ruleParserModule = gen.getRuleGrammar(defWithConfig.mainModule());
        //modified by hhh
        //System.out.println("HHHHHHHHHHHH\n");
        ParseCache cache = loadCache(ruleParserModule);
        //modified by hhh
        //System.out.println("IIIIIIIIIIIII\n");
        try (ParseInModule parser = RuleGrammarGenerator.getCombinedGrammar(cache.getModule(), isStrict, profileRules, files)) {
            //modified by hhh
            //System.out.println("55555555555555\n");
            return DefinitionTransformer.from(m -> this.resolveNonConfigBubbles(m, parser.getScanner(), gen), "parsing rules").apply(defWithConfig);
        }
    }

    private Module resolveNonConfigBubbles(Module module, Scanner scanner, RuleGrammarGenerator gen) {
        if (stream(module.localSentences())
                .filter(s -> s instanceof Bubble)
                .map(b -> (Bubble) b)
                .filter(b -> !b.sentenceType().equals("config")).count() == 0)
            return module;

        Module ruleParserModule = gen.getRuleGrammar(module);

        ParseCache cache = loadCache(ruleParserModule);
        try (ParseInModule parser = RuleGrammarGenerator.getCombinedGrammar(cache.getModule(), isStrict, profileRules, files)) {
            if (stream(module.localSentences()).filter(s -> s instanceof Bubble).findAny().isPresent()) {
                parser.initialize();
            }

            // this scanner is not good for this module, so we must generate a new scanner.
            boolean needNewScanner = !scanner.getModule().importedModuleNames().contains(module.name());
            final Scanner realScanner = needNewScanner ? parser.getScanner() : scanner;

            //modified by hhh
            //System.out.println("666666666666\n");
            
            Set<Sentence> ruleSet = stream(module.localSentences())
                    .parallel()
                    .filter(s -> s instanceof Bubble)
                    .map(b -> (Bubble) b)
                    .filter(b -> b.sentenceType().equals("rule"))
                    .flatMap(b -> performParse(cache.getCache(), parser, realScanner, b))
                    .map(this::upRule)
                .collect(Collections.toSet());

            //modified by hhh
            //System.out.println("77777777777\n");

            Set<Sentence> contextSet = stream(module.localSentences())
                    .parallel()
                    .filter(s -> s instanceof Bubble)
                    .map(b -> (Bubble) b)
                    .filter(b -> b.sentenceType().equals("context"))
                    .flatMap(b -> performParse(cache.getCache(), parser, realScanner, b))
                    .map(this::upContext)
                .collect(Collections.toSet());

            //modified by hhh
            //System.out.println("88888888888\n");

            Set<Sentence> aliasSet = stream(module.localSentences())
                    .parallel()
                    .filter(s -> s instanceof Bubble)
                    .map(b -> (Bubble) b)
                    .filter(b -> b.sentenceType().equals("alias"))
                    .flatMap(b -> performParse(cache.getCache(), parser, realScanner, b))
                    .map(this::upAlias)
                .collect(Collections.toSet());

            if (needNewScanner) {
                realScanner.close();//required for Windows.
            }

            //modified by hhh
            //System.out.println("999999999999\n");

            return Module(module.name(), module.imports(),
                    stream((Set<Sentence>) module.localSentences().$bar(ruleSet).$bar(contextSet).$bar(aliasSet)).filter(b -> !(b instanceof Bubble)).collect(Collections.toSet()), module.att());
        }
    }

    public Rule parseRule(CompiledDefinition compiledDef, String contents, Source source) {
        errors = java.util.Collections.synchronizedSet(Sets.newHashSet());
        gen = new RuleGrammarGenerator(compiledDef.kompiledDefinition);
        try (ParseInModule parser = RuleGrammarGenerator
                .getCombinedGrammar(gen.getRuleGrammar(compiledDef.executionModule()), isStrict, profileRules, files)) {
            java.util.Set<K> res = performParse(new HashMap<>(), parser, parser.getScanner(),
                    new Bubble("rule", contents, Att().add("contentStartLine", Integer.class, 1)
                            .add("contentStartColumn", Integer.class, 1).add(Source.class, source)))
                    .collect(Collectors.toSet());
            if (!errors.isEmpty()) {
                throw errors.iterator().next();
            }
            return upRule(res.iterator().next());
        }
    }

    private Rule upRule(K contents) {
        KApply ruleContents = (KApply) contents;
        List<org.kframework.kore.K> items = ruleContents.klist().items();
        switch (ruleContents.klabel().name()) {
        case "#ruleNoConditions":
            return Rule(items.get(0), BooleanUtils.TRUE, BooleanUtils.TRUE, ruleContents.att());
        case "#ruleRequires":
            return Rule(items.get(0), items.get(1), BooleanUtils.TRUE, ruleContents.att());
        case "#ruleEnsures":
            return Rule(items.get(0), BooleanUtils.TRUE, items.get(1), ruleContents.att());
        case "#ruleRequiresEnsures":
            return Rule(items.get(0), items.get(1), items.get(2), ruleContents.att());
        default:
            throw new AssertionError("Wrong KLabel for rule content");
        }
    }

    private Context upContext(K contents) {
        KApply ruleContents = (KApply) contents;
        List<K> items = ruleContents.klist().items();
        switch (ruleContents.klabel().name()) {
        case "#ruleNoConditions":
            return Context(items.get(0), BooleanUtils.TRUE, ruleContents.att());
        case "#ruleRequires":
            return Context(items.get(0), items.get(1), ruleContents.att());
        default:
            throw KEMException.criticalError("Illegal context with ensures clause detected.", contents);
        }
    }

    private ContextAlias upAlias(K contents) {
        KApply ruleContents = (KApply) contents;
        List<K> items = ruleContents.klist().items();
        switch (ruleContents.klabel().name()) {
        case "#ruleNoConditions":
            return ContextAlias(items.get(0), BooleanUtils.TRUE, ruleContents.att());
        case "#ruleRequires":
            return ContextAlias(items.get(0), items.get(1), ruleContents.att());
        default:
            throw KEMException.criticalError("Illegal context alias with ensures clause detected.", contents);
        }
    }

    private ParseCache loadCache(Module parser) {
        ParseCache cachedParser = caches.get(parser.name());
        if (cachedParser == null || !equalsSyntax(cachedParser.getModule(), parser) || cachedParser.isStrict() != isStrict) {
            cachedParser = new ParseCache(parser, isStrict, java.util.Collections.synchronizedMap(new HashMap<>()));
            caches.put(parser.name(), cachedParser);
        }
        return cachedParser;
    }

    private boolean equalsSyntax(Module _this, Module that) {
        if (!_this.productions().equals(that.productions())) return false;
        if (!_this.priorities().equals(that.priorities())) return false;
        if (!_this.leftAssoc().equals(that.leftAssoc())) return false;
        if (!_this.rightAssoc().equals(that.rightAssoc())) return false;
        return _this.sortDeclarations().equals(that.sortDeclarations());
    }

    private Stream<? extends K> parseBubble(Module module, Bubble b) {
        ParseCache cache = loadCache(gen.getConfigGrammar(module));
        try (ParseInModule parser = RuleGrammarGenerator.getCombinedGrammar(cache.getModule(), isStrict, profileRules, files)) {
            return performParse(cache.getCache(), parser, parser.getScanner(), b);
        }
    }

    private ParseInModule getParser(Module module) {
        ParseCache cache = loadCache(gen.getConfigGrammar(module));
        return RuleGrammarGenerator.getCombinedGrammar(cache.getModule(), isStrict);
    }

    private Stream<? extends K> performParse(Map<String, ParsedSentence> cache, ParseInModule parser, Scanner scanner, Bubble b) {
        int startLine = b.att().get("contentStartLine", Integer.class);
        int startColumn = b.att().get("contentStartColumn", Integer.class);
        Source source = b.att().get(Source.class);
        Tuple2<Either<java.util.Set<ParseFailedException>, K>, java.util.Set<ParseFailedException>> result;
        
        //modified by hhh
        //System.out.println("1111110000000\n");

        if (cache.containsKey(b.contents())) {
            ParsedSentence parse = cache.get(b.contents());
            Optional<Source> cacheSource = parse.getParse().source();
            //Cache might contain content from an identical file but another source path.
            //The content will have wrong Source attribute and must be invalidated.
            if (cacheSource.isPresent() && cacheSource.get().equals(source)) {
                cachedBubbles.getAndIncrement();
                kem.addAllKException(parse.getWarnings().stream().map(e -> e.getKException()).collect(Collectors.toList()));
                return Stream.of(parse.getParse());
            }
        }
        //modified by hhh
        //System.out.println("11111122222222\n");
        result = parser.parseString(b.contents(), START_SYMBOL, scanner, source, startLine, startColumn, true, b.att().contains("anywhere"));
        //modified by hhh
        //System.out.println("11111133333333\n");
        parsedBubbles.getAndIncrement();
        if (kem.options.warnings2errors && !result._2().isEmpty()) {
          for (KEMException err : result._2()) {
            if (kem.options.warnings.includesExceptionType(err.exception.getType())) {
              errors.add(KEMException.asError(err));
            }
          }
        } else {
          kem.addAllKException(result._2().stream().map(e -> e.getKException()).collect(Collectors.toList()));
        }
        //modified by hhh
        //System.out.println("1111144444444\n");
        if (result._1().isRight()) {
            KApply k = (KApply) new TreeNodesToKORE(Outer::parseSort, isStrict).down(result._1().right().get());
            k = KApply(k.klabel(), k.klist(), k.att().addAll(b.att().remove("contentStartLine").remove("contentStartColumn").remove(Source.class).remove(Location.class)));
            cache.put(b.contents(), new ParsedSentence(k, new HashSet<>(result._2())));
            //modified by hhh
            //System.out.println("11111115555555\n");
            return Stream.of(k);
        } else {
            errors.addAll(result._1().left().get());
            //modified by hhh
            //System.out.println("111111116666666\n");
            return Stream.empty();
        }

    }
}
