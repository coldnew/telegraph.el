CASK  ?= cask
EMACS ?= emacs
BATCH := $(CASK) $(EMACS) $(EFLAGS) -batch -q -no-site-file -L .

all: telegraph.elc

clean:
	$(RM) *.elc

%.elc: %.el
	$(BATCH) --eval '(byte-compile-file "$<")'

test:
	$(CASK) install
	$(BATCH) -L . -l test/test.el -f ert-run-tests-batch-and-exit

.PHONY: check clean test README.md
