// Copyright (c) 2015-2019 K Team. All Rights Reserved.
package org.kframework.kprove;

import com.google.inject.Inject;
import org.apache.commons.io.FilenameUtils;
import org.kframework.RewriterResult;
import org.kframework.attributes.Source;
import org.kframework.compile.Backend;
import org.kframework.definition.Definition;
import org.kframework.definition.Module;
import org.kframework.definition.Rule;
import org.kframework.kompile.CompiledDefinition;
import org.kframework.kompile.Kompile;
import org.kframework.krun.KRun;
import org.kframework.rewriter.Rewriter;
import org.kframework.unparser.KPrint;
import org.kframework.utils.Stopwatch;
import org.kframework.utils.errorsystem.KEMException;
import org.kframework.utils.errorsystem.KExceptionManager;
import org.kframework.utils.file.FileUtil;
import scala.Option;
import scala.Tuple2;

import java.io.File;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.function.Function;


/**
 * Class that implements the "--prove" option.
 */
public class KProve {

    public static final String BOUNDARY_CELL_PREFIX = "BOUND_";

    private final KExceptionManager kem;
    private final Stopwatch sw;
    private final FileUtil files;
    private final KPrint kprint;
    private final KProveOptions kproveOptions;

    @Inject
    public KProve(KExceptionManager kem, Stopwatch sw, FileUtil files, KPrint kprint, KProveOptions kproveOptions) {
        this.kem    = kem;
        this.sw     = sw;
        this.files  = files;
        this.kprint = kprint;
        this.kproveOptions = kproveOptions;
    }
    
    /* modified by hhh
        kprove entrance
    */
    public int run(KProveOptions options, CompiledDefinition compiledDefinition, Backend backend, Function<Definition, Rewriter> rewriterGenerator) {
        Tuple2<Definition, Module> compiled = getProofDefinition(options.specFile(files), options.defModule, options.specModule, compiledDefinition, backend, files, kem, sw);
        Rewriter rewriter = rewriterGenerator.apply(compiled._1());
        Module specModule = compiled._2();

        /*
        // modified by hhh
        System.out.println("rewriter @@@\n");
        System.out.println(compiled._1().toString() + "\n");
        System.out.println("======\n");
        System.out.println("specModule ###\n");
        System.out.println(specModule.toString() + "\n");
        System.out.println("check ######\n");
        */

        Rule boundaryPattern = buildBoundaryPattern(compiledDefinition);

        RewriterResult results = rewriter.prove(specModule, boundaryPattern);
        kprint.prettyPrint(compiled._1(), compiled._1().getModule("LANGUAGE-PARSING").get(), s -> kprint.outputFile(s), results.k());
        return results.exitCode().orElse(KEMException.TERMINATED_WITH_ERRORS_EXIT_CODE);
    }

    private static Module getModule(String defModule, Map<String, Module> modules, Definition oldDef) {
        if (modules.containsKey(defModule))
            return modules.get(defModule);
        Option<Module> mod = oldDef.getModule(defModule);
        if (mod.isDefined()) {
            return mod.get();
        }
        throw KEMException.criticalError("Module " + defModule + " does not exist.");
    }

    public static Map<Definition, Definition> cache = Collections.synchronizedMap(new LinkedHashMap<Definition, Definition>() {
        @Override
        protected boolean removeEldestEntry(Map.Entry entry) {
            return size() > 10;
        }
    });

    public static Tuple2<Definition, Module> getProofDefinition(File proofFile, String defModuleName, String specModuleName, CompiledDefinition compiledDefinition, Backend backend, FileUtil files, KExceptionManager kem, Stopwatch sw) {
        Kompile kompile = new Kompile(compiledDefinition.kompileOptions, files, kem, sw, true);

        //modified by hhh
        //System.out.println("ZZZZZZZZZZZZ\n");

        if (defModuleName == null) {
            defModuleName = compiledDefinition.kompiledDefinition.mainModule().name();
        }
        if (specModuleName == null) {
            specModuleName = FilenameUtils.getBaseName(proofFile.getName()).toUpperCase();
        }

        //modified by hhh
        //System.out.println("AAAAAAAAAAAA\n");

        java.util.Set<Module> modules = kompile.parseModules(compiledDefinition, defModuleName, files.resolveWorkingDirectory(proofFile).getAbsoluteFile());
        
        //modified by hhh
        //System.out.println("BBBBBBBBBBBBB\n");
        
        Map<String, Module> modulesMap = new HashMap<>();
        modules.forEach(m -> modulesMap.put(m.name(), m));
        Module defModule = getModule(defModuleName, modulesMap, compiledDefinition.getParsedDefinition());
        Module specModule = getModule(specModuleName, modulesMap, compiledDefinition.getParsedDefinition());
        specModule = backend.specificationSteps(compiledDefinition.kompiledDefinition).apply(specModule);
        Definition combinedDef = Definition.apply(defModule, compiledDefinition.getParsedDefinition().entryModules(), compiledDefinition.getParsedDefinition().att());
        combinedDef = Kompile.excludeModulesByTag(backend.excludedModuleTags()).apply(combinedDef);
        Definition compiled = compileDefinition(backend, combinedDef);
        return Tuple2.apply(compiled, specModule);
    }

    private static Definition compileDefinition(Backend backend, Definition combinedDef) {
        Definition compiled = cache.get(combinedDef);
        if (compiled == null) {
            compiled = backend.steps().apply(combinedDef);
            cache.put(combinedDef, compiled);
        }
        return compiled;
    }

    /**
     * A pattern that implements --boundary-cells functionality. When this pattern matches, in the resulting
     * substitution, for each boundary cell there will be a variable starting with {@code "BOUND_"}. Other variables
     * must be ignored.
     *
     * @return the rule corresponding to boundary pattern, or null if no boundary cells were set.
     */
    public Rule buildBoundaryPattern(CompiledDefinition compiledDefinition) {
        if (kproveOptions.boundaryCells.isEmpty()) {
            return null;
        }
        StringBuilder patternStr = new StringBuilder();
        for (String cell : kproveOptions.boundaryCells) {
            //for each boundary cell add a sequence of the form `<cell> VAR </cell>`
            patternStr.append(String.format("<%2$s> %1$s%2$s </%2$s> ", BOUNDARY_CELL_PREFIX, cell));
        }

        return KRun.compilePattern(files, kem, patternStr.toString(), compiledDefinition,
                Source.apply("<option --boundary-cells>"));
    }
}
