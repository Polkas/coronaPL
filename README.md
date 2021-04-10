# coronaPL
corona virus data from Polish government and more.

DATA: https://www.gov.pl/web/koronawirus/wykaz-zarazen-koronawirusem-sars-cov-2  
Description:https://www.gov.pl/web/koronawirus/metodologia  
Plik `govDATA.R` pozyskanie danych.

Date Wojewodztwa: `data/woj_df.csv`  
Date Powiaty: `data/pow_df.csv`

Pliki mozna wykorzystac do stworzenia DB. 
Nastepnie dane dzienne moga byc dodawane np. poprzez skrypt uruchamiany przez `cron`.
Przykladowy skrypt do tego celu `govDATAdailyupdate.R`.

Dane dzienne pod linkami:  
- Woj: https://www.arcgis.com/sharing/rest/content/items/153a138859bb4c418156642b5b74925b/data  
- Pow: https://www.arcgis.com/sharing/rest/content/items/6ff45d6b5b224632a672e764e04e8394/data
