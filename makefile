INDEX=docs/_build/html/index
README=README

all:
	make build

build: ## readthedocs 'make html' command
	cd docs;	\
	make html;	\
	cd ..

open: $(INDEX).html ## Open the main 'html' page
	xdg-open $(INDEX).html &

readme: $(README).Rmd
	echo "rmarkdown::render('$(README).Rmd',output_format=rmarkdown::md_document(variant='gfm'))" | R --no-save -q

clean: ## Run readthedocs 'make clean' + clean all 'grab' targets (R pkg files)
	cd docs;	\
	make clean;	\
	cd ..

help: ## Show this help
		@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
	
# Phony targets:
.PHONY: all
.PHONY: build
.PHONY: open
.PHONY: readme
.PHONY: clean
.PHONY: help
