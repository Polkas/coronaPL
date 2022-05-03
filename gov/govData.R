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
all_vac_sha <- "b860f2797f7f4da789cb6fccf6bd5bc7"

pol_encoding <- "Windows-1250"
path_data <- tempdir(check = TRUE)

path_res <- "gov/data"
path_res_pow1 <- gzfile("gov/data/pow_df.csv.gz")
path_res_pow2 <- gzfile("gov/data/pow_df_full.csv.gz")
path_res_woj <- gzfile("gov/data/woj_df.csv.gz")
path_res_pow_vac <- gzfile("gov/data/pow_df_vac.csv.gz")
path_res_woj_vac <- gzfile("gov/data/woj_df_vac.csv.gz")

tempzip <- tempfile(fileext = ".zip")
all_id <- c("cały kraj", "Cały kraj", "Cały Kraj")
woj_var <- "wojewodztwo"
pow_var <- "powiat_miasto"

dir.create(path_res)

# Powiaty
download.file(paste0(main_url, pow_sha, "/data"), tempzip)
unzip(tempzip, exdir = path_data)
# Wojewodztwa
download.file(paste0(main_url, woj_sha, "/data"), tempzip)
unzip(tempzip, exdir = path_data)
# Vaccination
download.file(paste0(main_url, all_vac_sha, "/data"), tempzip)
unzip(tempzip, exdir = path_data)

# Przetwarzanie
# niepelny plik 20210107054535_rap_gov_pow_eksport.csv
pow_df <- rbindlist(lapply(
  list.files(path_data, pattern = "_pow_eksport.csv"),
  function(x) {
    dat <- fread(
      file = paste0(path_data, "/", x)
    )
    dat$name <- x
    dat$Date <- ymd(substr(x, 1, 8))
    if (is.null(dat$powiat_miasto)) dat$powiat_miasto <- dat$powiat
    if (is.null(dat$liczba_przypadkow)) dat$liczba_przypadkow <- dat$liczba_wszystkich_zakazen
    if (is.null(dat$liczba_na_10_tys_mieszkancow)) dat$liczba_na_10_tys_mieszkancow <- dat$liczba_wszystkich_zakazen_na_10_tys_mieszkancow
    dat[[woj_var]] <- if (!dat[[woj_var]][1] %in% all_id) str_conv(dat[[woj_var]], pol_encoding) else dat[[woj_var]]
    dat[[pow_var]] <- if (!dat[[pow_var]][1] %in% all_id) str_conv(dat[[pow_var]], pol_encoding) else dat[[pow_var]]
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
  list.files(path_data, pattern = "_woj_eksport.csv"),
  function(x) {
    dat <- fread(file = paste0(path_data, "/", x))
    if (is.null(dat$liczba_przypadkow)) dat$liczba_przypadkow <- dat$liczba_wszystkich_zakazen
    if (is.null(dat$liczba_na_10_tys_mieszkancow)) dat$liczba_na_10_tys_mieszkancow <- dat$liczba_wszystkich_zakazen_na_10_tys_mieszkancow
    dat$name <- x
    dat$Date <- ymd(substr(x, 1, 8))
    dat[[woj_var]] <- if (!dat[[woj_var]][1] %in% all_id) str_conv(dat[[woj_var]], pol_encoding) else dat[[woj_var]]
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

# Vaccination

pow_df <- rbindlist(lapply(
  list.files(path_data, pattern = "pow_szczepienia.csv"),
  function(x) {
    dat <- fread(
      file = paste0(path_data, "/", x)
    )
    dat$name <- x
    dat$Date <- ymd(substr(x, 1, 8))
    dat[[woj_var]] <- if (!tail(dat[[woj_var]], 1) %in% all_id) str_conv(dat[[woj_var]], pol_encoding) else dat[[woj_var]]
    dat[[pow_var]] <- if (dat[[pow_var]][nrow(dat) - 1] == "Świnoujście") dat[[pow_var]] else str_conv(dat[[pow_var]], pol_encoding)
    dat
  }
), fill = TRUE)

pow_df$stan_rekordu_na <- pow_df$Date - 1

write.csv(pow_df, path_res_pow_vac, row.names = FALSE)

woj_df <- rbindlist(lapply(
  list.files(path_data, pattern = "woj_szczepienia.csv"),
  function(x) {
    dat <- fread(file = paste0(path_data, "/", x))
    dat$name <- x
    dat$Date <- ymd(substr(x, 1, 8))
    dat[[woj_var]] <- if (!tail(dat[[woj_var]], 1) %in% all_id) str_conv(dat[[woj_var]], pol_encoding) else dat[[woj_var]]
    dat
  }
), fill = TRUE)

woj_df$stan_rekordu_na <- woj_df$Date - 1
write.csv(woj_df, path_res_woj_vac, row.names = FALSE)

