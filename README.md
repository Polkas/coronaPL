# coronaPL
corona virus data from Polish government and more.

## Dane COVID19 GOV

URL GOV: https://www.gov.pl/web/koronawirus/wykaz-zarazen-koronawirusem-sars-cov-2  
URL GOV Description:https://www.gov.pl/web/koronawirus/metodologia  

**Plik `gov/govDATA.R` pozyskanie danych.**

**Dane są codziennie automatycznie aktualizowane o 10:10 UTC** - pythonanywhere.com servers

Połączone pliki z archiwum gov wraz z poprawnym formatowaniem polskich znaków.  
**Date Wojewodztwa: `gov/data/woj_df.csv`**  
**Date Powiaty: `gov/data/pow_df.csv`**

Dane gov.pl dla powiatów i wojewodztw publikowane są od dnia `2020-11-23`.
Wczesniejsze dane dla liczby przypadkow i zgonow zostaly dodane ze strony Michała Rogalskiego: https://docs.google.com/spreadsheets/d/1Tv6jKMUYdK6ws6SxxAsHVxZbglZfisC8x_HZ1jacmBM/edit#gid=1169869581.

### Quick Usage

Usage:

**R**

```r
library(data.table)
pow_df <- fread("https://raw.githubusercontent.com/Polkas/coronaPL/main/gov/data/pow_df.csv")

woj_df <- fread("https://raw.githubusercontent.com/Polkas/coronaPL/main/gov/data/woj_df.csv")
```

**python**

```python
import pandas as pd
pow_df = pd.read_csv("https://raw.githubusercontent.com/Polkas/coronaPL/main/gov/data/pow_df.csv")

woj_df = pd.read_csv("https://raw.githubusercontent.com/Polkas/coronaPL/main/gov/data/woj_df.csv")
```

## Spatial Analysis

in development

Przykład (zgony na COVID19 na przestrzeni powiatów oraz czasu):  
![](spatial/images/zgonyPL.gif)

*Daty na dzień publikacji

## shiny App 

in development
