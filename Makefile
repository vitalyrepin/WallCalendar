# Main input (w/o extension)
# Additional files the main input file depends on
ADDDEPS=common/preamble.tex common/flags.tex common/flags/fsb.tex common/flags/orthodox.tex

IMAGES=$(addprefix photos/, baikal.png baikalsky.png Carcassonne.png espoo.png finnbay.png hoboi.png irkutsk.png kapchuk.png norilsk.png nuuksio.png peterhof.png piter.png porkkala.png riga.png ruskeala.png savonlinna.png saima.png)
THUMBS=$(addprefix photos/,$(addsuffix .jpg, $(basename $(notdir $(IMAGES)))))

GOALS = 2014.pdf cover.pdf

COPY = if test -r $*.toc; then cp $*.toc $*.toc.bak; fi
RM = /bin/rm -f

all:            $(GOALS)


DEPS = 	2014.tex customization.tex $(ADDDEPS)

2014.pdf: $(DEPS) $(IMAGES)

back.pdf: $(ADDDEPS) $(IMAGES) back.tex
front.pdf: $(ADDDEPS) $(IMAGES) front.tex

cover.pdf: back.pdf front.pdf cover.tex $(IMAGES)

%.jpg:  %.png
	convert $< $@

%.png:  %.dia
	dia -e $@ $<

%.png: %.pic
	pic2plot -T png $< > $@

%.ps: %.pic
	pic2plot -T ps $< > $@

%.eps: %.ps
	ps2eps $<

%.eps:  %.dia
	dia -e $@ $<

%.eps:  %.dot
	dot -Tps $< -o $@

%.pdf:  %.eps
	epstopdf $<

%.eps: %.png
	convert $< $@

%.pdf:          %.tex
# http://tex.stackexchange.com/questions/67859/errors-in-latexmk-with-use-of-auto-pst-pdf-and-hyperref
#		latexmk -e "\$hash_calc_ignore_pattern{'pdf'} = '^/(CreationDate|ModDate|ID) ';" -pdf -pdflatex="pdflatex --shell-escape  %O  %S" $<
		latexmk -pdf -shell-escape $<

clean:
		latexmk -c
		$(RM) -f *.bbl
#		aux *.log *.bbl *.blg *.brf *.cb *.ind *.idx *.ilg  \
#		*.inx *.ps *.dvi *.pdf *.toc *.out *.lot *.lof *.eps *.fls *.fdb_latexmk

