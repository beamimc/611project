.PHONY: all clean dir


# default target: build cleaned data
all: data/clean_cuisines.csv figures/categorical_distributions_all.png \
	figures/numeric_distributions_all.png figures/author_success.png \
	figures/top_authors_cuisines.png \
# 	report.html

clean:
	rm -rf figures
	mkdir figures
	rm -rf data
	mkdir data
	rm report.html

dir:
	mkdir figures
	mkdir data


# build cleaned data to run analysis and distribution plots
data/clean_cuisines.csv figures/categorical_distributions_all.png figures/numeric_distributions_all.png: clean_data.r
	mkdir -p figures data
	Rscript --vanilla --slave clean_data.r >/dev/null 2>&1 # hide stdout

# build analysis by author figures
figures/author_success.png figures/top_authors_cuisines.png: author_analysis.r data/clean_cuisines.csv
	Rscript --vanilla --slave author_analysis.r >/dev/null 2>&1 # hide stdout

# # build final report
# report.html: report.Rmd data/clean_cuisines.csv figures/categorical_distributions_all.png \
# 	figures/numeric_distributions_all.png figures/author_success.png \
# 	figures/top_authors_cuisines.png
# 	Rscript -e "rmarkdown::render('report.Rmd', output_file = 'report.html')" >/dev/null 2>&1 # hide stdout