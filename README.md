# Cuisines — EDA & Analysis

Compact project for exploratory analysis, clustering and simple modelling on the TidyTuesday `cuisines` dataset (recipes, nutrition, ratings).
A description of the dataset can be found [here](https://github.com/rfordatascience/tidytuesday/blob/main/data/2025/2025-09-16/readme.md), provided by the TidyTuesday project.

---

## Repository layout

- `clean_data.r`         — data load / cleaning, creates `data/clean_cuisines.csv` and distribution figures
- `author_analysis.r`    — author-level analysis and figures
- `report.rmd`           — report that includes generated figures
- `Makefile`             — top-level pipeline (build data, figures, render report)
- `Dockerfile`           — R environment (rocker/verse) with packages
- `start.sh`             — build & run Docker image (RStudio / interactive)
- `data/`                — directory for cleaned CSV output (generated)
- `figures/`             — generated PNG/HTML outputs (ignored by git)
- `.gitignore`           — ignores `figures/`, .DS_Store and .dockerignore
---

## Quick start (development)

Requirements: Docker (if using container) and R (if running locally).

1. Clone the repo and cd into it:
```bash
git clone https://github.com/beamimc/611project.git
cd 611_project
```

2a. Run with Docker (recommended for reproducibility)
```bash
# build image (only once or after Dockerfile changes)
docker build . -t project611 --platform=linux/amd64

# run interactive container with project mounted and RStudio on :8787
bash start.sh 
# or 
docker run --platform linux/amd64 \
  -e USERID=$(id -u) \
  -e GROUPID=$(id -g) \
  -v $(pwd):/home/rstudio/work \
  -v $HOME/.ssh:/home/rstudio/.ssh \
  -v $HOME/.gitconfig:/home/rstudio/.gitconfig \
  -w /home/rstudio/work \
  -p 8787:8787 -it project611

# then open http://localhost:8787 (user: rstudio / password: provided in terminal for rocker images)
```

2b. Or run locally with R
```bash
# ensure required packages are installed, then run:
Rscript --vanilla clean_data.r
Rscript --vanilla author_analysis.r
```

---

## Pipeline / Makefile

The project uses a Makefile to run the pipeline and render the report.

- Run the full pipeline and render the report:
```bash
make
```

- Rebuild outputs from scratch:
```bash
make clean
make
```

Targets created by the pipeline:
- `data/clean_cuisines.csv`
- `figures/categorical_distributions_all.png`
- `figures/numeric_distributions_all.png`
- `figures/country_distribution.png`
- author figures: `figures/author_success.png`, `figures/top_authors_cuisines.png`, `figures/top_authors_total_time.png`, `figures/top_authors_calories.png`
- `report.html` (rendered from `report.rmd`)

---

## Typical workflows

- Update code, re-run the pipeline and regenerate the report:
```bash
# rebuild data & figures, then render report
make
```

- Quick interactive analysis:
```bash
# start a shell inside the image, working dir mounted
docker run --platform linux/amd64 -it -v "$(pwd)":/home/rstudio/work -w /home/rstudio/work project611 /bin/bash
```

---

## Troubleshooting

- If `make` always rebuilds, check file names and timestamps. Ensure the R scripts write the exact target filenames listed in the Makefile.
- To silence Rscript output in Make, the Makefile uses `Rscript --vanilla --slave ... >/dev/null 2>&1` — check `logs/` if you add logging.
- If Docker port 8787 conflicts, change `-p 8787:8787` in `start.sh`.

---

## License & contact

See repository for license or contact information.<!-- filepath: /Users/beacm/Documents/GitHub_local/611_project/README.md -->

# Cuisines — EDA & Analysis

Compact project for exploratory analysis, clustering and simple modelling on the TidyTuesday `cuisines` dataset (recipes, nutrition, ratings).

---

## Repository layout

- `clean_data.r`         — data load / cleaning, creates `data/clean_cuisines.csv` and distribution figures
- `author_analysis.r`    — author-level summaries & author figures
- `analysis_calories.r`  — clustering / PCA / calories analysis
- `report.rmd`           — simple report that includes pipeline figures
- `Makefile`             — top-level pipeline (build data, figures, render report)
- `Dockerfile`           — R environment (rocker/verse) with packages
- `start.sh`             — build & run Docker image (RStudio / interactive)
- `data/`                — cleaned CSV output (generated)
- `figures/`             — generated PNG/HTML outputs (ignored by git)
- `models/`              — saved model objects (optional)
- `.gitignore`           — ignores `figures/`, other outputs

---

## Quick start (development)

Requirements: Docker (if using container) and R (if running locally).

1. Clone the repo and cd into it:
```bash
cd /path/to/parent
git clone <repo-url>
cd 611_project
```

2a. Run with Docker (recommended for reproducibility)
```bash
# build image (only once or after Dockerfile changes)
docker build . -t project611 --platform=linux/amd64

# run interactive container with project mounted and RStudio on :8787
bash start.sh
# then open http://localhost:8787 (user: rstudio / password: rstudio for rocker images)
```

2b. Or run locally with R
```bash
# ensure required packages are installed, then run:
Rscript --vanilla clean_data.r
Rscript --vanilla author_analysis.r
```

---

## Pipeline / Makefile

The project uses a Makefile to run the pipeline and render the report.

- Run the full pipeline and render the report:
```bash
make
```

- Rebuild outputs from scratch:
```bash
make clean
make
```

Targets created by the pipeline:
- `data/clean_cuisines.csv`
- `figures/categorical_distributions_all.png`
- `figures/numeric_distributions_all.png`
- `figures/country_distribution.png`
- author figures: `figures/author_success.png`, `figures/top_authors_cuisines.png`, `figures/top_authors_total_time.png`, `figures/top_authors_calories.png`
- `report.html` (rendered from `report.rmd`)

Note: Make uses timestamps. If a file is newer than its prerequisites it will be considered up-to-date.

---

## Build the report

The report is rendered from `report.rmd`. To create `report.html`:

- With Make:
```bash
make report.html
```

- Directly in R:
```r
rmarkdown::render("report.rmd", output_format = "html_document")
```

To open on macOS:
```bash
open report.html
```

---

## Typical workflows

- Update code, re-run the pipeline and regenerate the report:
```bash
# rebuild data & figures, then render report
make
```

- Quick interactive analysis:
```bash
# start a shell inside the image, working dir mounted
docker run --platform linux/amd64 -it -v "$(pwd)":/home/rstudio/work -w /home/rstudio/work project611 /bin/bash
```

