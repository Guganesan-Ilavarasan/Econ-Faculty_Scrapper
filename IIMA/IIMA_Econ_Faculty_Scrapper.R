#' @title IIMA_Econ_Faculty_Scrapper
#' @author: Guganesan Ilavarasan
#' @email: gi247@cam.ac.uk
#' @date: 08/06/2024 19:28
#' @param url input (character)
#' @return faculty_profile output (data.frame)
#' @import stringr 
#' @description
#' This script loads the Indian Institute of Management, Ahmadabad economics faculty webpage and retrieves links to all its members' webpage.
#' The individual pages are then loaded to collect educational and research details of the members, which are collated into a data.frame.

library(rvest)

library(stringr) # This library is used to access str_squish() and str_remove() function to remove white spaces from results.

# This creates an empty data.frame for the result with assigned column names.
faculty_profile <- data.frame(Professor_Name = character(),
                              Role = character(),
                              Expertise = character(),
                              Previous_Education_1 = character(),
                              Previous_Education_2 = character(),
                              Previous_Education_3 = character(),
                              Previous_Education_4 = character(),
                              Previous_Education_5 = character(),
                              Email.ID = character(),
                              Website = character())

#'[ These three lines of code retrieves all Economics faculty members' pages' links.
url = "https://www.iima.ac.in/faculty-research/faculty-directory?field_primary_area_target_id=58"

page <- read_html(url)

faculty_links <- page %>% html_nodes(".faculty-card-box") %>% html_attr('href')

# start.time <- Sys.time() # Commented out as this was only for test purpose whilst debugging; however, could prove useful if desired.

