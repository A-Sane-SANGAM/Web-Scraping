# install.packages("tidyverse")
# install.packages("rvest")
# install.packages("httr")
# install.packages("RSelenium")
# install.packages("lubridate")

library(tidyverse)
library(rvest)
library(httr)
library(RSelenium)
library(lubridate)


binman::list_versions("chromedriver")
con <- rsDriver(browser="chrome", port=4444L, chromever="87.0.4280.88" )
conDriver <- con[["client"]]

# KILLING A PROCESS ON A PORT IN CMD
# netstat -ano | findstr:4444
# Identify the PID which is in use.
# taskkill /PID <PID in use> /F


#Navigating a URL
conDriver$navigate("https://www.walmart.com/")
#Getting the navigated URL
conDriver$getCurrentUrl()
#Going back to the last URL
conDriver$goBack()
#Going to a forward URL if it exists
conDriver$goForward()
#Refreshing a URL
conDriver$refresh()

# SEARCHING ELEMENTS ON A WEB PAGE ****************************************************************
#Searching element by name
searchbox_ByName <- conDriver$findElement(using = "name",value = "query")
#Searching element by class
searchbox_ByClass <- conDriver$findElement(using = "class",value = "header-GlobalSearch-input")
#Searching element by ID
searchbox_ByID <- conDriver$findElement(using = "id",value = "global-search-input")
#Searching element by CSS Selector
searchbox_By_CSS_Selector1 <- conDriver$findElement(using = "css", "[name='query']")
searchbox_By_CSS_Selector2 <- conDriver$findElement(using = "css", "[class='header-GlobalSearch-input']")
searchbox_By_CSS_Selector3 <- conDriver$findElement(using = "css", "[id='global-search-input']")
#Searching element by xpath
searchbox_By_XPath1 <- conDriver$findElement(using = "xpath","//*[@id='global-search-input']")
searchbox_By_XPath2 <- conDriver$findElement(using = "xpath","//*[@class='header-GlobalSearch-input']")
searchbox_By_XPath1$getElementAttribute("class")

# SENDING EVENTS TO ELEMENTS  *********************************************************************
#Sending a string to the search box element and hit enter
searchbox_ByName$sendKeysToElement(list("5-hour ENERGY Shot, Extra Strength, Grape, 1.93 oz","enter"))
#This will give u the list of keys available for use.
View(selKeys)










