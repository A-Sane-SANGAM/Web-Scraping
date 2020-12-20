library(tidyverse)
library(rvest)
library(httr)
library(RSelenium)
library(lubridate)
library(stringr)

#Requesting a connection
binman::list_versions("chromedriver")
con <- rsDriver(browser="chrome", port=4444L, chromever="87.0.4280.88")
conDriver <- con[["client"]]

#Getting the list of products
product_df <- read.csv("product_list.csv")

#Navigating the website
conDriver$navigate("https://www.walmart.com/")
Sys.sleep(15)


getProductAttributes <- function(title){
      
    #Searching for the product on the website
    searchbox_ByName <- conDriver$findElement(using = "name",value = "query")
    searchbox_ByName$sendKeysToElement(list(title,key="enter"))
    Sys.sleep(10)
    
    #Scraping product attributes from the results page
    search_result_text <- conDriver$findElements(using = "xpath", value = "//*[@id='searchProductResult']/ul/li | //*[@id='searchProductResult']/div/div")
    temp1 <- list()
    i<-1
    while (i<=length(search_result_text)) {
        content <- search_result_text[[i]]
        temp1[i] <- content$getElementText()
        i<-i+1
    }
    
    #Scraping the links for the corresponding products
    search_result_links <- conDriver$findElements(using = "class", value = "product-title-link")
    temp2 <- list()
    i<-1
    while (i<=length(search_result_text)) {
      link <- search_result_links[[i]]
      temp2[i] <- link$getElementAttribute("href")
      i<-i+1
    }
    
    #Appending the product data into product data frame
    temp3 <- data.frame(unlist(temp1),unlist(temp2))
    colnames(temp3) <- c('content','link')
    #Removing the sponsored product
    temp3 <- temp3[!grepl("Sponsored Product", temp3$content),]
    #Keeping only those products where title is present
    temp3 <- temp3[grepl("Product Title", temp3$content),]
    temp3$title <- to_search
    temp3 <- temp3[,c(3,1,2)]
    
    
    #Going back to home page
    conDriver$goBack()
    Sys.sleep(10)
    
    return (temp3)

}

#Creating a data frame to store all product attributes
product_df_final <- data.frame(matrix(ncol = 3))
colnames(product_df_final) <- c("title","content","link")


for(k in 1:nrow(product_df)){
  to_search <- product_df[k,]
  temp4 <- getProductAttributes(to_search)
  product_df_final <- rbind(product_df_final,temp4)
}

#Removing top row from the final product table
product_df_final <- product_df_final[-1,]


#Extracting Product Attributes
temp5 <- product_df_final
temp5$content <- gsub(pattern = "[[:space:]]+",replacement = "",x = temp5$content)
temp5$content <- tolower(temp5$content)
#Extracting Product Name
temp5$Product_Name <- regmatches(temp5$content, gregexpr(pattern = "producttitle.*averagerating",text = temp5$content)) 
temp5$Product_Name <- gsub(pattern = c("producttitle|averagerating"),replacement = "",x = temp5$Product_Name)
#Extracting Product Price
temp5$Price <- gsub("\\$", "CP", temp5$content)
temp5$Price <- regmatches(temp5$Price, gregexpr(pattern = "currentpriceCP.*CP",text = temp5$Price))
temp5$Price <- gsub('^([^CP]+CP[^CP]+).*', '\\1', temp5$Price)
temp5$Price <- gsub(pattern = "currentpriceCP",replacement = "",x = temp5$Price)
#Extracting Stars
temp5$stars <- regmatches(temp5$content, gregexpr(pattern = "averagerating.*stars",text = temp5$content))
temp5$stars <- gsub(pattern = c("averagerating:|outof5stars"),replacement = "",x = temp5$stars)
temp5$stars <- gsub(pattern = "[()]",replacement = "",x = temp5$stars)
temp5$stars <- as.numeric(temp5$stars)
#Extracting Reviews
temp5$reviews <- regmatches(temp5$content, gregexpr(pattern = "basedon.*reviews",text = temp5$content))
temp5$reviews <- gsub(pattern = "basedon|reviews",replacement = "",x = temp5$reviews)
temp5$reviews <- as.numeric(temp5$reviews)
temp5$reviews[is.na(temp5$reviews)] <- 0

write.csv(temp5,"WalmartProductData.csv")


# # OTHER CODES **********************************************************************************
# 
# # KILLING A PROCESS ON A PORT IN CMD
# # netstat -ano | findstr :4444
# # Identify the PID which is in use.
# # taskkill /PID <PID in use> /F
# 
# #This will give u the list of keys available for use.
# View(selKeys)
# 
# #Navigating a URL
# conDriver$navigate("https://www.walmart.com/")
# #Getting the navigated URL
# conDriver$getCurrentUrl()
# #Going back to the last URL
# conDriver$goBack()
# #Going to a forward URL if it exists
# conDriver$goForward()
# #Refreshing a URL
# conDriver$refresh()
# 
# # SEARCHING ELEMENTS ON A WEB PAGE ****************************************************************
# #Searching element by name
# searchbox_ByName <- conDriver$findElement(using = "name",value = "query")
# #Searching element by class
# searchbox_ByClass <- conDriver$findElement(using = "class",value = "header-GlobalSearch-input")
# #Searching element by ID
# searchbox_ByID <- conDriver$findElement(using = "id",value = "global-search-input")
# #Searching element by CSS Selector
# searchbox_By_CSS_Selector1 <- conDriver$findElement(using = "css", "[name='query']")
# searchbox_By_CSS_Selector2 <- conDriver$findElement(using = "css", "[class='header-GlobalSearch-input']")
# searchbox_By_CSS_Selector3 <- conDriver$findElement(using = "css", "[id='global-search-input']")
# #Searching element by xpath
# searchbox_By_XPath1 <- conDriver$findElement(using = "xpath","//*[@id='global-search-input']")
# searchbox_By_XPath2 <- conDriver$findElement(using = "xpath","//*[@class='header-GlobalSearch-input']")
# searchbox_By_XPath1$getElementAttribute("class")
# 
#
# #PRODUCT TITLE
# product_title <- conDriver$findElement(using = "class", value = "prod-ProductTitle")
# a$title <- product_title$getElementText()
# #WALMART SKU
# product_item_number <- conDriver$findElement(using = "class", value = "wm-item-number")
# a$sku <- product_item_number$getElementText()
# #PRODUCT PRICE
# product_price <- conDriver$findElement(using = "class", value = "price-group")
# a$price <-product_price$getElementText()
# #PRODUCT STARS
# product_star_rating <- conDriver$findElement(using = "xpath", value = "//*[@id='product-overview']/div/div[3]/div/div[1]/div[1]/div/button/span/span[1]")
# a$stars <- product_star_rating$getElementText()
# #PRODUCT REVIEWS
# product_reviews <- conDriver$findElement(using = "class", value = "stars-reviews-count-node")
# a$reviews <- product_reviews$getElementText()
# #PRODUCT DESCRIPTION
# product_description <- conDriver$findElement(using = "class", value = "about-product-description")
# a$description <- product_description$getElementText()















