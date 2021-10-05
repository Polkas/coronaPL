# DATA SOURCE: https://www.gov.pl/web/koronawirus/wykaz-zarazen-koronawirusem-sars-cov-2

#if (!"pacman" %in% unname(installed.packages()[, 1])) install.packages("pacman")
library(data.table)
library(stringr)
library(lubridate)

if (Sys.getenv("PYTHONANYWHERE_SITE") == "www.pythonanywhere.com") {
setwd("/home/polkas/Rdir/coronaPL")
}

main_url <- "https://arcgis.com/sharing/rest/content/items/"
# Looks to be stable
woj_sha <- "0b17f540e23e4871a1196fd4097f9659"
pow_sha <- "8ee83bf0d2a3415387e4a353f66b8862"

pol_encoding <- "Windows-1250"
path_pow <- "gov/raw_data_vac/pow"
path_woj <- "gov/raw_data_vac/woj"

path_res_pow <- "gov/data/pow_df_vac.csv"

path_res_woj <- "gov/data/woj_df_vac.csv"

path_res <- "gov/data"
all_id <- c("cały kraj", "Cały kraj", "Cały Kraj")
woj_var <- "wojewodztwo"
pow_var <- "powiat_miasto"

dir.create(path_res)
dir.create(path_pow, recursive = TRUE)
dir.create(path_woj, recursive = TRUE)

woj_c_name <- sprintf("gov/raw_data_vac/woj/%s060000_rap_rcb_woj_eksport_vac.csv", format(Sys.Date(), "%Y%m%d"))

if (! Sys.Date() %in% as.Date(substr(list.files(path_woj), 1, 8), "%Y%m%d")) {
  download.file(sprintf("%s%s/data", main_url, woj_sha), woj_c_name)
}

pow_c_name <- sprintf("gov/raw_data_vac/pow/%s074502_rap_rcb_pow_eksport_vac.csv", format(Sys.Date(), "%Y%m%d"))

if (! Sys.Date() %in% as.Date(substr(list.files(path_pow), 1, 8), "%Y%m%d")) {
  download.file(sprintf("%s%s/data", main_url, pow_sha), pow_c_name)
}

# Przetwarzanie
# niepelny plik 20210107054535_rap_gov_pow_eksport.csv
pow_df <- rbindlist(lapply(
  list.files(path_pow, pattern = "csv"),
  function(x) {
    dat <- fread(
      file = paste0(path_pow, "/", x)
    )
    dat$name <- x
    dat$Date <- ymd(substr(x, 1, 8))
    dat[[woj_var]] <- if (!tail(dat[[woj_var]], 1) %in% all_id) str_conv(dat[[woj_var]], pol_encoding) else dat[[woj_var]]
    dat[[pow_var]] <- if (!tail(dat[[pow_var]], 1) %in% all_id) str_conv(dat[[pow_var]], pol_encoding) else dat[[pow_var]]
    dat
  }
), fill = TRUE)

pow_df$stan_rekordu_na <- pow_df$Date - 1

write.csv(pow_df, path_res_pow, row.names = FALSE)

woj_df <- rbindlist(lapply(
  list.files(path_woj, pattern = "csv"),
  function(x) {
    dat <- fread(file = paste0(path_woj, "/", x))
    dat$name <- x
    dat$Date <- ymd(substr(x, 1, 8))
    dat[[woj_var]] <- if (!tail(dat[[woj_var]], 1) %in% all_id) str_conv(dat[[woj_var]], pol_encoding) else dat[[woj_var]]
    dat
  }
), fill = TRUE)

woj_df$stan_rekordu_na <- woj_df$Date - 1

write.csv(woj_df, path_res_woj, row.names = FALSE)
