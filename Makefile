
LATEX = latex
BIBTEX = bibtex
DVIPDFT = dvipdft

.tex.dvi::
	$(LATEX) $<
	$(BIBTEX) $*
	$(LATEX) $<
	$(LATEX) $<

%.ps:	%_ps.dvi
	dvips -o $@ $<

%.pdf:	%_pdf.dvi
	$(DVIPDFT) -o $@ $<

.PHONY: clean
clean:
	rm -f *.aux *.dvi *.pdf *.log *.out *.toc *.bbl *.blg