#'[ This for-loop iterates through all the collected links to retrieve individual profile's attributes to populate the faculty_profile df.
for (links in faculty_links){
  
  profile_link <- paste("https://www.iima.ac.in", links, sep="")
  
  page <- read_html(profile_link)
  
  #'[ This retrieves Professor's name.
  prof_name = page %>% html_nodes(xpath='//*[@id="employee-banner-text"]/h3/span') %>% html_text()%>% str_remove('\r\n ') %>% 
    as.character() %>% str_squish()
  
  #'* print(prof_name) # Commented out as this was only for test purpose whilst debugging; however, could prove useful if desired.*
  
  #'[ This retrieves the Professor's designation.
  role = page %>% html_nodes(xpath='//*[@id="employee-banner-text"]/p') %>% html_text() %>% str_remove('\r\n ') %>% 
    as.character() %>% str_squish()
 
  # This condition is warranted when the professor holds multiple designations, thus needing to be associated together. 
  if (length(role) == 2){
    
    role <- paste(role[1], role[2], sep=" & ")
    
  }
  
  #'* print(role)  # Commented out as this was only for test purpose whilst debugging; however, could prove useful if desired.*
  
  #'[ This retrieves the professor's area of expertise.
  expertise = page %>% html_nodes(xpath='//*[@id="block-iima-content"]/section[3]/div/div/div/div[2]/div/div/p/text()') %>% html_text() %>% str_remove('\r\n ') %>% 
    as.character() %>% str_squish()
  
  if (length(expertise) == 0){
    
    expertise = page %>% html_nodes(xpath='//*[@id="block-iima-content"]/section[2]/div/div/div/div[2]/div/div/p/text()') %>% html_text() %>% str_remove('\r\n ') %>% 
      as.character() %>% str_squish()
    
  }
  
  comment(expertise) <- "Whilst mostly expertise indicates the professor's primary field, if expressed in thier profiles 
  a secondary intretest, this conditional statement essentially combines them in order of primary, first and secondary, next."
  
  if (length(expertise) == 2){
    
    expertise <- paste(expertise[1], expertise[2], sep=" & ")
    
  }
  
  #'* print(expertise) # Commented out as this was only for test purpose whilst debugging; however, could prove useful if desired.*
  
  #'[ This retrieves the professor's previous education history.
  
  prev_edu_his <- c(1:5)
  
  comment(prev_edu_his) <- " This visually appears Slightly convoluted since in the source code, the histories are stored into 
  three different types of tags, whch makes elusive to the modular loop-through, thus requiring slightly complex workaround."
  
  for (p in prev_edu_his){
    
    pre_edu_check_0 <- try(page %>% html_nodes(xpath= '//*[@id="block-iima-content"]/section[5]/div/div/div/div[2]/div/div/div/p') %>% html_text()%>%unlist())
    
    comment(pre_edu_check_0) <- "This checks for the first type of tag; normally they only hold a single record, hence 
    the hard-coded NA values for the next four subsequent results- 'break' helps to come out of the nested loop."
    
    if (length(pre_edu_check_0) == 1) {
      
      if (p == 1){
        
        assign(paste0('prev_edu_',p,'_prog'),page %>% html_nodes(xpath= '//*[@id="block-iima-content"]/section[5]/div/div/div/div[2]/div/div/div/p') %>% html_text() %>% str_remove('\r\n ') %>% 
                 as.character() %>% str_squish()) #%>% print()
        
        for (n in 2:5){assign(paste0('prev_edu_',n,'_prog'),NA)}
        
        stop = TRUE # This fires the flag, and breaks the inner loop.
        
        break
        
      }
      
      if (stop) {break} # This breaks the outer loop when the flag is fired.
      
    }
    
    pre_edu_check <- try(page %>% html_nodes(xpath= paste0('//*[@id="block-iima-content"]/section[5]/div/div/div/div[2]/div/div/div[',p,']/p')) %>% html_text()%>%unlist())
    
    comment(pre_edu_check) <- "This checks for the second type of tag holding previous education records."
    
    pre_edu_check_2<- try(page %>% html_nodes(xpath= paste0('//*[@id="block-iima-content"]/section[4]/div/div/div/div[2]/div/div/div[',p,']/p/text()')) %>% html_text()%>%unlist())
    
    comment(pre_edu_check_2) <- "This checks for the third type of tag holding previous educational records."
    
    if (length(pre_edu_check) == 1) {
      
      assign(paste0('prev_edu_',p,'_prog'),page %>% html_nodes(xpath= paste0('//*[@id="block-iima-content"]/section[5]/div/div/div/div[2]/div/div/div[',p,']/p')) %>% html_text() %>% str_remove('\r\n ') %>% 
               as.character() %>% str_squish()) #%>% print()
      
    } else if (length(pre_edu_check) == 0 & length(pre_edu_check_2) != 0){
      
      assign(paste0('prev_edu_',p,'_prog'),page %>% html_nodes(xpath= paste0('//*[@id="block-iima-content"]/section[4]/div/div/div/div[2]/div/div/div[',p,']/p/text()')) %>% html_text() %>% str_remove('\r\n ') %>% 
               as.character() %>% str_squish()) #%>% print()
      
    } else {
      
      assign(paste0('prev_edu_',p,'_prog'),NA) #%>% print() # This assigns NA to unfilled Contingency educational record fields.
      
    }
   
  }
  
  #'* Commented out as this was only for test purpose whilst debugging; however, could prove useful if desired.*
  #'*  if (is.na(prev_edu_1_prog) == FALSE | is.na(prev_edu_2_prog) == FALSE | is.na(prev_edu_3_prog) == FALSE |is.na(prev_edu_4_prog) == FALSE |is.na(prev_edu_5_prog) == FALSE){*
  #'*  *
  #'*  writeLines(c(prev_edu_1_prog,prev_edu_2_prog,prev_edu_3_prog,prev_edu_4_prog,prev_edu_5_prog))}*
  
  #'[ This retrieves the professor's Email.ID
  contact = page %>% html_nodes(xpath='//*[@id="block-iima-content"]/section[3]/div/div/div/div[2]/div/div/div[1]/p[1]/text()') %>% html_text() %>% str_remove('\r\n ') %>% 
    as.character() %>% str_squish()
  
  if (length(contact) == 0){ # This condition is due to the email being stored in a different tag between the professors. 
    
    contact <- page %>% html_nodes(xpath='//*[@id="block-iima-content"]/section[4]/div/div/div/div[2]/div/div/div[1]/p[1]/text()') %>% html_text() %>% str_remove('\r\n ') %>%
      as.character() %>% str_squish()
    
  }
  
  #'* print(contact)  # Commented out as this was only for test purpose whilst debugging; however, could prove useful if desired.*
  
  #'[ This retrieves the professor's website's link
  website <- page %>% html_nodes(xpath='//*[@id="block-iima-content"]/section[4]/div/div/div/div[2]/div/div/div[3]/p[1]/a') %>% html_attr('href')
  
  if (length(website) == 0){ # This condition is due to the webpages being stored in a different tag between the professors. 
    
    website <- page %>% html_nodes(xpath='//*[@id="block-iima-content"]/section[3]/div/div/div/div[2]/div/div/div[3]/p/a') %>% html_attr('href')
    
  }
  
  #'* print(website)  # Commented out as this was only for test purpose whilst debugging; however, could prove useful if desired.*
  
  #'[ Combines the collected objects into a list
  prof_profile <- list(Professor_Name = prof_name, 
                       Role = role,
                       Expertise = expertise,
                       Previous_Education_1 = prev_edu_1_prog,
                       Previous_Education_2 = prev_edu_2_prog,
                       Previous_Education_3 = prev_edu_3_prog,
                       Previous_Education_4 = prev_edu_4_prog,
                       Previous_Education_5 = prev_edu_5_prog,
                       Email.ID = contact,
                       Website = website)
  
  #'[  Converts the list into a data frame
  prof_profile <- as.data.frame(prof_profile)
  
  #'[  Appending the data frame to the main faculty_profile data.frame
  faculty_profile <- rbind(faculty_profile, prof_profile)
  
  #'[  This deletes all the stored objects, so that they doesn't get assigned to un-iterated over variables during next loop.] @note: The warnings are intention-ly suppressed.
  suppressWarnings(rm(prof_name,role,expertise,prev_edu_1_prog,prev_edu_2_prog,prev_edu_3_prog,prev_edu_4_prog,prev_edu_5_prog,contact,website,pre_edu_check_0,pre_edu_check,pre_edu_check_2))
  
}

# end.time <- Sys.time()
# time.taken <- round(end.time - start.time,2)
# print(paste0("Time taken to run the analysis: ", time.taken)

#Saves the faculty_profile data.frame
save(faculty_profile,file="iima_econ_dept_profile.Rda")

# Write the data.frame to a csv file
write_csv(faculty_profile, "IIMA_Econ_Dept_Profiles.csv", na = "")

#'* View(faculty_profile) # Commented out as this was only for test purpose whilst debugging; however, could prove useful if desired.*

#'@references https://github.com/ggSamoora/TutorialsBySamoora/blob/main/Yelp%20Scraper%20-%20YT.R