# SimSoC-Cert, a toolkit for generating certified processor simulators
# See the COPYRIGHTS and LICENSE files.

DIR := ..

include $(DIR)/Makefile.common

default: arm8.pc arm8.dec arm8.syntax

SUBDIRS := parsing

clean::
	@for d in $(SUBDIRS); do make -C $$d $@; done

###########################################################################
# file decompression

.PRECIOUS: arm6.txt

arm6.txt: arm6.txt.gz
	gunzip -c $< > $@

clean::
	rm -f arm6.txt

###########################################################################
# creation of arm6.txt.gz

.PHONY: pdftotext

pdftotext: arm6.pdf
	pdftotext -layout $< arm6.txt && gunzip arm6.txt

###########################################################################
# patch application

# arm6patched.txt: arm6.txt arm6patch.ed
#	cp -f $< $@ && ed -s $@ < arm6patch.ed

# clean::
#	rm -f arm6patched.txt

###########################################################################
# update patch

# .PHONY: patch

# patch: arm6.txt arm6patched.txt
#	-diff -e $+ > arm6patch.ed; echo w >> arm6patch.ed

###########################################################################
# parsing

.DELETE_ON_ERROR: arm8.pc

arm8.pc: armv8_m.txt parsing/keepoper parsing/oneline_expr \
		parsing/preproc_pseudo.sh parsing/indentation
	$(SHOW) generate $@ from $<
	$(HIDE) cat $< | parsing/keepoper | parsing/oneline_expr \
		| parsing/preproc_pseudo.sh | parsing/indentation > $@

.DELETE_ON_ERROR: arm8.dec

arm8.dec: armv8_m.txt parsing/keepbincode parsing/parsebincode
	$(SHOW) generate $@ from $<
	$(HIDE) cat $< | parsing/keepbincode | parsing/parsebincode > $@

.DELETE_ON_ERROR: arm8.syntax

arm8.syntax: armv8_m.txt parsing/keepsyntax parsing/parsesyntax \
		parsing/blanks_syntax.sh
	$(SHOW) generate $@ from $<
	$(HIDE) cat $< | parsing/keepsyntax | parsing/blanks_syntax.sh \
		| parsing/parsesyntax > $@

ARM6_PARSING := indentation keepbincode keepoper oneline_expr parsebincode \
		keepsyntax parsesyntax

$(ARM6_PARSING:%=parsing/%): FORCE
	$(MAKE) -C $(DIR)/arm6/parsing $(@:parsing/%=%)

clean::
	rm -f arm8.pc arm8.dec arm8.syntax
