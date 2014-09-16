# Makefile to build CISM documentation
# Useful targets are: glimmer.pdf, glimmer.ps, www
# Not all may be working yet.



# ===================================
# EDIT THESE COMMANDS IF NECESSARY
# ===================================

# Location of source directory - needed for autogenerating variables only
#top_srcdir = /Users/mhoffman/documents/cism/trunk
top_srcdir = /Users/sprice/work/modeling/cism/seacism

# commands to make documentation
LATEX = latex
BIBTEX = bibtex
DVIPDFT = dvipdft

# Python - for autogenerating variables
PYTHON = python

# ===================================
# ===================================




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

%.dvi: %.tex graphics varlists
	$(LATEX) $<
	$(BIBTEX) $*
	$(LATEX) $<
	$(LATEX) $<

SUBDIRS = dg ug num tut common doclets ext higher-order install intro shallow-ice modeling-intro tests physics
glimmer_html:  glimmer.tex
	install -d www
	htlatex glimmer_html "html,3,info" "" " -d./www/ -m 644 "
	$(BIBTEX) glimmer_html
	htlatex glimmer_html "html,3,info" "" " -d./www/ -m 644 "
	# First create the subdirectories needed for the png's to go into
	find . -name '*.png' |grep -o '.*/' |sort|uniq | cut -f 1 | xargs -I {} install -d ./www/{}
	find $(SUBDIRS) -name '*.png' -exec install -m 644 {} ./www/{} \;
# old version that uses the handy -D option to create directories before installing but which is not available on Mac's crappy old 'install' version
#	find $(SUBDIRS) -name '*.png' -exec install -m 644 -D {} ./www/{} \;
	#TODO Clean up the rest of the junk that is created by htlatex
	rm -f *.html

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
# Dependecies for the documentation
#=======================

# Graphics
#=======================
# Include the graphics files as dependencies so that if they are updated manually, the documentation will know about it...
# where to find the .eps files
vpath %.eps ./ug/figs ./num/figs ./num/gnu ./dg/figures
# list of graphics files
ug_graphics = glide.eps glimmer.eps glint_timesteps.eps
num_graphics = scale.eps grid.eps thick_evo.eps grid_ew.eps basal_bc.eps basal_alg.eps staggered_grid.eps
numgnu_graphics = w_profile.eps wt_sigma.eps
dg_graphics = class_diagram.eps class_diagram_glint.eps glide_mod_depend.eps glimmer_structure.eps
graphics: $(ug_graphics) $(num_graphics) $(numgnu_graphics) $(dg_graphics)



# Auto-generated variable lists
#=======================
# path where the varlist .tex file will be created
vpath %.tex ./ug
# list of variable list tex files to be generated
var_lists = glide_varlist.tex glint_varlist.tex
varlists: $(var_lists)

# how to auto-generate the variable list .tex files
glide_varlist.tex: $(top_srcdir)/libglide/glide_vars.def ./ug/varlist.tex.in
	cd ug; $(PYTHON) $(top_srcdir)/utils/build/generate_ncvars.py $(top_srcdir)/libglide/glide_vars.def varlist.tex.in; cd ..
glint_varlist.tex: $(top_srcdir)/libglint/glint_vars.def ./ug/varlist.tex.in
	cd ug; $(PYTHON) $(top_srcdir)/utils/build/generate_ncvars.py $(top_srcdir)/libglint/glint_vars.def varlist.tex.in; cd ..


#=======================
# Finally, the clean target.  Need to add the subdirectory files that might get made.
clean:
	rm -f *.aux *.dvi *.pdf *.log *.out *.toc *.bbl *.blg *.eps *.ps
	rm -f ug/*_varlist.tex
	# clean all the junk created by the html build
	rm -rf www *.png *.html
