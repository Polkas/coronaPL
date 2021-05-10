library(dplyr)
library(tidyr)
library(stringr)
dir_path <- "./old_mrogalski"

files_rogalski <- list.files(dir_path, full.names = TRUE)

ff <- list(c("Kopia COVID-19 w powiatach - Suma przypadków.csv", "liczba_przypadkow"),
     c("Kopia COVID-19 w powiatach - Suma zgonów.csv", "zgony"))

res <- list()

for (l in ff) {
  dd <- read.csv(sprintf("./old_mrogalski/%s", l[1]))[, -c(1, 2)]
  dd <- dd[dd$Nazwa != "" & !is.na(dd$Nazwa), ]
  dd <- cbind(dd[, 1, drop = F], vapply(dd[, -1], function(x) as.integer(x), FUN.VALUE = integer(nrow(dd))))
  dd <- pivot_longer(dd, cols = starts_with("X"), names_to = "Date", values_to = l[2])
  dd$stan_rekordu_na <- as.Date(str_c(str_sub(dd$Date, 2), ".2020"), "%d.%m.%y")
  dd <- dd[order(dd$Date), ]
  dd$Nazwa <- str_replace(dd$Nazwa, "Powiat ", "")
  dd$Nazwa <- str_replace(dd$Nazwa, "m\\.st\\.", "")
  dd$Nazwa <- str_replace(dd$Nazwa, "m\\.", "")
  dd$Nazwa <- str_replace(dd$Nazwa, "POLSKA", "Cały kraj")
  dd$powiat_miasto <- dd$Nazwa
  dd$Nazwa <- NULL
  dd$Date <- dd$stan_rekordu_na + 1
  res[[l[2]]] <- dd
}

dd_final <- full_join(res[[1]], res[[2]], by = c("powiat_miasto", "Date", "stan_rekordu_na"))

