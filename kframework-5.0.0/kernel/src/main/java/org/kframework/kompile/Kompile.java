// Copyright (c) 2015-2019 K Team. All Rights Reserved.
package org.kframework.kompile;

import com.google.inject.Inject;
import org.kframework.Strategy;
import org.kframework.attributes.Att;
import org.kframework.attributes.Source;
import org.kframework.backend.Backends;
import org.kframework.builtin.Sorts;
import org.kframework.compile.*;
import org.kframework.compile.checks.CheckConfigurationCells;
import org.kframework.compile.checks.CheckFunctions;
import org.kframework.compile.checks.CheckHOLE;
import org.kframework.compile.checks.CheckImports;
import org.kframework.compile.checks.CheckKLabels;
import org.kframework.compile.checks.CheckLabels;
import org.kframework.compile.checks.CheckRHSVariables;
import org.kframework.compile.checks.CheckRewrite;
import org.kframework.compile.checks.CheckSortTopUniqueness;
import org.kframework.compile.checks.CheckStreams;
import org.kframework.definition.*;
import org.kframework.definition.Module;
import org.kframework.kore.Sort;
import org.kframework.kore.KLabel;
import org.kframework.parser.concrete2kore.ParserUtils;
import org.kframework.parser.concrete2kore.generator.RuleGrammarGenerator;
import org.kframework.unparser.ToJson;
import org.kframework.utils.Stopwatch;
import org.kframework.utils.errorsystem.KEMException;
import org.kframework.utils.errorsystem.KExceptionManager;
import org.kframework.utils.file.FileUtil;
import org.kframework.utils.file.JarInfo;
import scala.Function1;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.util.Collections;
import java.util.EnumSet;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.function.UnaryOperator;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static org.kframework.Collections.*;
import static org.kframework.definition.Constructors.*;
import static org.kframework.kore.KORE.*;
import static org.kframework.compile.ResolveHeatCoolAttribute.Mode.*;

/**
 * The new compilation pipeline. Everything is just wired together and will need clean-up once we deside on design.
 * Tracked by #1442.
 */
public class Kompile {
    public static final File BUILTIN_DIRECTORY = JarInfo.getKIncludeDir().resolve("builtin").toFile();
    public static final String REQUIRE_PRELUDE_K = "requires \"prelude.k\"\n";

    public final KompileOptions kompileOptions;
    private final FileUtil files;
    private final KExceptionManager kem;
    private final ParserUtils parser;
    private final Stopwatch sw;
    private final DefinitionParsing definitionParsing;
    java.util.Set<KEMException> errors;

    public Kompile(KompileOptions kompileOptions, FileUtil files, KExceptionManager kem, boolean cacheParses) {
        this(kompileOptions, files, kem, new Stopwatch(kompileOptions.global), cacheParses);
    }

    public Kompile(KompileOptions kompileOptions, FileUtil files, KExceptionManager kem) {
        this(kompileOptions, files, kem, true);
    }

    @Inject
    public Kompile(KompileOptions kompileOptions, FileUtil files, KExceptionManager kem, Stopwatch sw) {
        this(kompileOptions, files, kem, sw, true);
    }
    
