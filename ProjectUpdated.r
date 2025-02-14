# ===================================================
# R Script for Scraping Articles from Microbiome Journal
# Author: Kunal Sharma, Ananya Jaikumar
# Description: This script scrapes article data from the Microbiome Journal for a specified year,
#              cleans the data, and generates visualizations of keywords and authors.
# ===================================================

# ===================================================
# Set Working Directory
# ===================================================
setwd("/Users/ananyajaikumar/Desktop/Data Analytics/Data Analytics Project")  # Set the working directory to your desired path

# ===================================================
# Required Packages
# ===================================================
# Uncomment the following lines to install the necessary packages if they are not already installed
# install.packages("rvest")
# install.packages("ggplot2")
# install.packages("lubridate")
# install.packages("dplyr")

# ===================================================
# Load Libraries
# ===================================================
library(rvest)      # For web scraping
library(ggplot2)    # For data visualization
library(lubridate)  # For date manipulation
library(dplyr)      # For data manipulation

# ===================================================
# Specify the Target Year for Scraping
# ===================================================
target_year <- 2024  # Change this to the desired year for analysis

# ===================================================
# Base URLs for the Microbiome Journal
# ===================================================
base_url <- "https://microbiomejournal.biomedcentral.com"
base_url_articles <- "https://microbiomejournal.biomedcentral.com/articles"

# ===================================================
# Get the List of Volumes and Years from the Articles Page
# ===================================================
document <- read_html(base_url_articles)

# Extract Volume Numbers and Corresponding Years
volume_numbers <- document %>%
  html_nodes("#volume-from > option") %>%
  html_text() %>%
  gsub("Volume (\\d+) \\(\\d+\\)", "\\1", .) %>%
  as.numeric() %>%
  na.omit()

volume_years <- document %>%
  html_nodes("#volume-from > option") %>%
  html_text() %>%
  gsub("Volume \\d+ \\((\\d+)\\)", "\\1", .) %>%
  as.numeric() %>%
  na.omit()

# Combine Volume Numbers and Years into a Data Frame
volume_df <- data.frame(
  volume_numbers = volume_numbers,
  volume_years = volume_years
)

# Find the Volume Corresponding to the Target Year
target_volume <- volume_df$volume_numbers[volume_df$volume_years == target_year]
if (length(target_volume) == 0) {
  stop("No articles found for the specified year.")
}

# Construct the URL for the Target Volume
target_url <- paste0(base_url, "/articles?query=&searchType=&tab=keyword&volume=", target_volume)

# ===================================================
# Function to Scrape Article Details from a Specific Page URL
# ===================================================
scrape_page <- function(url) {
  webpage <- read_html(url)
  title <- webpage %>% html_nodes(".c-listing__title") %>% html_text()
  authors <- webpage %>% html_nodes(".c-listing__authors") %>% html_text()
  link <- webpage %>% html_nodes(xpath = '//*/a[@data-test="title-link"]') %>% html_attr("href")
  
  # Create a Data Frame to Store the Scraped Data
  article_data <- data.frame(
    Title = title,
    Authors = authors,
    Link = link,
    stringsAsFactors = FALSE
  )
  return(article_data)
}

# ===================================================
# Loop Through Paginated Pages to Collect All Articles for the Specified Volume
# ===================================================
page_link <- paste0("/articles?query=&searchType=&tab=keyword&volume=", target_volume, "&page=1")
all_data <- data.frame()  # Initialize an empty data frame to store all articles

while(TRUE) {
  url <- paste0(base_url, page_link)  # Construct the full URL
  page_data <- scrape_page(url)        # Scrape data from the current page
  all_data <- rbind(all_data, page_data)  # Append the scraped data
  
  # Check for the next page link
  webpage <- read_html(url)
  page_link <- webpage %>% html_node("li.c-pagination__item a[data-test='next-page']") %>% html_attr("href")
  
  # Break the loop if there are no more pages
  next_page_disabled <- webpage %>% html_nodes(xpath = '//*[@class="c-pagination__item"]/span[@data-test="next-page-disabled"]')
  if(length(next_page_disabled) == 1) {
    break
  }
}

# ===================================================
# Data Cleaning Functions
# ===================================================
# Function to Clean and Format the Authors' Names
clean_authors <- function(author_string) {
  author_string <- trimws(author_string)
  author_string <- gsub("Authors:|\\n", "", author_string)  # Remove unwanted text
  author_string <- gsub(" and", ",", author_string)          # Replace "and" with ","
  author_string <- trimws(author_string)
  authors <- strsplit(author_string, ", ")                    # Split authors into a list
  return(authors)
}

# Function to Clean and Format the Article Titles
clean_title <- function(title_string) {
  title_string <- trimws(title_string)
  title_string <- gsub("\\n", "", title_string)  # Remove newline characters
  title_string <- trimws(title_string)
  return(title_string)
}

# ===================================================
# Apply Cleaning Functions to the Scraped Data
# ===================================================
all_data$Authors <- lapply(all_data$Authors, clean_authors)
all_data$Title <- lapply(all_data$Title, clean_title)
all_data$Link <- paste0(base_url, all_data$Link)  # Construct full links to articles

