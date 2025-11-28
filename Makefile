.PHONY: all clean dir


# default target: build cleaned data
all: data/eurovision_cleaned.csv


clean:
	rm -rf figures
	mkdir figures
	rm -rf data
	mkdir data
	rm report.html

dir:
	mkdir figures
	mkdir data


# build cleaned data to run analysis on
data/eurovision_cleaned.csv: clean_data.r
	Rscript --vanilla --slave clean_data.r >/dev/null # hide stdout