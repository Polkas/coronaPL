# DATA SOURCE: https://www.gov.pl/web/koronawirus/wykaz-zarazen-koronawirusem-sars-cov-2
# Daily Update
# Run once per day after 12:00 GMT + 2h

#if (!"pacman" %in% unname(installed.packages()[, 1])) install.packages("pacman")
library(data.table)
library(stringr)
library(lubridate)

main_url <- "https://arcgis.com/sharing/rest/content/items/"
# Looks to be stable
woj_sha <- "a8c562ead9c54e13a135b02e0d875ffb"
pow_sha <- "e16df1fa98c2452783ec10b0aea4b341"

pol_encoding <- "Windows-1250"
path_res_pow <- "data/pow_df.csv"
path_res_woj <- "data/woj_df.csv"
all_id <- "Cały kraj"
woj_var <- "wojewodztwo"
pow_var <- "powiat_miasto"
tempcsv <- tempfile(fileext = ".csv")

woj_daily_hash <- "153a138859bb4c418156642b5b74925b"
pow_daily_hash <- "6ff45d6b5b224632a672e764e04e8394"

woj_c_name <- sprintf("gov/raw_data/woj/%s060000_rap_rcb_woj_eksport.csv", format(Sys.Date(), "%Y%m%d"))

if (! Sys.Date() %in% as.Date(substr(list.files("gov/raw_data/woj"), 1, 8), "%Y%m%d")) {
  download.file(sprintf("%s%s/data", main_url, woj_daily_hash), pow_c_name)
  dat <- fread(woj_c_name)
  dat$wojewodztwo <- if (dat[[woj_var]][1] != all_id) str_conv(dat[[woj_var]], pol_encoding) else dat[[woj_var]]
  write.csv(dat, woj_c_name)
}

pow_c_name <- sprintf("gov/raw_data/pow/%s074502_rap_rcb_pow_eksport.csv", format(Sys.Date(), "%Y%m%d"))

if (! Sys.Date() %in% as.Date(substr(list.files("gov/raw_data/pow"), 1, 8), "%Y%m%d")) {
  download.file(sprintf("%s%s/data", main_url, pow_daily_hash), pow_c_name)
  dat <- fread(pow_c_name)
  dat$wojewodztwo <- if (dat[[woj_var]][1] != all_id) str_conv(dat[[woj_var]], pol_encoding) else dat[[woj_var]]
  dat$powiat_miasto <- if (dat[[pow_var]][1] != all_id) str_conv(dat[[pow_var]], pol_encoding) else dat[[pow_var]]
  write.csv(dat, pow_c_name)
}
