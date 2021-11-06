# SimSoC-Cert, a toolkit for generating certified processor simulators
# See the COPYRIGHTS and LICENSE files.


DIR := .

ifeq ($(VERBOSE),1)
  SHOW := @true
  HIDE :=
else
  SHOW := @echo
  HIDE := @
endif

OCAMLBUILD := ocamlbuild -pp camlp4o -j 2 -no-hygiene -no-links

TARGETS := keepoper indentation oneline_expr keepbincode parsebincode \
	keepsyntax parsesyntax convert_syntax

default: $(TARGETS)

$(TARGETS):
	$(SHOW) ocamlbuild $@
	$(HIDE) $(OCAMLBUILD) $@.d.byte $@.native

clean::
	rm -f $(TARGETS)
