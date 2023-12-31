# CRESHMap

Various scripts used for processing data for the CRESHMap application

##### tobacco_scraper.py

Harvests data from https://www.tobaccoregisterscotland.org/ using Python Requests

Exports a CSV file with details of all tobacco retail outlets in Scotland with postcode

##### tobacco_data_2023.R

Uses CSV data from tobacco_scraper.py

Uses NRS data:

https://www.nrscotland.gov.uk/statistics-and-data/geography/our-products/scottish-postcode-directory/2023-2

https://www.nrscotland.gov.uk/statistics-and-data/statistics/statistics-by-theme/population/population-estimates/small-area-population-estimates-2011-data-zone-based/mid-2021

Exports a CSV file with datazones and retail outlet densities

R Tidyverse

##### alcohol_data_2023.R

Uses CSV data sourced from the Police Scotland InnKeepers Database

Uses NRS data:

https://www.nrscotland.gov.uk/statistics-and-data/geography/our-products/scottish-postcode-directory/2023-2

Exports a CSV file with datazones and retail outlet counts

R Tidyverse

##### alcohol_data_densities.R

Use CSV data from alcohol_data_2023.R

Uses NRS data:

https://www.nrscotland.gov.uk/statistics-and-data/statistics/statistics-by-theme/population/population-estimates/small-area-population-estimates-2011-data-zone-based/mid-2021

Exports a CSV file with datazones and retail outlet densities

R Tidyverse

##### Datazones_TimeSeriesData.R

Uses CSV data from alcohol_data_densities.R and tobacco_data_2023.R

Uses CSV Data from existing 'master' CRESHMap data file

Exports a CSV with five new columns for NRS 2021 datazone populations, alcohol densities (3 types), and tobacco 2023 densities, added to the 'master' CRESHMap data file

R Tidyverse

##### gambling_data_2023.R

Uses CSV data sourced from the Gambling Commission public regisrer of gambling premises:

https://www.gamblingcommission.gov.uk/public-register/premises

Uses NRS data:

https://www.nrscotland.gov.uk/statistics-and-data/geography/our-products/scottish-postcode-directory/2023-2

https://www.nrscotland.gov.uk/statistics-and-data/statistics/statistics-by-theme/population/population-estimates/small-area-population-estimates-2011-data-zone-based/mid-2021

Exports a CSV file with datazones and retail outlet densities

R Tidyverse

##### Datazones_TimeSeriesData_2.R

Uses CSV data from gambling_data_2023.R

Uses CSV Data from existing 'master' CRESHMap data file

Exports a CSV with one new columns for gambling 2023 densities, added to the 'master' CRESHMap data file

R Tidyverse