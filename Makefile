.PHONY: all clean dir


# default target: build cleaned data
all: data/clean_cuisines.csv figures/categorical_distributions_all.png figures/numeric_distributions_all.png

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

# # build EDA figures
# figures/distribution_all.png: analysis.r data/clean_cuisines.csv
# 	Rscript --vanilla --slave analysis.r >/dev/null # hide stdout