wojs <- structure(list(wojewodztwo = c(
  "Cały kraj", "dolnośląskie",
  "dolnośląskie", "dolnośląskie", "dolnośląskie", "dolnośląskie",
  "dolnośląskie", "dolnośląskie", "dolnośląskie", "dolnośląskie",
  "dolnośląskie", "dolnośląskie", "dolnośląskie", "dolnośląskie",
  "dolnośląskie", "dolnośląskie", "dolnośląskie", "dolnośląskie",
  "dolnośląskie", "dolnośląskie", "dolnośląskie", "dolnośląskie",
  "dolnośląskie", "dolnośląskie", "dolnośląskie", "dolnośląskie",
  "dolnośląskie", "dolnośląskie", "dolnośląskie", "dolnośląskie",
  "dolnośląskie", "kujawsko-pomorskie", "kujawsko-pomorskie",
  "kujawsko-pomorskie", "kujawsko-pomorskie", "kujawsko-pomorskie",
  "kujawsko-pomorskie", "kujawsko-pomorskie", "kujawsko-pomorskie",
  "kujawsko-pomorskie", "kujawsko-pomorskie", "kujawsko-pomorskie",
  "kujawsko-pomorskie", "kujawsko-pomorskie", "kujawsko-pomorskie",
  "kujawsko-pomorskie", "kujawsko-pomorskie", "kujawsko-pomorskie",
  "kujawsko-pomorskie", "kujawsko-pomorskie", "kujawsko-pomorskie",
  "kujawsko-pomorskie", "kujawsko-pomorskie", "kujawsko-pomorskie",
  "lubelskie", "lubelskie", "lubelskie", "lubelskie", "lubelskie",
  "lubelskie", "lubelskie", "lubelskie", "lubelskie", "lubelskie",
  "lubelskie", "lubelskie", "lubelskie", "lubelskie", "lubelskie",
  "lubelskie", "lubelskie", "lubelskie", "lubelskie", "lubelskie",
  "lubelskie", "lubelskie", "lubelskie", "lubelskie", "lubuskie",
  "lubuskie", "lubuskie", "lubuskie", "lubuskie", "lubuskie", "lubuskie",
  "lubuskie", "lubuskie", "lubuskie", "lubuskie", "lubuskie", "lubuskie",
  "lubuskie", "łódzkie", "łódzkie", "łódzkie", "łódzkie",
  "łódzkie", "łódzkie", "łódzkie", "łódzkie", "łódzkie",
  "łódzkie", "łódzkie", "łódzkie", "łódzkie", "łódzkie",
  "łódzkie", "łódzkie", "łódzkie", "łódzkie", "łódzkie",
  "łódzkie", "łódzkie", "łódzkie", "łódzkie", "łódzkie",
  "małopolskie", "małopolskie", "małopolskie", "małopolskie",
  "małopolskie", "małopolskie", "małopolskie", "małopolskie",
  "małopolskie", "małopolskie", "małopolskie", "małopolskie",
  "małopolskie", "małopolskie", "małopolskie", "małopolskie",
  "małopolskie", "małopolskie", "małopolskie", "małopolskie",
  "małopolskie", "małopolskie", "mazowieckie", "mazowieckie",
  "mazowieckie", "mazowieckie", "mazowieckie", "mazowieckie", "mazowieckie",
  "mazowieckie", "mazowieckie", "mazowieckie", "mazowieckie", "mazowieckie",
  "mazowieckie", "mazowieckie", "mazowieckie", "mazowieckie", "mazowieckie",
  "mazowieckie", "mazowieckie", "mazowieckie", "mazowieckie", "mazowieckie",
  "mazowieckie", "mazowieckie", "mazowieckie", "mazowieckie", "mazowieckie",
  "mazowieckie", "mazowieckie", "mazowieckie", "mazowieckie", "mazowieckie",
  "mazowieckie", "mazowieckie", "mazowieckie", "mazowieckie", "mazowieckie",
  "mazowieckie", "mazowieckie", "mazowieckie", "mazowieckie", "mazowieckie",
  "opolskie", "opolskie", "opolskie", "opolskie", "opolskie", "opolskie",
  "opolskie", "opolskie", "opolskie", "opolskie", "opolskie", "opolskie",
  "podkarpackie", "podkarpackie", "podkarpackie", "podkarpackie",
  "podkarpackie", "podkarpackie", "podkarpackie", "podkarpackie",
  "podkarpackie", "podkarpackie", "podkarpackie", "podkarpackie",
  "podkarpackie", "podkarpackie", "podkarpackie", "podkarpackie",
  "podkarpackie", "podkarpackie", "podkarpackie", "podkarpackie",
  "podkarpackie", "podkarpackie", "podkarpackie", "podkarpackie",
  "podkarpackie", "podlaskie", "podlaskie", "podlaskie", "podlaskie",
  "podlaskie", "podlaskie", "podlaskie", "podlaskie", "podlaskie",
  "podlaskie", "podlaskie", "podlaskie", "podlaskie", "podlaskie",
  "podlaskie", "podlaskie", "podlaskie", "pomorskie", "pomorskie",
  "pomorskie", "pomorskie", "pomorskie", "pomorskie", "pomorskie",
  "pomorskie", "pomorskie", "pomorskie", "pomorskie", "pomorskie",
  "pomorskie", "pomorskie", "pomorskie", "pomorskie", "pomorskie",
  "pomorskie", "pomorskie", "pomorskie", "śląskie", "śląskie",
  "śląskie", "śląskie", "śląskie", "śląskie", "śląskie",
  "śląskie", "śląskie", "śląskie", "śląskie", "śląskie",
  "śląskie", "śląskie", "śląskie", "śląskie", "śląskie",
  "śląskie", "śląskie", "śląskie", "śląskie", "śląskie",
  "śląskie", "śląskie", "śląskie", "śląskie", "śląskie",
  "śląskie", "śląskie", "śląskie", "śląskie", "śląskie",
  "śląskie", "śląskie", "śląskie", "śląskie", "świętokrzyskie",
  "świętokrzyskie", "świętokrzyskie", "świętokrzyskie", "świętokrzyskie",
  "świętokrzyskie", "świętokrzyskie", "świętokrzyskie", "świętokrzyskie",
  "świętokrzyskie", "świętokrzyskie", "świętokrzyskie", "świętokrzyskie",
  "świętokrzyskie", "warmińsko-mazurskie", "warmińsko-mazurskie",
  "warmińsko-mazurskie", "warmińsko-mazurskie", "warmińsko-mazurskie",
  "warmińsko-mazurskie", "warmińsko-mazurskie", "warmińsko-mazurskie",
  "warmińsko-mazurskie", "warmińsko-mazurskie", "warmińsko-mazurskie",
  "warmińsko-mazurskie", "warmińsko-mazurskie", "warmińsko-mazurskie",
  "warmińsko-mazurskie", "warmińsko-mazurskie", "warmińsko-mazurskie",
  "warmińsko-mazurskie", "warmińsko-mazurskie", "warmińsko-mazurskie",
  "warmińsko-mazurskie", "wielkopolskie", "wielkopolskie", "wielkopolskie",
  "wielkopolskie", "wielkopolskie", "wielkopolskie", "wielkopolskie",
  "wielkopolskie", "wielkopolskie", "wielkopolskie", "wielkopolskie",
  "wielkopolskie", "wielkopolskie", "wielkopolskie", "wielkopolskie",
  "wielkopolskie", "wielkopolskie", "wielkopolskie", "wielkopolskie",
  "wielkopolskie", "wielkopolskie", "wielkopolskie", "wielkopolskie",
  "wielkopolskie", "wielkopolskie", "wielkopolskie", "wielkopolskie",
  "wielkopolskie", "wielkopolskie", "wielkopolskie", "wielkopolskie",
  "wielkopolskie", "wielkopolskie", "wielkopolskie", "wielkopolskie",
  "zachodniopomorskie", "zachodniopomorskie", "zachodniopomorskie",
  "zachodniopomorskie", "zachodniopomorskie", "zachodniopomorskie",
  "zachodniopomorskie", "zachodniopomorskie", "zachodniopomorskie",
  "zachodniopomorskie", "zachodniopomorskie", "zachodniopomorskie",
  "zachodniopomorskie", "zachodniopomorskie", "zachodniopomorskie",
  "zachodniopomorskie", "zachodniopomorskie", "zachodniopomorskie",
  "zachodniopomorskie", "zachodniopomorskie", "zachodniopomorskie"
), powiat_miasto = c(
  "Cały kraj", "bolesławiecki", "dzierżoniowski",
  "głogowski", "górowski", "jaworski", "jeleniogórski", "kamiennogórski",
  "kłodzki", "legnicki", "lubański", "lubiński", "lwówecki",
  "milicki", "oleśnicki", "oławski", "polkowicki", "strzeliński",
  "średzki", "świdnicki", "trzebnicki", "wałbrzyski", "wołowski",
  "wrocławski", "ząbkowicki", "zgorzelecki", "złotoryjski",
  "Jelenia Góra", "Legnica", "Wrocław", "Wałbrzych", "aleksandrowski",
  "brodnicki", "bydgoski", "chełmiński", "golubsko-dobrzyński",
  "grudziądzki", "inowrocławski", "lipnowski", "mogileński",
  "nakielski", "radziejowski", "rypiński", "sępoleński", "świecki",
  "toruński", "tucholski", "wąbrzeski", "włocławski", "żniński",
  "Bydgoszcz", "Grudziądz", "Toruń", "Włocławek", "bialski",
  "biłgorajski", "chełmski", "hrubieszowski", "janowski", "krasnostawski",
  "kraśnicki", "lubartowski", "lubelski", "łęczyński", "łukowski",
  "opolski", "parczewski", "puławski", "radzyński", "rycki",
  "świdnicki", "tomaszowski", "włodawski", "zamojski", "Biała Podlaska",
  "Chełm", "Lublin", "Zamość", "gorzowski", "krośnieński",
  "międzyrzecki", "nowosolski", "słubicki", "strzelecko-drezdenecki",
  "sulęciński", "świebodziński", "zielonogórski", "żagański",
  "żarski", "wschowski", "Gorzów Wielkopolski", "Zielona Góra",
  "bełchatowski", "kutnowski", "łaski", "łęczycki", "łowicki",
  "łódzki wschodni", "opoczyński", "pabianicki", "pajęczański",
  "piotrkowski", "poddębicki", "radomszczański", "rawski", "sieradzki",
  "skierniewicki", "tomaszowski", "wieluński", "wieruszowski",
  "zduńskowolski", "zgierski", "brzeziński", "Łódź", "Piotrków Trybunalski",
  "Skierniewice", "bocheński", "brzeski", "chrzanowski", "dąbrowski",
  "gorlicki", "krakowski", "limanowski", "miechowski", "myślenicki",
  "nowosądecki", "nowotarski", "olkuski", "oświęcimski", "proszowicki",
  "suski", "tarnowski", "tatrzański", "wadowicki", "wielicki",
  "Kraków", "Nowy Sącz", "Tarnów", "białobrzeski", "ciechanowski",
  "garwoliński", "gostyniński", "grodziski", "grójecki", "kozienicki",
  "legionowski", "lipski", "łosicki", "makowski", "miński", "mławski",
  "nowodworski", "ostrołęcki", "ostrowski", "otwocki", "piaseczyński",
  "płocki", "płoński", "pruszkowski", "przasnyski", "przysuski",
  "pułtuski", "radomski", "siedlecki", "sierpecki", "sochaczewski",
  "sokołowski", "szydłowiecki", "warszawski zachodni", "węgrowski",
  "wołomiński", "wyszkowski", "zwoleński", "żuromiński", "żyrardowski",
  "Ostrołęka", "Płock", "Radom", "Siedlce", "Warszawa", "brzeski",
  "głubczycki", "kędzierzyńsko-kozielski", "kluczborski", "krapkowicki",
  "namysłowski", "nyski", "oleski", "opolski", "prudnicki", "strzelecki",
  "Opole", "bieszczadzki", "brzozowski", "dębicki", "jarosławski",
  "jasielski", "kolbuszowski", "krośnieński", "leżajski", "lubaczowski",
  "łańcucki", "mielecki", "niżański", "przemyski", "przeworski",
  "ropczycko-sędziszowski", "rzeszowski", "sanocki", "stalowowolski",
  "strzyżowski", "tarnobrzeski", "leski", "Krosno", "Przemyśl",
  "Rzeszów", "Tarnobrzeg", "augustowski", "białostocki", "bielski",
  "grajewski", "hajnowski", "kolneński", "łomżyński", "moniecki",
  "sejneński", "siemiatycki", "sokólski", "suwalski", "wysokomazowiecki",
  "zambrowski", "Białystok", "Łomża", "Suwałki", "bytowski",
  "chojnicki", "człuchowski", "gdański", "kartuski", "kościerski",
  "kwidzyński", "lęborski", "malborski", "nowodworski", "pucki",
  "słupski", "starogardzki", "tczewski", "wejherowski", "sztumski",
  "Gdańsk", "Gdynia", "Słupsk", "Sopot", "będziński", "bielski",
  "cieszyński", "częstochowski", "gliwicki", "kłobucki", "lubliniecki",
  "mikołowski", "myszkowski", "pszczyński", "raciborski", "rybnicki",
  "tarnogórski", "bieruńsko-lędziński", "wodzisławski", "zawierciański",
  "żywiecki", "Bielsko-Biała", "Bytom", "Chorzów", "Częstochowa",
  "Dąbrowa Górnicza", "Gliwice", "Jastrzębie-Zdrój", "Jaworzno",
  "Katowice", "Mysłowice", "Piekary Śląskie", "Ruda Śląska",
  "Rybnik", "Siemianowice Śląskie", "Sosnowiec", "Świętochłowice",
  "Tychy", "Zabrze", "Żory", "buski", "jędrzejowski", "kazimierski",
  "kielecki", "konecki", "opatowski", "ostrowiecki", "pińczowski",
  "sandomierski", "skarżyski", "starachowicki", "staszowski",
  "włoszczowski", "Kielce", "bartoszycki", "braniewski", "działdowski",
  "elbląski", "ełcki", "giżycki", "iławski", "kętrzyński",
  "lidzbarski", "mrągowski", "nidzicki", "nowomiejski", "olecki",
  "olsztyński", "ostródzki", "piski", "szczycieński", "gołdapski",
  "węgorzewski", "Elbląg", "Olsztyn", "chodzieski", "czarnkowsko-trzcianecki",
  "gnieźnieński", "gostyński", "grodziski", "jarociński", "kaliski",
  "kępiński", "kolski", "koniński", "kościański", "krotoszyński",
  "leszczyński", "międzychodzki", "nowotomyski", "obornicki",
  "ostrowski", "ostrzeszowski", "pilski", "pleszewski", "poznański",
  "rawicki", "słupecki", "szamotulski", "średzki", "śremski",
  "turecki", "wągrowiecki", "wolsztyński", "wrzesiński", "złotowski",
  "Kalisz", "Konin", "Leszno", "Poznań", "białogardzki", "choszczeński",
  "drawski", "goleniowski", "gryficki", "gryfiński", "kamieński",
  "kołobrzeski", "koszaliński", "myśliborski", "policki", "pyrzycki",
  "sławieński", "stargardzki", "szczecinecki", "świdwiński",
  "wałecki", "łobeski", "Koszalin", "Szczecin", "Świnoujście"
)), class = "data.frame", row.names = c(NA, -381L))

