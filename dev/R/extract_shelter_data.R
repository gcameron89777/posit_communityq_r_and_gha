setwd(here::here("dev", "R"))

pacman::p_load(tidyverse, opendatatoronto, janitor, here)

get_shelter_data <- function(year = 2024) {
       
    # Oped Data API Info
    info <- opendatatoronto::show_package("21c83b32-d5a8-4106-a54f-010dbe49f6f2") %>% 
        list_package_resources() %>% 
        filter(str_to_lower(format) %in% c("csv", "geojson")) %>% 
        filter(! is.na(last_modified)) %>% 
        arrange(desc(last_modified)) %>% 
        mutate(last_modified_year = lubridate::year(last_modified))
    
    info_2 <- info %>% 
        filter(last_modified_year == year) %>% 
        arrange(desc(last_modified)) %>% 
        head(1)
    
    # Info Check
    if (is.null(info) || length(info) == 0) {
        stop("No API info extracted! Check API info code chunk", call. = FALSE)
        msg = "No API info extracted!"
    }
    
    # Data Extract (Open Data API)
    data <- info_2 %>% 
        get_resource() %>% 
        janitor::clean_names() %>% 
        mutate(occupancy_date = lubridate::ymd(occupancy_date)) %>% 
        head(5)
    
    # Data Check
    if (is.null(data) || length(data) == 0) {
        stop("No data extracted! Check data chunk", call. = FALSE)
        msg = "No data extracted!"
    }
    
   ret <- data %>% mutate(time = Sys.time())
    
    # Return
    return(ret)
    
}

shelter_raw_tbl <- get_shelter_data()

if (!dir.exists("../../data")) {dir.create("../../data")}

save_path <- str_glue("../../data/shelter_raw_tbl_{Sys.time()}.csv")

shelter_raw_tbl %>% write_csv(save_path)