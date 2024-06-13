#' @title SheRNI_Links_Scrapper
#' @author: Guganesan Ilavarasan
#' @email: gi247@cam.ac.uk
#' @date: 12/06/2024 22:18
#' @param mainlink input (character)
#' @return links_df output (data.frame)
#' @importFrom netstat freeport()
#' @description
#' This module opens the SheRNI webpage, passes the appropriate filters to derive the target faculty members
#' and retrieves each individuals' profile page's link from the generated search results.

get_links <- function (mainlink){
#'* get_links <- function (mainlink,wordsearch)*{ [ An alternative function definition with parameteric provision to pass a word search as an argument.

library(RSelenium)
  
library(netstat) # This library helps to select random ports during each connection request thus reliving of static port errors.


#'* This initiates a server.*
remote_driver <- rsDriver(browser = "firefox", chromever = NULL, verbose = F, port = free_port())

#'* This creates a client object.*
remDr <- remote_driver$client

#'* This opens a new browser window.*
remDr$open()

#'* This maximises earlier opened browser window.*
remDr$maxWindowSize()

#'* This navigates to passed website through the main run module; SheRNI website in this instance.*
remDr$navigate(mainlink)

#'[ This finds Economics faculty members including that of inter-disciplinary expertise- Agricultural economics, Finance, Management, etc.
#'[ If you are using this search method, then please be sure to comment out lines28 through 35.
#'* search_box <- remDr$findElement(using = 'id', 'title')$sendKeysToElement(list(wordsearch, key = 'enter'))*

#'@_This_finds_Economics_faculty_members_specialising_in_Economics.

#'* This opens the 'Expertise' drop-down filter.*
expertise_open<-remDr$findElement(using = 'xpath', '//*[@id="accordion"]/div/div[1]/h2/a/i')
expertise_open$clickElement()

#'* This chooses the 'Economics' check box from the available options from drop-down filter.*
econ_filter<-remDr$findElement(using = 'xpath', '//*[@id="style-4"]/div/ul/li[29]/label')
econ_filter$clickElement()

#'* This submits the prior chosen option.*
submit_econ_filter<-remDr$findElement(using = 'xpath', '//*[@id="collapseOne"]/div/input')
submit_econ_filter$clickElement()

#'* This sorts the returned results by name, alphabetically.*
sort_by_name<-remDr$findElement(using = 'xpath', '//*[@id="sortfield"]/option[1]')
sort_by_name$clickElement()

#'* This chooses to display the maximum results per page.*
show_100_results<-remDr$findElement(using = 'xpath', '//*[@id="limits"]/option[4]')
show_100_results$clickElement()

#'* This creates an empty .CSV file to be populated with the gathered results.*
cat(NULL,file="faculty_profile_links.csv")

#'* This retrieves the total no. of pages for the passed filter values which later determines the no. of loops to persecute to get links of matching profiles.*
total_no_of_results<-remDr$findElement(using = 'xpath', '//li[(((count(preceding-sibling::*) + 1) = 12) and parent::*)]//*[(@id = "pagenos")]')$getElementText() %>% unlist()

n <- 0 #'[ This acts as a counter to discern to load the next page or not.

#'* This for-loop iterates across all resultant pages and retrieves individual scholars' profile's link.*
for (i in 1:as.numeric(total_no_of_results)) {
  
  #'[ This retrieves all profiles' links in that page.
  get_links <- remDr$findElements(using='class name', 'pink-women')
  all_links <- lapply(get_links, function (x) x$getElementAttribute("href")) %>% unlist()
  
  #'[ This loop transfers the gathered links, which is now in a list, into a global data frame, links_df.
  for (links in all_links){
    links_df <<- rbind(links_df,links)
  }
  
  #'@_This_writes_out_the_results_(links)_into_a_.CSV_file.
  write.table(all_links, "faculty_profile_links.csv", sep = ",", append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)
  
  n <- n + 1 #'[ The counter acts accumulative and increments by one which every iteration through the filters' results pages.
  
  #'[ This] *if* [clause prevents the non-existent] *'Next'* [button in the last page of results to be clicked, thus avoiding an error.
  if (n != as.numeric(total_no_of_results)){
    
    #'[ If the current page is not the last page, this chooses to load the next page of 100 results.
    nlinks<-remDr$findElement(using = 'link text', 'Next')$clickElement() 
  }
  
}

#'@_This_saves_the_'links_df'_data.frame_into_a_.Rda_file.
save(links_df,file="faculty_profile_links.Rda") 

#'* This closes the server.*
remote_driver$server$stop()

comment(all_links) <- "faculty_profile_links.csv: A review for duplicate profiles (links) is done visually through highlighting 
duplicate cells by conditional formatting in Excel (Home > Conditional Formatting > Highlight Cells Rules > Duplicate Values)."

}

#'@references https://github.com/ggSamoora/TutorialsBySamoora/blob/3cacfc7b902e8c81dd628789dc7a1100c6eb16c8/rate_my_professor_script.Rmd