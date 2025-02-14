# 🏆 Web-Scraping-Data-Analytics-on-Microbiome-Research 

## 📌 Project Overview  
This project **automates web scraping** to extract and analyze **scientific article metadata** from the **Microbiome Journal**. By leveraging **R**, we uncover **trends in research focus, authorship, and keyword usage**, providing **data-driven insights** into microbiome-related studies.  

## 🎯 Key Contributions  
✅ **Automated Web Scraping** using `rvest`  
✅ **Data Cleaning & Structuring** for analysis  
✅ **Trend Analysis on Research Topics & Authors**  
✅ **Data Visualization with `ggplot2`**  

## 🛠 Tech Stack  
🔹 **Language**: R 🟦  
🔹 **Libraries**: `rvest`, `dplyr`, `ggplot2`, `lubridate`  

## 🔬 Methodology  

### 1️⃣ Web Scraping Process  
- **Access website structure & extract HTML content**  
- **Parse & clean extracted data** for analysis  

### 2️⃣ Identifying Target Volumes  
- Extracts **year-specific journal volumes** using **regular expressions**  
- Matches the **target year** to fetch relevant data  

### 3️⃣ Scraping Article Metadata  
- Extracts **article titles, authors, and links** using **XPath & HTML queries**  
- Structures the data in a **clean data frame**  

### 4️⃣ Handling Pagination  
- Dynamically constructs **URLs across multiple pages**  
- Stops when **no ‘Next Page’ link exists**  

### 5️⃣ Data Cleaning & Enrichment  
- Standardizes **author names, titles, and metadata**  
- Fetches **abstracts, keywords, publication dates, & corresponding authors**  

## 📊 Data Insights  

### 🔹 **Most Frequent Keywords (2022 & 2023)**  
📈 **Visualization 1**: Analyzing **top keywords** used in microbiome research  

### 🔹 **Top 10 Authors by Paper Count**  
📉 **Visualization 2**: Identifying leading researchers in the microbiome field  

## 📌 Results  
📊 **Key Takeaways:**  
- **Emerging Trends:** Research focus has shifted towards [Insert Key Trend].  
- **Most Cited Authors:** [Insert Notable Authors] contributed the most publications.  
- **Keyword Evolution:** Increase in topics related to [Insert Observation].  

## 📡 Future Scope  
🚀 **Expand web scraping to multiple microbiome journals**  
📊 **Apply NLP for deeper text analysis on abstracts**  
📈 **Predict emerging research topics using time-series models**  

## 💻 How to Run  

1️⃣ **Clone the repository:**  
```bash
git clone https://github.com/your-username/microbiome-data-analysis.git
```

2️⃣ **Install required R packages:**  
```r
install.packages(c("rvest", "dplyr", "ggplot2", "lubridate"))
```

3️⃣ **Run the script:**  
```r
source("scraper_script.R")
```

4️⃣ **View the results:**  
Extracted data is saved as `microbiome_data.csv`  
Visualizations are generated in `output/`  

💡 If you find this project insightful, ⭐ star the repo!

