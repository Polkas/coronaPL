# coronaPL
corona virus data from Polish government and more.

## Dane COVID19 GOV

URL GOV: https://www.gov.pl/web/koronawirus/wykaz-zarazen-koronawirusem-sars-cov-2  
URL GOVDescription:https://www.gov.pl/web/koronawirus/metodologia  

**Plik `gov/govDATA.R` pozyskanie danych.**

Połączone pliki z archiwum gov wraz z poprawnym formatowaniem polskich znaków.  
**Date Wojewodztwa: `gov/data/woj_df.csv`**  
**Date Powiaty: `gov/data/pow_df.csv`**

Pliki można wykorzystać do stworzenia DB. 
Następnie dane dzienne moga byc dodawane np. poprzez skrypt uruchamiany przez `cron`.
Przykładowy skrypt do tego celu `gov/govDATAdailyupdate.R`.

## Spatial Analysis

in development

Przykład (zgony na COVID19 na przestrzeni powiatów oraz czasu):  
![](spatial/images/zgonyPL.gif)

*Daty na dzień publikacji

## shiny App 

in development
