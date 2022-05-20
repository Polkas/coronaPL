# -*- coding: utf-8 -*-
import os
import zipfile
import tempfile
import glob
import collections
from govDataUtils.funs import get_plgov_cols, process_gov, list2gzip, get_url

os.chdir("./gov")

MAIN_URL = "https://arcgis.com/sharing/rest/content/items/"
# Looks to be stable
WOJ_SHA = "a8c562ead9c54e13a135b02e0d875ffb"
WOJ_SHA_OLD = "b03b454aed9b4154ba50df4ba9e1143b"
POW_SHA = "e16df1fa98c2452783ec10b0aea4b341"
ALL_VAC_SHA = "b860f2797f7f4da789cb6fccf6bd5bc7"

POL_ENCODING = "Windows-1250"
PATH_DATA = tempfile.mkdtemp()

ALL_ID = "cały kraj"
WOJ_VAR = "wojewodztwo"
POW_VAR = "powiat_miasto"

PATH_RES = "./data"
PATH_RES_POW1 = "./data/pow_df.csv.gz"
PATH_RES_POW2 = "./data/pow_df_full.csv.gz"
PATH_RES_WOJ = "./data/woj_df.csv.gz"
PATH_RES_POW_VAC = "./data/pow_df_vac.csv.gz"
PATH_RES_WOJ_VAC = "./data/woj_df_vac.csv.gz"

try:   
    os.remove(PATH_RES_POW1)
    os.remove(PATH_RES_POW2)
    os.remove(PATH_RES_WOJ)
    os.remove(PATH_RES_POW_VAC)
    os.remove(PATH_RES_WOJ_VAC)
except:
    None

try:
    os.mkdir(PATH_RES)
except:
    None

zip_path, _ = get_url(MAIN_URL + POW_SHA + "/data")
with zipfile.ZipFile(zip_path, "r") as f:
    f.extractall(PATH_DATA)

zip_path, _ = get_url(MAIN_URL + WOJ_SHA + "/data")
with zipfile.ZipFile(zip_path, "r") as f:
    f.extractall(PATH_DATA)

zip_path, _ = get_url(MAIN_URL + ALL_VAC_SHA + "/data")
with zipfile.ZipFile(zip_path, "r") as f:
    f.extractall(PATH_DATA)

# Powiat
pow_files = sorted(glob.glob(f'{PATH_DATA}/*_pow_eksport.csv'))
headers = get_plgov_cols(pow_files, ALL_ID)
base_cols_p = ["wojewodztwo", "powiat_miasto", "liczba_przypadkow", "liczba_na_10_tys_mieszkancow",
"zgony","stan_rekordu_na", "Date", "name"]
cols_p = list(collections.OrderedDict().fromkeys(base_cols_p + headers).keys())
pow_row = collections.namedtuple('pow_row', cols_p)

pow_mapp = {"liczba_wszystkich_zakazen":"liczba_przypadkow",
            "liczba_wszystkich_zakazen_na_10_tys_mieszkancow":"liczba_na_10_tys_mieszkancow",
            "powiat":"powiat_miasto"}
res = process_gov(pow_files, ["20210107"], pow_mapp, pow_row, 1, ALL_ID)

list2gzip(PATH_RES_POW1, res, cols_p, 7)
list2gzip(PATH_RES_POW2, res, cols_p, len(cols_p))

# Wojewodztwo
woj_files = sorted(glob.glob(f'{PATH_DATA}/*_woj_eksport.csv'))
headers = get_plgov_cols(woj_files, ALL_ID)
base_cols_w = ["wojewodztwo", "liczba_przypadkow", "liczba_na_10_tys_mieszkancow",
"zgony","stan_rekordu_na", "Date", "name"]
cols_w = list(collections.OrderedDict().fromkeys(base_cols_w + headers).keys())
woj_row = collections.namedtuple('woj_row', cols_w)
woj_mapp = {"liczba_wszystkich_zakazen":"liczba_przypadkow",
            "liczba_wszystkich_zakazen_na_10_tys_mieszkancow":"liczba_na_10_tys_mieszkancow"}

res = process_gov(woj_files, ["20210107"], woj_mapp, woj_row, 1, ALL_ID)

list2gzip(PATH_RES_WOJ, res, cols_w, len(cols_w))

# Powiat Vac
pow_vac_files = sorted(glob.glob(f'{PATH_DATA}/*_pow_szczepienia.csv'))
headers = get_plgov_cols(pow_vac_files, ALL_ID)
base_cols_p_v = ['wojewodztwo', 'powiat_miasto', 'liczba_szczepien_ogolem', 'liczba_szczepien_ogolnie',
                 'dawka_1_ogolem', 'dawka_2_ogolem', 'dawka_3_ogolem', 'dawka_1_dziennie', 'dawka_2_dziennie',
                 'dawka_3_dziennie', 'dawka_przypominajaca_dziennie', 'liczba_szczepien_dziennie',
                 'dawka_przypominajaca_ogolem', 'teryt', "name", "Date", "stan_rekordu_na"]
cols_p_v = list(collections.OrderedDict().fromkeys(base_cols_p_v + headers).keys())
pow_row_v = collections.namedtuple('woj_row', cols_p_v)

res = process_gov(pow_vac_files, ["20210107"], {}, pow_row_v, -1, ALL_ID)

list2gzip(PATH_RES_POW_VAC, res, cols_p_v, len(cols_p_v))

# Wojewodztwo Vac
woj_vac_files = sorted(glob.glob(f'{PATH_DATA}/*_woj_szczepienia.csv'))
headers = get_plgov_cols(woj_vac_files, ALL_ID)
base_cols_p_v = ['wojewodztwo', 'liczba_szczepien_ogolem', 'liczba_szczepien_ogolnie', 'dawka_1_ogolem',
                 'dawka_2_ogolem', 'dawka_3_ogolem', 'dawka_1_dziennie', 'dawka_2_dziennie', 'dawka_3_dziennie',
                 'dawka_przypominajaca_dziennie', 'liczba_szczepien_dziennie', 'dawka_przypominajaca_ogolem',
                 'teryt', "name", "Date", "stan_rekordu_na"]
cols_w_v = list(collections.OrderedDict().fromkeys(base_cols_p_v + headers).keys())
woj_row_v = collections.namedtuple('woj_row', cols_w_v)

res = process_gov(woj_vac_files, ["20210107"], {}, woj_row_v, -1, ALL_ID)

list2gzip(PATH_RES_WOJ_VAC, res, cols_w_v, len(cols_w_v))
