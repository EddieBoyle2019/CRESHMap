# Python script for web scraping all registered tobacco retailers in Scotland based on the register hosted here:
# https://www.tobaccoregisterscotland.org/

##Import required libraries
import requests
from bs4 import BeautifulSoup
import os
import csv
from datetime import datetime

print("Program started at {}".format(datetime.now().strftime("%H:%M:%S %m/%d/%Y")))

#Sort out file saving and other bits 
#First create the headers we need
headers = ['Date of Query', 'Time of Query', 'Name', 'Address', 'Postcode', 'Local Authority', 'Type', 'Products Sold', 'Company Name', 'Status']

#Then the filename and path
file = "TobaccoRegister_{}.csv".format(datetime.now().strftime("%m-%d-%Y"))

#Then create the blank file with the column headers
with open(file, "w", encoding='utf-8', newline='') as filename:
    our_writer = csv.writer(filename, delimiter = "|", lineterminator=os.linesep)
    our_writer.writerow(headers)

#Collect the total results on the page
#First do an initial beautiful soup search before the loop to pull the page
URL = 'https://www.tobaccoregisterscotland.org/search-the-register/?\
Name=\
&Postcode=\
&LocalAuthority=\
&BusinessType=\
&ProductType=\
&PremisesStatus=\
&page=1'
page = requests.get(URL)
soup = BeautifulSoup(page.content, 'html.parser')
total_results = int(soup.find('div', attrs={'class':'premises-search-results__total'}).get_text().split()[3])

#now start the loop
for PageNumber in range(1,int(total_results/20)+2):
    #Specify the URL we want to scrape
    URL = 'https://www.tobaccoregisterscotland.org/search-the-register/?\
    Name=\
    &Postcode=\
    &LocalAuthority=\
    &BusinessType=\
    &ProductType=\
    &PremisesStatus=\
    &page={}'\
    .format(PageNumber)

    #Retrieve the contents of that URL
    page = requests.get(URL)

    #Take this content and turn it into a beautiful soup object
    soup = BeautifulSoup(page.content, 'html.parser')

    #Find all of the 'dd' html tags and place in a list called 'items'
    items = soup.find_all('dd')

    #Remove all of the HTML codes from the items
    cleaned_items = []
    for item in items:
        cleaned_items.append(item.contents[0])

    #Obtain the missing premises names 
    premise_names = []
    for item in soup.find_all('b'):
        premise_names.append(item.contents[0])

    #Create separate lists for each of the remaining fields
    statuses = cleaned_items[5::6]
    addresses = cleaned_items[0::6]
    local_authorities = cleaned_items[1::6]
    types = cleaned_items[2::6]
    products_solds = cleaned_items[3::6]
    company_names = cleaned_items[4::6]

    #And query dates and times
    date = [datetime.now().strftime("%m/%d/%Y")] * int(len(items)/6)
    time = [datetime.now().strftime("%H:%M:%S")] * int(len(items)/6)

    #Do the same for the postcodes by extracting from the address field
    postcodes = []
    for address in addresses:
        postcodes.append(' '.join(address.split()[-2:]))

    #Combine the lists into a "zip" object in preparation for writing to a CSV
    rows = zip(date, time, premise_names, addresses, postcodes, local_authorities, types, products_solds, company_names, statuses)

    #Append the rows to the bottom of our csv
    with open(file, "a", encoding='utf-8', newline='') as filename:
        writer = csv.writer(filename, delimiter ='|', lineterminator=os.linesep)
        for row in rows:
            writer.writerow(row)
            
    print("Page {} completed".format(PageNumber))

#Print completion statement
print("Scrape completed at {}. All {} pages scraped.".format(datetime.now().strftime("%H:%M:%S %m/%d/%Y"), total_results))