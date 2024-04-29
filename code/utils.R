getDate <- function(time) {
  strftime(time, format="%Y-%m-%d", tz="GMT")
}

getMonth <- function(time) {
  strtoi(strftime(time, format="%m", tz="GMT"), base=10)
}

getHour <- function(time) {
  strtoi(strftime(time, format="%H", tz="GMT"), base=10)
}

date()