dd_final2 <- left_join(dd_final, wojs, "powiat_miasto")
dd_final2$wojewodztwo <- ifelse(is.na(dd_final2$wojewodztwo), dd_final2$powiat_miasto, dd_final2$wojewodztwo)

wojs2 <- c(
  "DOLNOŚLĄSKIE", "KUJAWSKO-POMORSKIE", "LUBELSKIE", "LUBUSKIE",
  "ŁÓDZKIE", "MAŁOPOLSKIE", "MAZOWIECKIE", "OPOLSKIE", "PODKARPACKIE",
  "PODLASKIE", "POMORSKIE", "ŚLĄSKIE", "ŚWIĘTOKRZYSKIE", "WARMIŃSKO-MAZURSKIE",
  "WIELKOPOLSKIE", "ZACHODNIOPOMORSKIE"
)

wojs_index <- dd_final2$wojewodztwo %in% c(wojs2)
pow_df_old <- dd_final2[!wojs_index, ]

woj_df_old <- dd_final2[wojs_index, ]
woj_df_old$powiat_miasto <- NULL
woj_df_old$wojewodztwo <- str_to_lower(woj_df_old$wojewodztwo)
woj_df_old <- rbind(woj_df_old, dd_final2[dd_final2$wojewodztwo == "Cały kraj", -4])
woj_df_old <- woj_df_old[order(woj_df_old$Date), ]

pow_df_old <- pow_df_old %>% arrange(Date) %>% group_by(powiat_miasto) %>% mutate(liczba_przypadkow = c(NA, diff(liczba_przypadkow)),
                                                                    zgony = c(NA, diff(zgony)) )
woj_df_old <- woj_df_old %>% arrange(Date) %>% group_by(wojewodztwo) %>% mutate(liczba_przypadkow = c(NA, diff(liczba_przypadkow)),
                                                                                zgony = c(NA, diff(zgony)) )

woj_df_old$liczba_przypadkow[woj_df_old$liczba_przypadkow < 0] <- NA
woj_df_old$zgony[woj_df_old$zgony < 0] <- NA
pow_df_old$liczba_przypadkow[pow_df_old$liczba_przypadkow < 0] <- NA
pow_df_old$zgony[pow_df_old$zgony < 0] <- NA

write.csv(woj_df_old, "old_mrogalski/woj_df_old.csv", row.names = FALSE)
write.csv(pow_df_old, "old_mrogalski/pow_df_old.csv", row.names = FALSE)