    // modified by hhh
    // compile entrance
    public Kompile(KompileOptions kompileOptions, FileUtil files, KExceptionManager kem, Stopwatch sw, boolean cacheParses) {
        this.kompileOptions = kompileOptions;
        this.files = files;
        this.kem = kem;
        this.errors = new HashSet<>();
        this.parser = new ParserUtils(files::resolveWorkingDirectory, kem, kem.options);

        //modified by hhh
        //System.out.println("XXXXXXXXXXX\n");

        List<File> lookupDirectories = kompileOptions.outerParsing.includes.stream().map(files::resolveWorkingDirectory).collect(Collectors.toList());
        // these directories should be relative to the current working directory if we refer to them later after the WD has changed.
        kompileOptions.outerParsing.includes = lookupDirectories.stream().map(File::getAbsolutePath).collect(Collectors.toList());

        //modified by hhh
        //System.out.println("YYYYYYYYYYY\n");

        File cacheFile = kompileOptions.experimental.cacheFile != null
                ? files.resolveWorkingDirectory(kompileOptions.experimental.cacheFile) : files.resolveKompiled("cache.bin");
        
        //modified by hhh
        //System.out.println("QQQQQQQQQQQ\n");

        this.definitionParsing = new DefinitionParsing(
                lookupDirectories, kompileOptions.strict(), kompileOptions.profileRules, kem, files,
                parser, cacheParses, cacheFile, !kompileOptions.outerParsing.noPrelude, kompileOptions.isKore());

        //modified by hhh
        //System.out.println("SSSSSSSSSSS\n");

        this.sw = sw;
    }

    public CompiledDefinition run(File definitionFile, String mainModuleName, String mainProgramsModuleName) {
        return run(definitionFile, mainModuleName, mainProgramsModuleName, defaultSteps(kompileOptions, kem, files), Collections.emptySet());
    }

    /**
     * Executes the Kompile tool. This tool accesses a
     *
     * @param definitionFile
     * @param mainModuleName
     * @param mainProgramsModuleName
     * @param programStartSymbol
     * @return
     */
    public CompiledDefinition run(File definitionFile, String mainModuleName, String mainProgramsModuleName, Function<Definition, Definition> pipeline, Set<String> excludedModuleTags) {
        if (kompileOptions.profileRules) {
            for (File f : files.resolveKompiled(".").listFiles()) {
                if (f.getName().matches("timing[0-9]+\\.log")) {
                    f.delete();
                }
            }
        }
        Definition parsedDef = parseDefinition(definitionFile, mainModuleName, mainProgramsModuleName, excludedModuleTags);
        sw.printIntermediate("Parse definition [" + definitionParsing.parsedBubbles.get() + "/" + (definitionParsing.parsedBubbles.get() + definitionParsing.cachedBubbles.get()) + " rules]");

        files.saveToKompiled("parsed.txt", parsedDef.toString());
        checkDefinition(parsedDef, excludedModuleTags);

        Definition kompiledDefinition = pipeline.apply(parsedDef);

        files.saveToKompiled("compiled.txt", kompiledDefinition.toString());
        sw.printIntermediate("Apply compile pipeline");

        if (kompileOptions.experimental.emitJson) {
            try {
                files.saveToKompiled("parsed.json",   new String(ToJson.apply(parsedDef),          "UTF-8"));
                files.saveToKompiled("compiled.json", new String(ToJson.apply(kompiledDefinition), "UTF-8"));
            } catch (UnsupportedEncodingException e) {
                throw KEMException.criticalError("Unsupported encoding `UTF-8` when saving JSON definition.");
            }
        }

        ConfigurationInfoFromModule configInfo = new ConfigurationInfoFromModule(kompiledDefinition.mainModule());

        return new CompiledDefinition(kompileOptions, parsedDef, kompiledDefinition, files, kem, configInfo.getDefaultCell(configInfo.getRootCell()).klabel());
    }

    public Definition parseDefinition(File definitionFile, String mainModuleName, String mainProgramsModule, Set<String> excludedModuleTags) {
        return definitionParsing.parseDefinitionAndResolveBubbles(definitionFile, mainModuleName, mainProgramsModule, excludedModuleTags);
    }

    private static Module filterStreamModules(Module input) {
        if (input.name().equals("STDIN-STREAM") || input.name().equals("STDOUT-STREAM")) {
            return Module(input.name(), Set(), Set(), input.att());
        }
        return input;
    }

    public static Definition resolveIOStreams(KExceptionManager kem,Definition d) {
        return DefinitionTransformer.from(new ResolveIOStreams(d, kem)::resolve, "resolving io streams")
                .andThen(DefinitionTransformer.from(Kompile::filterStreamModules, "resolving io streams"))
                .apply(d);
    }

