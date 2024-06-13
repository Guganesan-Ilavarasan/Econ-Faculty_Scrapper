#' @title SheRNI_Profiles_Scrapper
#' @author: Guganesan Ilavarasan
#' @email: gi247@cam.ac.uk
#' @date: 13/06/2024 00:49
#' @param links_dataframe input (data.frame)
#' @return researchers_profile output (data.frame)
#' @include faculty_profile_links.R
#' @importFrom stringr str_squish()
#' @description
#' This module loads all the individual profiles' links gathered previously through 'SheRNI_Links_Scrapper'
#' and retrieves the researchers' academic and research attributes of interest.

profile_scrapper <- function (links_dataframe){

library(rvest)
  
library(stringr) # This library is used to access str_squish() function to remove white spaces from results.

comment(links_dataframe) <- "The earlier collected data.frame of links of all researchers under the passed filter conditions, links_df, 
is assigned into this loop to be iterated over each profile to retrieve their individual academic and professional attributes of interest. 
The data.frame is passed as an argument from the main-run module, SheRNI_master_scrapper, through 'links_dataframe' function parameter."

for (i in 1:nrow(links_dataframe)){
    
  url = links_dataframe[i,] #'[ The i-th link of all links is assigned to be analysed.
  
  page <- read_html(url) #'[ The profile of the researcher is loaded.
  
  #'[ This gets the name of the researcher.
  prof_name = page %>% html_nodes("h4 span") %>% html_text()
  
  #'[ This is a qualification check to only choose profiles with a] '*doctorate.*
  quali_match <- pmatch(c("Ms","Miss","Mrs", "Miss", "Smt"), prof_name, nomatch = 0) %>% sum()
  
  #'[ This conditional clause permits the rest of scrape to be performed if the researcher has a PhD.
  if (quali_match < 1 & length(prof_name) != 0)
    
  {
    
    #'* This retrieves the researcher's unique 'Vidwan-ID' which could be used for identification in the final output data.*
    prof_id = page %>% html_nodes(".ui-id") %>% html_text() %>% str_remove('\r\n ') %>% 
      as.character() %>% str_squish() %>% strsplit(, split = ":") %>% unlist()
    prof_id = prof_id[2]%>% as.numeric()
    
    #'* This retrieves the researcher's designation within their institution.*
    role = page %>% html_nodes("#edit-experience-view:nth-child(1) h2") %>% html_text() %>% str_remove('\r\n ') %>% 
      as.character() %>% str_squish()
    
    #'* This retrieves the researcher's affiliated educational/research institution.*
    uni = page %>% html_nodes("#edit-experience-view:nth-child(1) p+ p") %>% html_text() %>% str_remove('\r\n ') %>% 
      as.character() %>% str_squish()
    
    #'* This retrieves the researcher's affiliated department within their institution.*
    dept = page %>% html_nodes("#edit-experience-view:nth-child(1) h2+ p") %>% html_text() %>% str_remove('\r\n ') %>% 
      as.character() %>% str_squish()
    
    comment(prev_edu_his) <- " This loop retirves the five most recent educational qualifications the reseracher has been bequeated."
    prev_edu_his <- c(1:5)
    
    for (p in prev_edu_his){
      
      #'* This retrieves the p-th educational qualification of the researcher.*
      pre_edu_check <- try(page %>% html_nodes(paste0("#qualification-view:nth-child(",p,") h2")) %>% html_text()%>%unlist())
      
      #'* This checks if the qualification is available to scrape, unavailability of which is passed to 'else' clause.*
      if (length(pre_edu_check) != 0){
        
        #'* This retrieves the programme of the p-th qualification.*
        assign(paste0('prev_edu_',p,'_prog'),page %>% html_nodes(paste0("#qualification-view:nth-child(",p,") h2")) %>% html_text() %>% str_remove('\r\n ') %>% 
                 as.character() %>% str_squish())
        
        #'* This retrieves the university where the p-th qualification of the researcher was obtained.*
        assign(paste0('prev_edu_',p,'_uni'),page %>% html_nodes(paste0("#qualification-view:nth-child(",p,") p")) %>% html_text() %>% str_remove('\r\n ') %>% 
                 as.character() %>% str_squish())
        
        #'* This retrieves the year the p-th qualification of the researcher was obtained.*
        assign(paste0('prev_edu_',p,'_yr'),page %>% html_nodes(paste0("#qualification-view:nth-child(",p,") span")) %>% html_text() %>% str_extract('\\d+') %>% 
                 str_remove('\r\n ') %>% as.numeric())
        
      }else{ #'* If any of the seeked information regarding the qualification is absent, this 'else' clause assigns NA to their respective fields.*
        
        assign(paste0('prev_edu_',p,'_prog'),NA)
        
        assign(paste0('prev_edu_',p,'_uni'),NA)
        
        assign(paste0('prev_edu_',p,'_yr'),NA)
        
      }
    }
    
    #'* This checks if the researcher has any published works mentioned in their profile.*
    pub_check <- try(page %>% html_nodes(".margin-bottom-10 .pull-left") %>% html_text()%>%unlist())
    
    #'* If there are, this retrieves the total number of published work by the researcher.*
    if (length(pub_check) != 0){
      
      publications <- page %>% html_nodes(".margin-bottom-10 .pull-left") %>% html_text() %>% str_remove('\r\n ') %>% 
        as.character() %>% str_squish()
      
      publications = unlist(strsplit(publications, split='(', fixed=TRUE))[2] 
      
      publications = gsub(")","", publications) %>% as.numeric()
      
    }else{
      
      assign('publications',NA) #'* This assigns NA to the field if the researcher's published works cannot be found.*
      
    }
    
    #'* This combines all objects of the researcher's retrieved attributes into a list.*
    researcher_profile <- list(Professor_ID = prof_id, 
                               Professor_Name = prof_name, 
                               Role = role,
                               University = uni,
                               Department = dept,
                               Previous_Education_1_Programme = prev_edu_1_prog,
                               Previous_Education_1_Institution = prev_edu_1_uni,
                               Previous_Education_1_Year = prev_edu_1_yr,
                               Previous_Education_2_Programme = prev_edu_2_prog,
                               Previous_Education_2_Institution = prev_edu_2_uni,
                               Previous_Education_2_Year = prev_edu_2_yr,
                               Previous_Education_3_Programme = prev_edu_3_prog,
                               Previous_Education_3_Institution = prev_edu_3_uni,
                               Previous_Education_3_Year = prev_edu_3_yr,
                               Previous_Education_4_Programme = prev_edu_4_prog,
                               Previous_Education_4_Institution = prev_edu_4_uni,
                               Previous_Education_4_Year = prev_edu_4_yr,
                               Previous_Education_5_Programme = prev_edu_5_prog,
                               Previous_Education_5_Institution = prev_edu_5_uni,
                               Previous_Education_5_Year = prev_edu_5_yr,
                               Total_Publications = publications)
    
    #'* This converts the compiled list into a data frame of a single row.*
    researcher_profile <- as.data.frame(researcher_profile)
    
    #'* This appends the individual researcher's data frame to the main researchers_profile data.frame.*
    researchers_profile <<- rbind(researchers_profile, researcher_profile)
    
    #'[ A faster option could be using library(data.table) as it joins by position rather than rbind.data.frame, which matches by name.
    # researchers_profile <- rbindlist(list(researchers_profile, researcher_profile))
    
  }
  
}

#'@_This_saves_the_'researchers_profile'_data.frame_into_a_.Rda_file.
save(researchers_profile,file="researchers_profile.Rda")

#'@_This_writes_the_'researchers_profile'_data.frame_to_a_csv_file.
write.csv(researchers_profile, "Researchers_Profiles.csv", na = "",row.names = FALSE)

}

#'@references https://github.com/ggSamoora/TutorialsBySamoora/blob/3cacfc7b902e8c81dd628789dc7a1100c6eb16c8/RSelenium%20Tutorial.R