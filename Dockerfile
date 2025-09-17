FROM --platform=linux/amd64 rocker/verse:latest

# Install additional R packages
RUN R -e "install.packages('matlab')"

