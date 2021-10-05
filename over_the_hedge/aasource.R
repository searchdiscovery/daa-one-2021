#######################################
#######################################
#    This is a source template for    #
#    setting up a Adobe Analytics     #
#         analysis document           #
#    ***************************      #
#  By Ben Woodard - SEARCH DISCOVERY  #
#######################################
#######################################

## Load common packages if run interactively
library(tidyverse)
library(lubridate)
library(scales)
library(adobeanalyticsr)

## Setup your authorization by including these in your .Renviron file
# Adobe Analytics 2.0 Creds
# AW_CLIENT_ID={client_id_string} <- insert your own client id
# AW_CLIENT_SECRET={client_secret_string} <- insert your own client secret
## Once added and saved to .Renviron, restart the R session

# Authorize Google Analytics the first time you run this
aw_token()

# copy then paste the authorization token after logging into Adobe
# into the Console and press enter

# Get your Company Id and add it to the .Renviron file
get_me() 

# AW_COMPANY_ID={company_id}  <- insert the 'globalCompanyId' from the get_me() result
## Once added and saved to .Renviron, restart the R session and reload the packages

## identify the report suite id needed for the data pull
rsids <- aw_get_reportsuites(limit = 1000)

rsids %>% filter(grepl('SDI Website 2020 Production', name)) %>% pull(id)

# Optional is to add report suite id to the global environment
# AW_REPORTSUITE_ID={reportsuite_id} <- insert report suite id

## Get all the dimensions and metrics available 
dims = aw_get_dimensions()
mets = aw_get_metrics()


## Get the calculated metrics
calc_mets <- aw_get_calculatedmetrics(limit = 1000)

## Get the segments
segments <- aw_get_segments(limit = 1000)


