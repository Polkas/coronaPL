# coronaPL
corona virus data from Polish government and more.

## shiny App 

check the /shiny directory.  
URL: https://polkas.shinyapps.io/c19PL/

The app is targeting Polish people so it is written with polish descriptions. The main objective was to develop a mobile app for everyday monitoring of the local coronavirus pandemic stage in Poland. Some of the used packages: leaflet, sparkline, data.table and miniUI.
I decided to build a mobile phone suited app to check the coronavirus pandemic stage in the specific local area. People were less mobile last time so they should mostly care about the pandemic stage in their local area. I was inspired by the apps which offer similar functionality although for quality of air. The main objective was to make the app useful for everyday usage so as to be suited for mobile phones. The local risk is estimated as a quantile from the empirical distribution of the infection value per 10,000. residents in a specific district.

## Data COVID19 GOV

URL GOV: https://www.gov.pl/web/koronawirus/wykaz-zarazen-koronawirusem-sars-cov-2
  
URL GOV Description: https://www.gov.pl/web/koronawirus/metodologia  

**File `gov/govDATA.R` data extraction.**

**Everyday update of the data around 09:00 UTC** - using pythonanywhere.com servers

Merged data with proper formatting:
**Data Wojewodztwa: `gov/data/woj_df.csv`**  
**Data Powiaty: `gov/data/pow_df.csv`**

gov.pl data are published since `2020-11-23`.

Older data is available e.g. Michała Rogalski GS: https://docs.google.com/spreadsheets/d/1Tv6jKMUYdK6ws6SxxAsHVxZbglZfisC8x_HZ1jacmBM/edit#gid=1169869581. 
Be careful as this data contains possible bugs.

### Quick Usage

Usage:

**R**

```r
library(data.table)
pow_df <- fread("https://raw.githubusercontent.com/Polkas/coronaPL/main/gov/data/pow_df.csv")
pow_df_full <- fread("https://raw.githubusercontent.com/Polkas/coronaPL/main/gov/data/pow_df_full.csv")

woj_df <- fread("https://raw.githubusercontent.com/Polkas/coronaPL/main/gov/data/woj_df.csv")
```

**python**

```python
import pandas as pd
pow_df = pd.read_csv("https://raw.githubusercontent.com/Polkas/coronaPL/main/gov/data/pow_df.csv")
pow_df_full = pd.read_csv("https://raw.githubusercontent.com/Polkas/coronaPL/main/gov/data/pow_df_full.csv")

woj_df = pd.read_csv("https://raw.githubusercontent.com/Polkas/coronaPL/main/gov/data/woj_df.csv")
```

## Spatial Analysis

In development

Example (deaths on COVID19 across time and districts):  
![](spatial/images/zgonyPL.gif)
* Dates on publication day
