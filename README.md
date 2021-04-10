# coronaPL
corona virus data from Polish government and more.

URL GOV: https://www.gov.pl/web/koronawirus/wykaz-zarazen-koronawirusem-sars-cov-2  
URL GOVDescription:https://www.gov.pl/web/koronawirus/metodologia  

**Plik `govDATA.R` pozyskanie danych.**

Połączone pliki z archiwum gov wraz z poprawnym formatowaniem polskich znaków.  
**Date Wojewodztwa: `data/woj_df.csv`**  
**Date Powiaty: `data/pow_df.csv`**

Pliki można wykorzystać do stworzenia DB. 
Następnie dane dzienne moga byc dodawane np. poprzez skrypt uruchamiany przez `cron`.
Przykładowy skrypt do tego celu `govDATAdailyupdate.R`.