    private static Module excludeModulesByTag(Set<String> excludedModuleTags, Module mod) {
        Set<Module> newImports = stream(mod.imports()).filter(_import -> excludedModuleTags.stream().noneMatch(tag -> _import.att().contains(tag))).collect(Collectors.toSet());
        return Module(mod.name(), immutable(newImports), mod.localSentences(), mod.att());
    }

    public static Function1<Definition, Definition> excludeModulesByTag(Set<String> excludedModuleTags) {
        DefinitionTransformer dt = DefinitionTransformer.from(mod -> excludeModulesByTag(excludedModuleTags, mod), "remove modules based on attributes");
        return dt.andThen(d -> Definition(d.mainModule(), immutable(stream(d.entryModules()).filter(mod -> excludedModuleTags.stream().noneMatch(tag -> mod.att().contains(tag))).collect(Collectors.toSet())), d.att()));
    }

    public static Function<Definition, Definition> defaultSteps(KompileOptions kompileOptions, KExceptionManager kem, FileUtil files) {
        Function1<Definition, Definition> resolveStrict = d -> DefinitionTransformer.from(new ResolveStrict(kompileOptions, d)::resolve, "resolving strict and seqstrict attributes").apply(d);
        DefinitionTransformer resolveHeatCoolAttribute = DefinitionTransformer.fromSentenceTransformer(new ResolveHeatCoolAttribute(new HashSet<>(kompileOptions.transition), EnumSet.of(HEAT_RESULT, COOL_RESULT_CONDITION, COOL_RESULT_INJECTION))::resolve, "resolving heat and cool attributes");
        DefinitionTransformer resolveAnonVars = DefinitionTransformer.fromSentenceTransformer(new ResolveAnonVar()::resolve, "resolving \"_\" vars");
        DefinitionTransformer guardOrs = DefinitionTransformer.fromSentenceTransformer(new GuardOrPatterns(false)::resolve, "resolving or patterns");
        DefinitionTransformer resolveSemanticCasts =
                DefinitionTransformer.fromSentenceTransformer(new ResolveSemanticCasts(kompileOptions.backend.equals(Backends.JAVA))::resolve, "resolving semantic casts");
        DefinitionTransformer resolveFun = DefinitionTransformer.from(new ResolveFun(false)::resolve, "resolving #fun");
        Function1<Definition, Definition> resolveFunctionWithConfig = d -> DefinitionTransformer.fromSentenceTransformer(new ResolveFunctionWithConfig(d, false)::resolve, "resolving functions with config context").apply(d);
        DefinitionTransformer generateSortPredicateSyntax = DefinitionTransformer.from(new GenerateSortPredicateSyntax()::gen, "adding sort predicate productions");
        DefinitionTransformer generateSortProjections = DefinitionTransformer.from(new GenerateSortProjections()::gen, "adding sort projections");
        DefinitionTransformer subsortKItem = DefinitionTransformer.from(Kompile::subsortKItem, "subsort all sorts to KItem");
        Function1<Definition, Definition> expandMacros = d -> {
          ResolveFunctionWithConfig transformer = new ResolveFunctionWithConfig(d, false);
          return DefinitionTransformer.fromSentenceTransformer((m, s) -> new ExpandMacros(transformer, m, files, kompileOptions, false).expand(s), "expand macros").apply(d);
        };
        GenerateCoverage cov = new GenerateCoverage(kompileOptions.coverage, files);
        Function1<Definition, Definition> genCoverage = d -> DefinitionTransformer.fromRuleBodyTransformerWithRule((r, body) -> cov.gen(r, body, d.mainModule()), "generate coverage instrumentation").apply(d);
        NumberSentences numSents = new NumberSentences(files);
        DefinitionTransformer numberSentences = DefinitionTransformer.fromSentenceTransformer(numSents::number, "number sentences uniquely");
        Function1<Definition, Definition> resolveConfigVar = d -> DefinitionTransformer.fromSentenceTransformer(new ResolveFunctionWithConfig(d, false)::resolveConfigVar, "Adding configuration variable to lhs").apply(d);
        Function1<Definition, Definition> resolveIO = (d -> Kompile.resolveIOStreams(kem, d));

        return def -> resolveIO
                .andThen(resolveFun)
                .andThen(resolveFunctionWithConfig)
                .andThen(resolveStrict)
                .andThen(resolveAnonVars)
                .andThen(d -> new ResolveContexts(kompileOptions).resolve(d))
                .andThen(numberSentences)
                .andThen(d -> { numSents.close(); return d; })
                .andThen(resolveHeatCoolAttribute)
                .andThen(resolveSemanticCasts)
                .andThen(subsortKItem)
                .andThen(expandMacros)
                .andThen(guardOrs)
                .andThen(generateSortPredicateSyntax)
                .andThen(generateSortProjections)
                .andThen(Kompile::resolveFreshConstants)
                .andThen(generateSortPredicateSyntax)
                .andThen(generateSortProjections)
                .andThen(AddImplicitComputationCell::transformDefinition)
                .andThen(d -> new Strategy(kompileOptions.experimental.heatCoolStrategies).addStrategyCellToRulesTransformer(d).apply(d))
                .andThen(ConcretizeCells::transformDefinition)
                .andThen(genCoverage)
                .andThen(Kompile::addSemanticsModule)
                .andThen(resolveConfigVar)
                .apply(def);
    }

