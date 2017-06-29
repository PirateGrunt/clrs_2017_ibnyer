all: Presentation.html

Presentation.html:Presentation.Rmd revealOpts.css
	Rscript -e "rmarkdown::render('$<', output_format = 'all')"
  
Presentation.Rmd:bibliography.bib ToyExample.rda NotSoToyExample.rda
	touch Presentation.Rmd
	
ToyExample.rda:ToyExample.R
	Rscript -e "source('ToyExample.R')"
	
NotSoToyExample.rda:NotSoToyExample.R
	Rscript -e "source('$<')"
	
ToyExample.rda NotSoToyExample.rda:TriangleUtils.R

clean:
	rm *.html
	rm *.rda
