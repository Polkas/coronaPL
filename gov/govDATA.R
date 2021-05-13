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
woj_sha <- "a8c562ead9c54e13a135b02e0d875ffb"
woj_sha_old <- "b03b454aed9b4154ba50df4ba9e1143b"
pow_sha <- "e16df1fa98c2452783ec10b0aea4b341"

pol_encoding <- "Windows-1250"
path_pow <- "gov/raw_data/pow"
path_woj <- "gov/raw_data/woj"

path_res_pow1 <- "gov/data/pow_df.csv"
path_res_pow2 <- "gov/data/pow_df_full.csv"

path_res_woj <- "gov/data/woj_df.csv"

path_res <- "gov/data"
tempzip <- tempfile(fileext = ".zip")
all_id <- "Cały kraj"
woj_var <- "wojewodztwo"
pow_var <- "powiat_miasto"

dir.create(path_res)
dir.create(path_pow, recursive = TRUE)
dir.create(path_woj, recursive = TRUE)

# Powiaty
download.file(paste0(main_url, pow_sha, "/data"), tempzip)
unzip(tempzip, exdir = path_pow)
# Wojewodztwa
download.file(paste0(main_url, woj_sha, "/data"), tempzip)
unzip(tempzip, exdir = path_woj)

# Przetwarzanie
# niepelny plik 20210107054535_rap_gov_pow_eksport.csv
pow_df <- rbindlist(lapply(
  list.files(path_pow, pattern = "csv"),
  function(x) {
    dat <- fread(
      file = paste0(path_pow, "/", x),
      colClasses = list(character = "liczba_na_10_tys_mieszkancow"),
    )
    dat$name <- x
    dat$Date <- ymd(substr(x, 1, 8))
    dat[[woj_var]] <- if (dat[[woj_var]][1] != all_id) str_conv(dat[[woj_var]], pol_encoding) else dat[[woj_var]]
    dat[[pow_var]] <- if (dat[[pow_var]][1] != all_id) str_conv(dat[[pow_var]], pol_encoding) else dat[[pow_var]]
    dat
  }
), fill = TRUE)

pow_df$liczba_na_10_tys_mieszkancow <- as.numeric(pow_df$liczba_na_10_tys_mieszkancow)

# pow_df_old <- fread("old_mrogalski/pow_df_old.csv")
# pow_df_old$Date <- as.Date(pow_df_old$Date)
# pow_df_final <- rbindlist(list(pow_df_old, pow_df), fill = TRUE)

pow_df$stan_rekordu_na <- pow_df$Date -1

write.csv(pow_df[, c("wojewodztwo",
                     "powiat_miasto",
                     "liczba_przypadkow",
                     "liczba_na_10_tys_mieszkancow",
                     "zgony",
                     "stan_rekordu_na",
                     "Date")], path_res_pow1, row.names = FALSE)
write.csv(pow_df, path_res_pow2, row.names = FALSE)

woj_df <- rbindlist(lapply(
  list.files(path_woj, pattern = "csv"),
  function(x) {
    dat <- fread(file = paste0(path_woj, "/", x))
    dat$name <- x
    dat$Date <- ymd(substr(x, 1, 8))
    dat[[woj_var]] <- if (dat[[woj_var]][1] != all_id) str_conv(dat[[woj_var]], pol_encoding) else dat[[woj_var]]
    dat
  }
), fill = TRUE)

woj_df$stan_rekordu_na <- woj_df$Date - 1
woj_df$liczba_na_10_tys_mieszkancow <- as.numeric(woj_df$liczba_na_10_tys_mieszkancow)
# Dane dla wojewodztw od poczatku pandemi m rogalski

# woj_df_old <- fread("old_mrogalski/woj_df_old.csv")
# woj_df_old$stan_rekordu_na <- as.Date(woj_df_old$stan_rekordu_na)
# woj_df_old$Date <- as.Date(woj_df_old$Date)
# woj_df_final <- rbindlist(list(woj_df_old, woj_df), fill = TRUE)

write.csv(woj_df, path_res_woj, row.names = FALSE)
