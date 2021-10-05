#######################################
#######################################
#   This is a source template for     #
#   setting up a Google Analytics     #
#         analysis document           #
#    ***************************      #
#  By Ben Woodard - SEARCH DISCOVERY  #
#######################################
#######################################

## Load common packages if run interactively
library(tidyverse)
library(lubridate)
library(scales)
library(googleAuthR)
library(googleAnalyticsR)

## Setup your authorization
## there are several ways to get auhtorization.  
#Here I'm using the "Your own Google Project" method for authorization 
options(googleAuthR.client_id = Sys.getenv('GA_CLIENT_ID'))
options(googleAuthR.client_secret = Sys.getenv('GA_CLIENT_SECRET'))

# Authorize Google Analytics the first time you run this
gar_auth(email = 'ben.woodard@searchdiscovery.com')

## get your accounts
account_list <- ga_account_list()

## Identify the account you are wanting to reference going forward
sdi_ga <- account_list %>% filter(grepl('209473*', viewId, ignore.case = T))

    ## Account ID
    accountid <- sdi_ga %>% pull(accountId)
    
    ## Web Property Id
    wpid <-	sdi_ga %>% pull(webPropertyId)
    
    ## View account_list and pick the viewId you want to extract data from
    vid <- sdi_ga %>% pull(viewId)

## Get all the dimensions and metrics available 
meta <- ga_meta(version = 'universal')

    ## Separate the dimensions and metrics for easier referencing
    dims = meta %>% filter(type == 'DIMENSION')
    mets = meta %>% filter(type == "METRIC")
    
    ### Remove meta after splitting up the metrics and dimensions
    rm(meta)
    
    ## Get the custom dimensions
    cust_dims <- ga_custom_vars_list(accountId = accountid, 
                                     webPropertyId = wpid, 
                                     type = "customDimensions")
    
    ## Get the custom metrics
    cust_mets <- ga_custom_vars_list(accountId = accountid, 
                                     webPropertyId = wpid, 
                                     type =  "customMetrics")
    
    ## Get the segments
    segments <- ga_segment_list()


