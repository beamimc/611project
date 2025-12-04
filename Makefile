.PHONY: all clean dir

all: report.html

clean:
	rm -rf figures data report.html
	mkdir -p figures data

dir:
	mkdir -p figures data

# build cleaned data + distribution plots
data/clean_cuisines.csv \
figures/categorical_distributions_all.png \
figures/numeric_distributions_all.png \
figures/country_distribution.png: clean_data.r | dir
	Rscript --vanilla clean_data.r >/dev/null 2>&1

# build author analysis plots
figures/author_success.png \
figures/top_authors_cuisines.png\
figures/top_authors_total_time.png \
figures/top_authors_calories.png: author_analysis.r data/clean_cuisines.csv | dir
	Rscript --vanilla author_analysis.r >/dev/null 2>&1

# build final report 
report.html: report.Rmd figures/categorical_distributions_all.png \
figures/numeric_distributions_all.png \
figures/country_distribution.png \
figures/author_success.png \
figures/top_authors_cuisines.png\
figures/top_authors_total_time.png \
figures/top_authors_calories.png | dir
	Rscript -e "rmarkdown::render('report.rmd', output_format='html_document')"
