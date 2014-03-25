# Makefile to build CISM documentation
# Useful targets are: glimmer.pdf, glimmer.ps, www
# Not all may be working yet.

# EDIT THESE COMMANDS IF NECESSARY
# ===================================
# commands to make documentation
LATEX = latex
BIBTEX = bibtex
DVIPDFT = dvipdft

# Commands to make figures
DIA = dia
FIG2PS = fig2ps

# ===================================

# places for make to find files to build
vpath %.dia ./ug/figs ./num/figs
vpath %.fig ./num/figs

# list of graphics files that must be made into .eps format for inclusion in .tex compilation
ug_graphics = glide.eps glimmer.eps glint_timesteps.eps
num_graphics = scale.eps grid.eps thick_evo.eps grid_ew.eps basal_bc.eps basal_alg.eps staggered_grid.eps



#========
# Targets
#========


# for now, make the all target the thing we want most frequently - glimmer.pdf
all: glimmer.pdf

# Primary targets for the documentation
#=======================
%.pdf:	%_pdf.dvi
	$(DVIPDFT) -o $@ $<

%.ps:	%_ps.dvi
	dvips -o $@ $<

%.dvi: %.tex makegraphics
	$(LATEX) $<
	$(BIBTEX) $*
	$(LATEX) $<
	$(LATEX) $<


# Dependecies for the documentation
#=======================
makegraphics: $(ug_graphics) $(num_graphics)
	echo "DOING makegraphics"


# pattern rules for making figures
#=======================
%.eps:		%.dia
	echo "DOING DIA" $(<D)/$*
	$(DIA) -t eps-builtin -n -e $(<D)/$*.eps $<

%.eps: 	%.fig
	$(FIG2PS) $< --eps


# Finally, the clean target.  Need to add the subdirectory files that might get made.
clean:
	rm -f *.aux *.dvi *.pdf *.log *.out *.toc *.bbl *.blg *.eps
	rm -f ug/figs/*.eps num/figs/*.eps
