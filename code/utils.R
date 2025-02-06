getDate <- function(time) {
  strftime(time, format="%Y-%m-%d", tz="GMT")
}

getMonth <- function(time) {
  strtoi(strftime(time, format="%m", tz="GMT"), base=10)
}

getHour <- function(time) {
  strtoi(strftime(time, format="%H", tz="GMT"), base=10)
}

getYear <- function(time) {
  strtoi(strftime(time, format="%Y", tz="GMT"), base=10)
}

getYearMonth <- function(time) {
  strftime(time, format="%Y-%m", tz="GMT")
}

getMonthDay <- function(time){
  strftime(time, format="%m-%d", tz="GMT")
}

getCoarseResolution <- function(time, daily){
  if(daily){
    getDate(time)
  }else{
    getYearMonth(time)
  }
}

flatten_list <- function(lst, parent_key = "") {
  result <- list()
  
  for (name in names(lst)) {
    full_name <- if (parent_key == "") name else paste(parent_key, name, sep = ".")
    
    if (is.list(lst[[name]])) {
      result <- c(result, flatten_list(lst[[name]], full_name))
    } else {
      result[[full_name]] <- lst[[name]]
    }
  }
  
  return(result)
}

substract_seasonality <- function(data, variable){
  
  variable <- rlang::sym(variable)
  
  data <- data |> 
    mutate(day = getMonthDay(time))
  
  data <- data |>
    group_by(day) |>
    mutate(m = mean(!!variable), new := !!variable - mean(!!variable)) |>     
    ungroup() 
  
  data  
}