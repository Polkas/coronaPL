# coronaPL
corona virus data from Polish government and more.

### Shiny App with powiat Covid19 data in POLAND

[c19lokalnie](https://polkas.shinyapps.io/c19lokalnie/)

### Quick COVID19 GOV Data Usage

gov.pl data are published since `2020-11-23`.
powiaty connected and all vaccination data are not updated from `05-2022`. 


**R**

```r
library(data.table)

woj_df <- fread("https://raw.githubusercontent.com/Polkas/coronaPL/main/gov/data/woj_df.csv.gz")

# infections
pow_df <- fread("https://raw.githubusercontent.com/Polkas/coronaPL/main/gov/data/pow_df.csv.gz")
pow_df_full <- fread("https://raw.githubusercontent.com/Polkas/coronaPL/main/gov/data/pow_df_full.csv.gz")
# vaccinations
pow_df_vac <- fread("https://raw.githubusercontent.com/Polkas/coronaPL/main/gov/data/pow_df_vac.csv.gz")
woj_df_vac <- fread("https://raw.githubusercontent.com/Polkas/coronaPL/main/gov/data/woj_df_vac.csv.gz")
```

**python**

```python
import pandas as pd

woj_df = pd.read_csv("https://raw.githubusercontent.com/Polkas/coronaPL/main/gov/data/woj_df.csv.gz")

# infections
pow_df = pd.read_csv("https://raw.githubusercontent.com/Polkas/coronaPL/main/gov/data/pow_df.csv.gz")
pow_df_full = pd.read_csv("https://raw.githubusercontent.com/Polkas/coronaPL/main/gov/data/pow_df_full.csv.gz", encoding_errors='ignore')
# vaccinations
pow_df_vac = pd.read_csv("https://raw.githubusercontent.com/Polkas/coronaPL/main/gov/data/pow_df_vac.csv.gz")
woj_df_vac = pd.read_csv("https://raw.githubusercontent.com/Polkas/coronaPL/main/gov/data/woj_df_vac.csv.gz")
```

## Data COVID19 GOV

URL GOV: https://www.gov.pl/web/koronawirus/wykaz-zarazen-koronawirusem-sars-cov-2
URL GOV Description: https://www.gov.pl/web/koronawirus/metodologia  

GOV vaccination Data: https://www.gov.pl/web/szczepimysie/raport-szczepien-przeciwko-covid-19

**File `gov/govDATA.R`/`gov/govDATA.py` data extraction.**

Older data is available e.g. Michała Rogalski GS: https://docs.google.com/spreadsheets/d/1Tv6jKMUYdK6ws6SxxAsHVxZbglZfisC8x_HZ1jacmBM/edit#gid=1169869581. 
Be careful as this data contains possible bugs.
Vaccination Data: https://docs.google.com/spreadsheets/d/19DqluO7mmKrheqBDRD2ZFM2ZLSi4YTW2nwLbPHkiTYU