    public static Sentence removePolyKLabels(Sentence s) {
      if (s instanceof Production) {
        Production p = (Production)s;
        if (!p.isSyntacticSubsort() && p.params().nonEmpty()) {
            p = p.substitute(immutable(Collections.nCopies(p.params().size(), Sorts.K())));
            return Production(p.klabel().map(KLabel::head), Seq(), p.sort(), p.items(), p.att());
        }
      }
      return s;
    }

    public static Module subsortKItem(Module module) {
        java.util.Set<Sentence> prods = new HashSet<>();
        for (Sort srt : iterable(module.definedSorts())) {
            if (!RuleGrammarGenerator.isParserSort(srt)) {
                // KItem ::= Sort
                Production prod = Production(Seq(), Sorts.KItem(), Seq(NonTerminal(srt)), Att());
                if (!module.sentences().contains(prod)) {
                    prods.add(prod);
                }
            }
        }
        if (prods.isEmpty()) {
            return module;
        } else {
            return Module(module.name(), module.imports(), Stream.concat(stream(module.localSentences()), prods.stream())
                    .collect(org.kframework.Collections.toSet()), module.att());
        }
    }

    public Rule parseAndCompileRule(CompiledDefinition compiledDef, String contents, Source source, Optional<Rule> parsedRule) {
        Rule parsed = parsedRule.orElse(parseRule(compiledDef, contents, source));
        return compileRule(compiledDef.kompiledDefinition, parsed);
    }

    public Rule parseRule(CompiledDefinition compiledDef, String contents, Source source) {
        return definitionParsing.parseRule(compiledDef, contents, source);
    }

