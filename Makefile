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
GNUPLOT = gnuplot
DVIPS = dvips

# ===================================

# places for make to find files to build
vpath %.dia ./ug/figs ./num/figs ./dg/figures
vpath %.fig ./num/figs ./dg/figures
vpath %.gp ./num/gnu
# where to find the .eps after they are built
vpath %.eps ./ug/figs ./num/figs ./num/gnu ./dg/figures

# list of graphics files that must be made into .eps format for inclusion in .tex compilation
ug_graphics = glide.eps glimmer.eps glint_timesteps.eps
num_graphics = scale.eps grid.eps thick_evo.eps grid_ew.eps basal_bc.eps basal_alg.eps staggered_grid.eps
numgnu_graphics = w_profile.eps wt_sigma.eps
dg_graphics = class_diagram.eps class_diagram_glint.eps glide_mod_depend.eps glimmer_structure.eps


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
	$(DVIPS) -o $@ $<

%.dvi: %.tex makegraphics
	$(LATEX) $<
	$(BIBTEX) $*
	$(LATEX) $<
	$(LATEX) $<


# Dependecies for the documentation
#=======================
makegraphics: $(ug_graphics) $(num_graphics) $(numgnu_graphics) $(dg_graphics)
	echo "DOING makegraphics"


# pattern rules for making figures
#=======================
%.eps:		%.dia
	echo "DOING DIA" $(<D)/$*
	$(DIA) -t eps-builtin -n -e $(<D)/$*.eps $<

%.eps: 	%.fig
	$(FIG2PS) $< --eps

%.eps: 	%.gp
	cd $(<D); 	echo `pwd`       && \
	$(GNUPLOT) $*.gp           && \
	$(LATEX) $*.tex            && \
	$(DVIPS) -o $*.eps $*.dvi  && \
	cd -

# Finally, the clean target.  Need to add the subdirectory files that might get made.
clean:
	rm -f *.aux *.dvi *.pdf *.log *.out *.toc *.bbl *.blg *.eps
	rm -f ug/figs/*.eps num/figs/*.eps num/gnu/*.eps ./dg/figures/*.eps
	rm -f num/gnu/*.eps num/gnu/*.aux num/gnu/*.dvi num/gnu/*.tex num/gnu/*.log


