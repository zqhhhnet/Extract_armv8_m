// Copyright (c) 2014-2019 K Team. All Rights Reserved.
package org.kframework.main;

import org.kframework.utils.InterrupterRunnable;
import org.kframework.utils.StringUtil;
import org.kframework.utils.errorsystem.KEMException;
import org.kframework.utils.errorsystem.KException;
import org.kframework.utils.errorsystem.KExceptionManager;
import org.kframework.utils.file.FileUtil;
import org.kframework.utils.file.JarInfo;

import com.google.inject.Provider;
import com.beust.jcommander.ParameterException;

public abstract class FrontEnd {

    protected abstract int run();

    private final KExceptionManager kem;
    private final GlobalOptions globalOptions;
    private final String usage, experimentalUsage;
    private final JarInfo jarInfo;
    private final Provider<FileUtil> files;

    public FrontEnd(
            KExceptionManager kem,
            GlobalOptions globalOptions,
            String usage,
            String experimentalUsage,
            JarInfo jarInfo,
            Provider<FileUtil> files) {
        this.kem = kem;
        this.globalOptions = globalOptions;
        this.usage = usage;
        this.experimentalUsage = experimentalUsage;
        this.jarInfo = jarInfo;
        this.files = files;
    }

    public int main() {
        int retval;
        try {
            if (globalOptions.help) {
                System.out.print(usage);
                retval = 0;
            } else if (globalOptions.helpExperimental) {
                System.out.print(experimentalUsage);
                retval = 0;
            } else if (globalOptions.version) {
                jarInfo.printVersionMessage();
                retval = 0;
            } else {
                if (globalOptions.shutdownWaitTime > 0 && ! Main.isNailgun()) {
                    //Will interrupt the thread on Ctrl+C and allow the backend to terminate gracefully.
                    Runtime.getRuntime().addShutdownHook(new Thread(
                            new InterrupterRunnable(Thread.currentThread(), globalOptions.shutdownWaitTime)));
                }
                try {
                    //modified by hhh
                    //System.out.println("FrontEnd to run @@@@\n");
                    retval = run();
                } catch (ParameterException e) {
                    throw KEMException.criticalError(e.getMessage(), e);
                } finally {
                    files.get().deleteTempDir(kem);
                }
                kem.print();
            }
        } catch (KEMException e) {
            // terminated with errors, so we need to return nonzero error code.
            retval = KEMException.TERMINATED_WITH_ERRORS_EXIT_CODE;
            if (globalOptions.debug()) {
                e.printStackTrace();
            } else {
                kem.registerThrown(e);
            }
            kem.print();
        }
        return retval;
    }

    public static void printBootError(String message) {
        System.err.println(StringUtil.splitLines(KException.criticalError(message).toString()));
    }
}
