# Econ_Faculty_Scrapper</br>

### A Web Scraping Task to collect detailed information on faculty members from selected departments with a PhD in Economics.</br>
</br>
<div align="justify">

The study aims to collect data from websites of select departments of economics, namely, Economics faculty from She Research Network in India ([SheRNI](https://sherni.inflibnet.ac.in/)) database and Economics department at Indian Institute of Management Ahmedabad ([IIM-A](https://www.iima.ac.in/)). The intended information to be extracted, wherever applicable, were of individual scholars and members of the forementioned departments' personal academic and professional attributes.</br>
* Name of the faculty member
* Department/University affiliation
* Educational background and subject studied
* Institution where they obtained their degree(s)
* Year of obtaining the degree(s)
* Current position/designation
* Any additional information that might be relevant (like research interests, publications, etc.)</br>

The data was requested by web scrapping with R programming language utilising libraries [``rvest``](https://rvest.tidyverse.org/) and [``RSelenium``](https://cran.r-project.org/web/packages/RSelenium/index.html) and was cleaned using [``stingr``](https://stringr.tidyverse.org/) package. ``rvest`` and ``RSelenium`` were used interchangeably depending upon the accessiblilty demand of the webpages to be sourced- conditional to web-elements interaction and if the webpages were either static or dynamic in nature. The objective is to organize the extracted data into a matrix format that can be easily analyzed using statistical software and store the extracted data in a CSV file with appropriate column names.</br>
</div>

<div align="justify">

### High-Level Overview:</br>

1. #### ``SheRNI``
    - [``SheRNI_Master_Scrapper.R``](SheRNI/SheRNI_Master_Scrapper.R)</br>
      
      This module acts as the master run, which summons the auxiliary modules to collect links of individuals of interest and then run those links to retrieve their academic and professional attributes, which is done by calling ``SheRNI_Links_Scrapper`` and ``SheRNI_Profiles_Scrapper`` modules. This inputs the main homepage of SheRNI's database to filter researchers and outputs a [<i>data.frame</i>](SheRNI/Output/faculty_profile_links.Rda) with educational / research attributes stipulated to be scrapped.</br>
    
    - [``SheRNI_Links_Scrapper.R``](SheRNI/SheRNI_Links_Scrapper.R)</br>

      This module opens the SheRNI webpage, passes the appropriate filters to derive the target faculty members and retrieves each individuals' profile page's link from the generated search results.</br>

    - [``SheRNI_Profiles_Scrapper.R``](SheRNI/SheRNI_Profiles_Scrapper.R)</br>
    
       This module loads all the individual profiles' links gathered previously through ``SheRNI_Links_Scrapper`` and retrieves the researchers' academic and research attributes of interest.</br>
    
    - [``Output``](SheRNI/Output)</br>

      This folder has the outputs of ``SheRNI_Master_Scrapper.R``. [``faculty_profile_links.csv``](SheRNI/Output/faculty_profile_links.csv) is the resultant return of running ``SheRNI_Links_Scrapper.R`` and [``Researchers_Profiles.csv``](SheRNI/Output/Researchers_Profiles.csv) is the final output of ``SheRNI_Profiles_Scrapper.R``.</br>

   ##### Run order:</br>
   
   ````
   SheRNI_Master_Scrapper.R -> SheRNI_Links_Scrapper.R -> SheRNI_Profiles_Scrapper.R
   ````
   
   <div align="justify">

