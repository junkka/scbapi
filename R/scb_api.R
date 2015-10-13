#' Query SCB API
#'
#' Build query for scb api
#'
#' @param id = url string
#' @import httr jsonlite
#' @export
#' @examples
#' a <- scb_api("ssd/BE/BE0001/BE0001T100")
#' res <- a$get()
#' 

scb_api <- function(id = "ssd"){
  id <- id
  url <- sprintf("http://api.scb.se/OV0104/v1/doris/en/%s", id)
  r <- httr::GET(url)
  rd <- content(r, as = "text")
  b <- fromJSON(rd)
  a <- list(data = b)
  class(a) <- "scb_api"
  a$di <- function(){
    return(id)
  }
  a$get_vars <- function(){
    return(b$variables)
  }
  a$get <- function(b = b){
    # from the a response build values
    vars <- a$get_vars()
    id <- a$di()
    r <- httr::POST(sprintf("http://api.scb.se/OV0104/v1/doris/en/%s", id), body = paste0('{   
    "query": [
     {       
     "code": "ContentsCode",
      "selection": {         
        "filter": "item",         
        "values": [
        ', paste0('"', paste(vars$values[vars$code == "ContentsCode"], collapse = '","'), '"'),'
        ]       
       }     
    },    
    {       
      "code": "Tid",
       "selection": {         
       "filter": "item",         
       "values": [           
       ', paste0('"', paste(unlist(vars$values[vars$code == "Tid"]), collapse = '","'), '"'),'
       ]       
      }     
     }    
    ],   
    "response": {     
      "format": "csv"   
     } 
    }'))
    stop_for_status(r)
    rd <- httr::content(r)
    return(rd)
  }
  return(a)
}

print.scb_api <- function(a){
  print(a$data)
}