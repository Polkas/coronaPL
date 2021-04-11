# DATA SOURCE: https://www.gov.pl/web/koronawirus/wykaz-zarazen-koronawirusem-sars-cov-2
# Daily Update
# Run once per day after 12:00 GMT + 2h

if (!"pacman" %in% unname(installed.packages()[, 1])) install.packages("pacman")
pacman::p_load(
  data.table,
  dplyr,
  stringr,
  lubridate
)

main_url <- "https://arcgis.com/sharing/rest/content/items/"
# Looks to be stable
woj_sha <- "a8c562ead9c54e13a135b02e0d875ffb"
pow_sha <- "e16df1fa98c2452783ec10b0aea4b341"

pol_encoding <- "Windows-1250"
path_res_pow <- "gov/data/pow_df.csv"
path_res_woj <- "gov/data/woj_df.csv"
all_id <- "Cały kraj"
woj_var <- "wojewodztwo"
pow_var <- "powiat_miasto"
tempcsv <- tempfile(fileext = ".csv")

woj_daily_hash <- "153a138859bb4c418156642b5b74925b"
pow_daily_hash <- "6ff45d6b5b224632a672e764e04e8394"

download.file(sprintf("%s%s/data", main_url, woj_daily_hash), tempcsv)
dat <- fread(tempcsv)
dat$wojewodztwo <- if (dat[[woj_var]][1] != all_id) str_conv(dat[[woj_var]], pol_encoding) else dat[[woj_var]]
dat_old <- fread(path_res_woj)
if (!dat$stan_rekordu_na[1] %in% (dat_old$Date - 1)) {
  dat_fin <- rbindlist(list(dat_old, dat), fill = TRUE)
  write.csv(dat_fin, path_res_woj)
} else {
  print("You already have this data.")
}

download.file(sprintf("%s%s/data", main_url, pow_daily_hash), tempcsv)
dat <- fread(tempcsv)
dat$wojewodztwo <- if (dat[[woj_var]][1] != all_id) str_conv(dat[[woj_var]], pol_encoding) else dat[[woj_var]]
dat$powiat_miasto <- if (dat[[pow_var]][1] != all_id) str_conv(dat[[pow_var]], pol_encoding) else dat[[pow_var]]
dat_old <- fread(path_res_pow)
if (!dat$stan_rekordu_na[1] %in% (dat_old$Date - 1)) {
  dat_fin <- rbindlist(list(dat_old, dat), fill = TRUE)
  write.csv(dat_fin, path_res_pow)
} else {
  print("You already have this data.")
}
