#!/usr/bin/env Rscript

###################
# Master run file #
###################

#' @title SheRNI_Master_Scrapper
#' @author: Guganesan Ilavarasan
#' @email: gi247@cam.ac.uk
#' @date: 13/06/2024 15:28
#' @param masterlink input (character)
#' @return researchers_profile output (data.frame)
#' @include faculty_profile_links.R
#' @importClassesFrom SheRNI_Links_Scrapper get_links()
#' @importClassesFrom SheRNI_Profiles_Scrapper profile_scrapper()
#' @description
#' This module acts as the master run, which summons the auxiliary modules to collect links of individuals of interest and then run those links to retrieve 
#' their academic and professional attributes, which is done by calling SheRNI_Links_Scrapper and SheRNI_Profiles_Scrapper modules. This inputs the main 
#' homepage of SheRNI's database to filter researchers and outputs a data.frame with educational / research attributes stipulated to be scrapped.

source('SheRNI_Links_Scrapper.R') #'[ This sources the module to run the links-scrapper to gather profile links of all researchers of interest in the SheRNI repository.
source('SheRNI_Profiles_Scrapper.R') #'[ This sources the module to run the profiles-scrapper to retrieve individual academic and research attributes of all researchers 
                                      #'[ of interest.

#'* This passes the repository's main hyperlink of its home page from where researchers' profiles could be filtered based on requisite.*
masterlink <- 'https://sherni.inflibnet.ac.in/searchc/search'
#' search_word <- 'Economics' [ This is an optional parameter to filter the results for a more coarser results output.

#'* This sets up an empty data.frame to gather links to profiles of all individual researchers of interest.*
links_df <- data.frame(Links = character(),row.names = NULL)

#'[ This calls the] *get_links()* [function from the] *SheRNI_Links_Scrapper.R* [module, with SheRNI's home link passed as an argument to retrieve individual profiles' links.
get_links(masterlink)
#' get_links(masterlink,search_word) [An alternative approach to call the same function if a word search is required to be passed for a less objective search return of results.

#'* This sets up an empty data.frame to gather individual profile attributes of all researchers of interest whose links to profile were gathered priorly.*
researchers_profile <- data.frame(Professor_ID = numeric(),
                                  Professor_Name = character(),
                                  Role = character(),
                                  University = character(),
                                  Department = character(),
                                  Previous_Education_1_Programme = character(),
                                  Previous_Education_1_Institution = character(),
                                  Previous_Education_1_Year = numeric(), 
                                  Previous_Education_2_Programme = character(),
                                  Previous_Education_2_Institution = character(),
                                  Previous_Education_2_Year = numeric(), 
                                  Previous_Education_3_Programme = character(),
                                  Previous_Education_3_Institution = character(),
                                  Previous_Education_3_Year = numeric(), 
                                  Previous_Education_4_Programme = character(),
                                  Previous_Education_4_Institution = character(),
                                  Previous_Education_4_Year = numeric(), 
                                  Previous_Education_5_Programme = character(),
                                  Previous_Education_5_Institution = character(),
                                  Previous_Education_5_Year = numeric(), 
                                  Total_Publications = numeric())

#'[ This calls the] *profile_scrapper()* [function from the] *SheRNI_Profiles_Scrapper.R* [module, with links_df passed as an argument to retrieve attributes of individual
#'[researchers of interest.
profile_scrapper(links_df)

#'@This_opens_the_newly_populated_'researchers_profile'_data.frame_with_the_final_output.
View(researchers_profile)

#'@references https://github.com/Guganesan-Ilavarasan/OxCalvsOLE/blob/b3a97aff56e540e189f14f3cce0581484310921e/multicoremasterrun.R