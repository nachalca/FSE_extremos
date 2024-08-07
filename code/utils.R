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

date()