    private void checkDefinition(Definition parsedDef, Set<String> excludedModuleTags) {
        CheckRHSVariables checkRHSVariables = new CheckRHSVariables(errors);
        stream(parsedDef.modules()).forEach(m -> stream(m.localSentences()).forEach(checkRHSVariables::check));

        stream(parsedDef.modules()).forEach(m -> stream(m.localSentences()).forEach(new CheckConfigurationCells(errors, m)::check));

        stream(parsedDef.modules()).forEach(m -> stream(m.localSentences()).forEach(new CheckSortTopUniqueness(errors, m)::check));

        stream(parsedDef.modules()).forEach(m -> stream(m.localSentences()).forEach(new CheckStreams(errors, m)::check));

        stream(parsedDef.modules()).forEach(m -> stream(m.localSentences()).forEach(new CheckRewrite(errors, m)::check));

        stream(parsedDef.modules()).forEach(new CheckImports(parsedDef.mainModule(), kem)::check);

        stream(parsedDef.modules()).forEach(m -> stream(m.localSentences()).forEach(new CheckHOLE(errors, m)::check));

        stream(parsedDef.modules()).forEach(m -> stream(m.localSentences()).forEach(new CheckFunctions(errors, m, excludedModuleTags.contains("concrete"))::check));

        Set<String> moduleNames = new HashSet<>();
        stream(parsedDef.modules()).forEach(m -> {
            if (moduleNames.contains(m.name())) {
                errors.add(KEMException.compilerError("Found multiple modules with name: " + m.name()));
            }
            moduleNames.add(m.name());
        });

        CheckKLabels checkKLabels = new CheckKLabels(errors);
        // only check imported modules because otherwise we might have false positives
        Consumer<Module> checkModuleKLabels = m -> stream(m.localSentences()).forEach(s -> checkKLabels.check(s, m));
        stream(parsedDef.mainModule().importedModules()).forEach(checkModuleKLabels);
        checkModuleKLabels.accept(parsedDef.mainModule());

        stream(parsedDef.modules()).forEach(m -> stream(m.localSentences()).forEach(new CheckLabels(errors)::check));

        if (!errors.isEmpty()) {
            kem.addAllKException(errors.stream().map(e -> e.exception).collect(Collectors.toList()));
            throw KEMException.compilerError("Had " + errors.size() + " structural errors.");
        }
    }

    public static Definition addSemanticsModule(Definition d) {
        java.util.Set<Module> allModules = mutable(d.modules());

        Module languageParsingModule = Constructors.Module("LANGUAGE-PARSING",
                Set(d.mainModule(),
                        d.getModule(d.att().get(Att.syntaxModule())).get(),
                        d.getModule("K-TERM").get(),
                        d.getModule(RuleGrammarGenerator.ID_PROGRAM_PARSING).get()), Set(), Att());
        allModules.add(languageParsingModule);
        return Constructors.Definition(d.mainModule(), immutable(allModules), d.att());
    }

    public static Definition resolveFreshConstants(Definition input) {
        return DefinitionTransformer.from(m -> GeneratedTopFormat.resolve(new ResolveFreshConstants(input, false).resolve(m)), "resolving !Var variables")
                .apply(input);
    }

    public Rule compileRule(Definition compiledDef, Rule parsedRule) {
        return (Rule) UnaryOperator.<Sentence>identity()
                .andThen(new ResolveAnonVar()::resolve)
                .andThen(new ResolveSemanticCasts(kompileOptions.backend.equals(Backends.JAVA))::resolve)
                .andThen(s -> concretizeSentence(s, compiledDef))
                .apply(parsedRule);
    }

    public Set<Module> parseModules(CompiledDefinition definition, String mainModule, File definitionFile) {
        Set<Module> modules = definitionParsing.parseModules(definition, mainModule, definitionFile);
        int totalBubbles = definitionParsing.parsedBubbles.get() + definitionParsing.cachedBubbles.get();
        //modified by hhh
        //System.out.println("CCCCCCCCC\n");
        sw.printIntermediate("Parse spec modules [" + definitionParsing.parsedBubbles.get() + "/" + totalBubbles + " rules]");
        return modules;
    }

    private Sentence concretizeSentence(Sentence s, Definition input) {
        ConfigurationInfoFromModule configInfo = new ConfigurationInfoFromModule(input.mainModule());
        LabelInfo labelInfo = new LabelInfoFromModule(input.mainModule());
        SortInfo sortInfo = SortInfo.fromModule(input.mainModule());
        return new ConcretizeCells(configInfo, labelInfo, sortInfo, input.mainModule()).concretize(s);
    }
}
