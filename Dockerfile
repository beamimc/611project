FROM --platform=linux/amd64 rocker/verse:latest


RUN R -e "install.packages(c('tidytuesdayR', 'tidyverse', 'skimr'), dependencies=TRUE)"