# ===================================================
# Function to Extract Additional Details from Individual Articles
# ===================================================
extract_article_data <- function(url) {
  document <- read_html(url)
  abstract <- document %>% html_node(xpath = "//div[@class='c-article-section__content']/p") %>% html_text()
  
  # Extract keywords
  keywords_doc <- list(document %>% html_nodes(".c-article-subject-list__subject") %>% sapply(html_text, simplify = TRUE))
  keywords <- ifelse(length(keywords_doc) != 0, keywords_doc, NA)
  keywords <- gsub("[\n[:space:]]+|[\\\\n[:space:]]+", " ", keywords)
  
  # Extract publish date
  publish_date_doc <- document %>% html_node(xpath = "//p[contains(text(), 'Published')]/span/time") %>% html_text()
  publish_date <- ifelse(length(publish_date_doc) != 0, publish_date_doc, NA)
  
  
  # Scrape corresponding author(s)
  corresponding_authors <- document %>% html_nodes(xpath = "//p[@id='corresponding-author-list']/a") %>% html_text(trim=TRUE)
  corresponding_authors_emails <- document %>% html_nodes(xpath = "//p[@id='corresponding-author-list']/a") %>% html_attr("href")
  
  # Extract the emails
  emails <- gsub("mailto:", "", corresponding_authors_emails)
  corresponding_authors <- paste(corresponding_authors, collapse = ", ")
  emails <- paste(emails, collapse = ", ")
  
  return(list(
    abstract = abstract,
    keywords = paste(keywords, collapse = ", "),
    publish_date = publish_date,
    corresponding_authors = corresponding_authors,
    emails = emails
  ))
}

# ===================================================
# Append Additional Article Data and Remove the Link Column
# ===================================================
article_data <- lapply(all_data$Link, extract_article_data)
article_df <- as.data.frame(do.call(rbind, article_data))  # Combine the list into a data frame
all_data <- cbind(all_data, article_df)  # Merge with the main data frame
all_data$Link <- NULL  # Remove Link column as it's no longer needed

# ===================================================
# Convert List Columns to Strings for Writing to CSV
# ===================================================
df <- all_data
df$Title <- sapply(df$Title, function(x) if(length(x) > 0) paste(x, collapse = ", ") else "")
df$Authors <- sapply(df$Authors, function(x) if(length(x) > 0) paste(x, collapse = ", ") else "")
df$abstract <- sapply(df$abstract, function(x) if(length(x) > 0) paste(x, collapse = ", ") else "")
df$keywords <- sapply(df$keywords, function(x) if(length(x) > 0) paste(x, collapse = ", ") else "")
df$publish_date <- sapply(df$publish_date, function(x) if(length(x) > 0) paste(x, collapse = ", ") else "")
df$corresponding_authors <- sapply(df$corresponding_authors, function(x) if(length(x) > 0) paste(x, collapse = ", ") else "")
df$emails <- sapply(df$emails, function(x) if(length(x) > 0) paste(x, collapse = ", ") else "")

# Convert publish_date to Date type for better handling
df$ publish_date <- as.Date(df$publish_date, format="%d %B %Y")

# ===================================================
# Write the Cleaned Data to a CSV File
# ===================================================
output_filename <- paste0("articles_data_", target_year, ".csv")
write.csv(df, output_filename, row.names = FALSE)  # Save the data frame to a CSV file
cat("Data written to:", output_filename, "\n")  # Print confirmation message

# ===================================================
# Data Visualization
# ===================================================
# Plot 1: Most Frequent Keywords
# Function to extract values within double quotes from a string
extract_keywords <- function(keyword_string) {
  keywords <- unlist(regmatches(keyword_string, gregexpr("\"([^\"]*)\"", keyword_string)))  # Extract keywords
  return(keywords)
}

# Create a table of keyword frequencies
extracted_keywords <- table(unlist(lapply(all_data$keywords, extract_keywords)))

# Converting the table to a data frame for easier manipulation
keyword_freq_df <- data.frame(keyword = names(extracted_keywords),
                              frequency = as.numeric(extracted_keywords))

# Group the data by keyword and summarize the total frequency
keyword_freq_df_final <- keyword_freq_df %>% group_by(keyword) %>% summarize(Total_frequency = sum(frequency))

# Sorting keywords by their total frequency in descending order
keyword_freq_df_final <- keyword_freq_df_final[order(-keyword_freq_df_final$Total_frequency), ]
head(keyword_freq_df_final)  # Display the top keywords

# Taking top N keywords (e.g., top 10) for visualization
top_n_keywords <- keyword_freq_df_final[1:10, ]

# Creating a bar plot for the top 10 keywords
ggplot(top_n_keywords, aes(x = reorder(keyword, -Total_frequency), y = Total_frequency)) +
  geom_bar(stat = "identity", fill = "lightblue") +
  labs(title = "Top 10 Keywords in Scraped Articles",
       x = "Keyword",
       y = "Frequency") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for better readability

# Plot 2: Top 10 Authors by Paper Count in the Target Year
# Flatten the list of authors into a single vector
all_authors <- unlist(lapply(all_data$Authors, function(x) unlist(x)))
authors_df <- data.frame(table(all_authors))  # Create a frequency table of authors
authors_df <- authors_df[order(-authors_df$Freq), ]  # Sort authors by frequency

# Select the top authors for visualization
top_authors <- head(authors_df, 10)

# Creating a bar plot for the top 10 authors
ggplot(top_authors, aes(x = reorder(all_authors, Freq), y = Freq)) +
  geom_bar(stat = "identity", fill = "lightcoral") +
  labs(title = paste("Top 10 Authors by Paper Count in", target_year), 
       x = "Author", 
       y = "Number of Papers") +
  theme_minimal() +
  coord_flip()  # Flip coordinates for better readability

# ===================================================
# End of Script
# ===================================================