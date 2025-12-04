FROM --platform=linux/amd64 rocker/verse:latest


RUN R -e "install.packages(c('tidytuesdayR', 'tidyverse', \
            'skimr', 'patchwork', 'ggrepel', 'plotly', 'fastDummies',\
             'FactoMineR', 'factoextra', 'cluster', 'reshape2', 'viridis'),\
            dependencies=TRUE)"

