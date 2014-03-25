# Makefile to build CISM documentation
# Useful targets are: glimmer.pdf, glimmer.ps, www
# Not all may be working yet.

# EDIT THESE COMMANDS IF NECESSARY
# ===================================
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

# Python - for autogenerating variables
PYTHON = python

# Location of source directory - for autogenerating variables
top_srcdir = /Users/mhoffman/documents/seacism-oceans11/trunk

# ===================================
# ===================================



# places for make to find files to build
vpath %.dia ./ug/figs ./num/figs ./dg/figures
vpath %.fig ./num/figs ./dg/figures
vpath %.gp ./num/gnu
# where to find the .eps after they are built
vpath %.eps ./ug/figs ./num/figs ./num/gnu ./dg/figures
# path where the varlist .tex file will be created
vpath %.tex ./ug



#=======================
#=======================
# Targets
#=======================
#=======================

# for now, make the all target the thing we want most frequently - glimmer.pdf
all: glimmer.pdf


#=======================
# Primary targets for the documentation
#=======================
%.pdf:	%_pdf.dvi
	$(DVIPDFT) -o $@ $<

%.ps:	%_ps.dvi
	$(DVIPS) -o $@ $<

%.dvi: %.tex makegraphics varlists
	$(LATEX) $<
	$(BIBTEX) $*
	$(LATEX) $<
	$(LATEX) $<

SUBDIRS = dg ug num tut common doclets ext
glimmer_html:  glimmer.tex
	install -d www
	htlatex glimmer_html "html,3,info" "" " -d./www/ -m 644 "
	$(BIBTEX) glimmer_html
	htlatex glimmer_html "html,3,info" "" " -d./www/ -m 644 "
	find $(SUBDIRS) -name '*.png' -exec install -m 644 -D {} ./www/{} \;
#www::   doxygen-run glimmer_html doxygen-run
#        rm -rf $(WWW_DIR)
#        install -d $(WWW_DIR)/$(GLIMMER_VERSION)/API
#        install -d $(WWW_DIR)/$(GLIMMER_VERSION)/manual
#        cp -a doxygen/html/* $(WWW_DIR)/$(GLIMMER_VERSION)/API
#        cp -a www/* $(WWW_DIR)/$(GLIMMER_VERSION)/manual
#        cd $(WWW_DIR) && ln -s $(GLIMMER_VERSION) current
#        tar cvzf $(PACKAGE)-doc.$(GLIMMER_VERSION).tar.gz $(WWW_DIR)
#        rm -rf $(WWW_DIR)

#=======================
#=======================
# Dependecies for the documentation
#=======================
#=======================

# Graphics
#=======================
# list of graphics files that must be made into .eps format for inclusion in .tex compilation
ug_graphics = glide.eps glimmer.eps glint_timesteps.eps
num_graphics = scale.eps grid.eps thick_evo.eps grid_ew.eps basal_bc.eps basal_alg.eps staggered_grid.eps
numgnu_graphics = w_profile.eps wt_sigma.eps
dg_graphics = class_diagram.eps class_diagram_glint.eps glide_mod_depend.eps glimmer_structure.eps

makegraphics: $(ug_graphics) $(num_graphics) $(numgnu_graphics) $(dg_graphics)

# pattern rules for making figures
%.eps:		%.dia
	$(DIA) -t eps-builtin -n -e $(<D)/$*.eps $<

%.eps: 	%.fig
	$(FIG2PS) $< --eps

%.eps: 	%.gp
	cd $(<D); 	echo `pwd`       && \
	$(GNUPLOT) $*.gp           && \
	$(LATEX) $*.tex            && \
	$(DVIPS) -o $*.eps $*.dvi  && \
	cd -


# Auto-generated variable lists
#=======================
# list of variable list tex files to be generated
var_lists = glide_varlist.tex eis_varlist.tex glint_varlist.tex
varlists: $(var_lists)

# how to auto-generate the variable list .tex files
glide_varlist.tex: $(top_srcdir)/libglide/glide_vars.def ./ug/varlist.tex.in
	cd ug; $(PYTHON) $(top_srcdir)/scripts/generate_ncvars.py $(top_srcdir)/libglide/glide_vars.def varlist.tex.in; cd ..
eis_varlist.tex: $(top_srcdir)/example-drivers/eis/src/eis_vars.def ./ug/varlist.tex.in
	cd ug; $(PYTHON) $(top_srcdir)/scripts/generate_ncvars.py $(top_srcdir)/example-drivers/eis/src/eis_vars.def varlist.tex.in; cd ..
glint_varlist.tex: $(top_srcdir)/libglint/glint_vars.def ./ug/varlist.tex.in
	cd ug; $(PYTHON) $(top_srcdir)/scripts/generate_ncvars.py $(top_srcdir)/libglint/glint_vars.def varlist.tex.in; cd ..

# Finally, the clean target.  Need to add the subdirectory files that might get made.
clean:
	rm -f *.aux *.dvi *.pdf *.log *.out *.toc *.bbl *.blg *.eps
	rm -f ug/figs/*.eps num/figs/*.eps num/gnu/*.eps ./dg/figures/*.eps
	rm -f num/gnu/*.eps num/gnu/*.aux num/gnu/*.dvi num/gnu/*.tex num/gnu/*.log
	rm -f ug/*_varlist.tex


