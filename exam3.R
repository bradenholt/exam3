# clear environ
rm(list = ls(all = TRUE))

# setwd
setwd("C:/Users/Braden/Documents/Data Science/Exam 3")

# libraries
library(rio)
library(bit64)
library(tidyverse)
library(data.table)
library(WDI)
library(plm)
library(countrycode)
library(googlesheets4)
library(labelled)
library(varhandle)
library(ggrepel)
library(geosphere)
library(sp)
library(rgeos)
library(viridisLite)
library(viridis)
library(usethis)
library(mapview)
library(rnaturalearth)
library(rnaturalearthdata)
library(devtools)
library(rnaturalearthhires)
library(raster)
library(sf)
library(Imap)
library(ggsflabel)
library(remotes)
library(raster)
library(Rcpp)
library(shiny)
library(tidycensus)
library(XML)
library(rvest)
library(dplyr)
library(ggplot2)
library(lubridate)
library(janeaustenr)
library(stringr)
library(tidyr)
library(pdftools)
library(gutenbergr)
library(knitr)
library(ggplot2)
library(dplyr)
library(tidytext)
library(scales)
library(wordcloud)
library(topicmodels)
library(readr)


# import Gini index variable

v10 <- get_acs(geography = "state", 
               variables = c(poverty = c("B06012_002",
                            year = 2010&2015)))

v15 <- get_acs(geography = "state", 
               variables = c(poverty = c("B06012_002",
                                         year = 2010)))

# single panel dataset
inequality_panel <- left_join(v10, v15, by = "NAME")

# change name
setnames(inequality_panel,"estimate.x", 'gini')
setnames(inequality_panel, "estimate.y", "gini")
setnames(inequality_panel, "NAME", "state")

# add year
inequality_panel$variable.x <- 2010
inequality_panel$variable.y <- 2015
setnames(inequality_panel, "variable.x", "2010", skip_absent = TRUE)
setnames(inequality_panel, "variable.y", "2015")

# run head
head(inequality_panel)

# wide format
inequality_wide <- 
  inequality_panel %>% 
  pivot_wider(id_cols = c("2010","2015","GEOID.x","GEOID.y"),
              names_from = "state",
              values_from = "gini") 

# long format
inequality_long <- 
  inequality_panel %>% 
  pivot_longer(cols = )

# collapse data
inequality_collapsed <- 
  inequality_panel %>% 
  group_by(state, gini) %>% 
  summarize(across(where(is.numeric), sum))

# WDI package
gdp_current <- WDI(country = 'all', 
                    indicator = 'NY.GDP.DEFL.ZS',
                    start = 2006,
                    end = 2007,
                    extra = FALSE,
                    cache = NULL)

# Deflate GDP
usd.deflator <- 
  WDI(country = 'USA', 
      indicator = 'NY.GDP.DEFL.ZS',
      start = 2015,
      end = 2015,
      extra = FALSE,
      cache = NULL)

# remove unnecessary stuff
gdp_current$iso2c <- NULL
gdp_current$country <- NULL

# gdp deflated
gdp_deflated <- left_join(gdp_current,usd.deflator,
                          by = c("year"))

# pull PDF file
armeniatext <- pdf_text(pdf = "https://pdf.usaid.gov/pdf_docs/PA00TNMG.pdf")

# convert to df
armeniatext <- as.data.frame(armeniatext, stringAsFactors = FALSE)
colnames(armeniatext)[which(names(armeniatext) == "armeniatext")] <- "text" # change column name

# tokenize
armeniatext <- armeniatext %>% 
  unnest_tokens(word, text) %>%
  anti_join(stop_words)

# count words
freq <- armeniatext %>% 
  count(word, sort = TRUE)

head(freq, num = 5)

# hot 100 exam
hot100exam <- "https://www.billboard.com/charts/hot-100"
hot100exam <- read_html(hot100exam)

# identify nodes
body_nodes <- hot100exam %>% 
  html_node("body") %>% 
  html_children

# get data 
rank <- hot100exam %>% 
  rvest::html_nodes('body') %>% 
  xml2::xml_find_all("//span[contains(@class,
                     'chart-element__rank__number')]") %>% 
  rvest::html_text()

title <- hot100exam %>% 
  rvest::html_nodes('body') %>% 
  xml2::xml_find_all("//span[contains(@class,
                     'chart-element__information__song')]") %>%
  rvest::html_text()

artist <- hot100exam %>% 
  rvest::html_nodes('body') %>% 
  xml2::xml_find_all("//span[contains(@class,
                     'chart-element__information__artist')]") %>%
  rvest::html_text()

last_week <- hot100exam %>% 
  rvest::html_nodes('body') %>% 
  xml2::xml_find_all("//span[contains(@class,
                     'chart-element__meta text--center color--secondary text--last')]") %>%
  rvest::html_text() 

# put it all together
hot100exam_df <- data.frame(rank,last_week,artist,title)

