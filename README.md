# Spiderfish: A pipeline for downloading and sorting Fishbase images
## A forked and modified version of [hiweller/spiderfish](https://github.com/hiweller/spiderfish)

**Author**: Cameron Trotter\
**Email**: c.trotter2@ncl.ac.uk

### About

A web scraper utilising python and R to download images from [Fishbase](https://fishbase.org) based on scientific family. Images are then filtered to retain only full body, lateral view images which contain relatively uniform backgrounds.

The pipeline follows 4 steps for each given fish family:

1) Downloads all images of that fish family that have confirmed identifications from Fishbase using [Scrapy](https://scrapy.org/) in python. Crawls species pages for photographs. See `fishbase` folder for scraper definitions.

2) Sorts images into `Pass` or `Fail` categories based on regionalised colour histogram indices with [OpenCV](https://opencv.org/) in python . See `Sorting.py` and `colordescriptor.py`. Image classification follows the methodology outlined [here](https://pyimagesearch.com/2014/12/01/complete-guide-building-image-search-engine-python-opencv/). For example images that pass and fail, and why, see the `Images` folder.

3) Fetches a list of all species in family from Fishbase using the [rfishbase](https://github.com/ropensci/rfishbase) package in R .

4) Outputs list of species in family missing images from fishbase (if any), list of species whose only images were rejected by the image classifier (not good candidates for morphometrics), and a list of which species correspond to which image names.

The results are stored in a directory specified by the user, in a `$FamilyName` folder. The folder has 3 subfolders: `Pass`, `Fail`, and `All`, which contain images passed by the classifier, images rejected by the classifier, and duplicates of all images in case you don't care about the classification, respectively. The folder also contains a JSON file with all the image URLs, image names, and species names, as well as the generated CSV files. Unlike to original version this repo is forked from, no size information is crawled (not needed for our use case).

### Usage

To clone the repository onto your computer:
```bash
git clone https://github.com/Trotts/spiderfish
```

Before running, set the `swd` variable in `go_fishing.sh` to the absolute filepath of the cloned spiderfish repo.

Running the pipeline is performed using:

```bash
cd spiderfish
bash go_fishing.sh /PATH/TO/families.csv /PATH/TO/OUTPUT/DIR
```

where `/PATH/TO/families.csv` points to a CSV file containing a list of fish families to scrape (see `example_input.csv` for an example input) and `/PATH/TO/OUTPUT/DIR` is the location to store the scraped and filtered images. This must be passed as an absolute filepath! The bash script must be ran from within the `spiderfish` folder.

After 1-2 minutes of initialising, Scrapy usually downloads images at about 50-100 images/minute from Fishbase. This is by far the longest step. Once it finishes, the image classifier and species tallies take a few seconds to run.

Scrapy by default attempts to crawl `fishbase.net.br`. Check this Fishbase mirror is operational before running. If not, the mirror used can be changed by modifying the `allowed_domains` and `start_urls` in `spiderfish/fishbase/spiders/spider_fish.py`. 

### Requirements

For a list of python requirements, see `requirements.txt`. Tested using Python 3.9.0, R 4.2.1 (2022-06-23) "Funny-Looking Kid", and [rfishbase](https://cran.r-project.org/web/packages/rfishbase/rfishbase.pdf) version 4.0.0.
