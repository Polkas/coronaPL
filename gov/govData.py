# -*- coding: utf-8 -*-
import os
os.chdir("./gov")
from govDataUtils.funs import *

main_url = "https://arcgis.com/sharing/rest/content/items/"
# Looks to be stable
woj_sha = "a8c562ead9c54e13a135b02e0d875ffb"
woj_sha_old = "b03b454aed9b4154ba50df4ba9e1143b"
pow_sha = "e16df1fa98c2452783ec10b0aea4b341"
all_vac_sha = "b860f2797f7f4da789cb6fccf6bd5bc7"

pol_encoding = "Windows-1250"
path_data = tempfile.mkdtemp()

path_res = "./gov/data"
path_res_pow1 = "./gov/data/pow_df.csv.gz"
path_res_pow2 = "./gov/data/pow_df_full.csv.gz"
path_res_woj = "./gov/data/woj_df.csv.gz"
path_res_pow_vac = "./gov/data/pow_df_vac.csv.gz"
path_res_woj_vac = "./gov/data/woj_df_vac.csv.gz"

try:   
  os.remove(path_res_pow1)
  os.remove(path_res_pow2)
  os.remove(path_res_woj)
  os.remove(path_res_pow_vac)
  os.remove(path_res_woj_vac)
except:
  None
  
tempzip = tempfile.TemporaryFile(suffix = ".zip")
all_id = "cały kraj"
woj_var = "wojewodztwo"
pow_var = "powiat_miasto"

try:
  os.mkdir(path_res)
except:
  None
  
zip_path, _ = urllib.request.urlretrieve(main_url + pow_sha + "/data")
with zipfile.ZipFile(zip_path, "r") as f:
    f.extractall(path_data)

zip_path, _ = urllib.request.urlretrieve(main_url + woj_sha + "/data")
with zipfile.ZipFile(zip_path, "r") as f:
    f.extractall(path_data)

zip_path, _ = urllib.request.urlretrieve(main_url + all_vac_sha + "/data")
with zipfile.ZipFile(zip_path, "r") as f:
    f.extractall(path_data)

# Powiat
pow_files = sorted(glob.glob('{path_data}/*_pow_eksport.csv'.format(path_data = path_data)))
headers = get_plgov_cols(pow_files, all_id)
base_cols_p = ["wojewodztwo", "powiat_miasto", "liczba_przypadkow", "liczba_na_10_tys_mieszkancow",
"zgony","stan_rekordu_na", "Date", "name"]
cols_p = list(collections.OrderedDict().fromkeys(base_cols_p + headers).keys())
pow_row = collections.namedtuple('pow_row', 
cols_p
)

pow_mapp = {"liczba_wszystkich_zakazen":"liczba_przypadkow","liczba_wszystkich_zakazen_na_10_tys_mieszkancow":"liczba_na_10_tys_mieszkancow"}
res = process_gov(pow_files, ["20210107"], pow_mapp, pow_row, 1, all_id)

list2gzip(path_res_pow1, res, cols_p, 7)
list2gzip(path_res_pow2, res, cols_p, len(cols_p))

# Wojewodztwo
woj_files = sorted(glob.glob('{path_data}/*_woj_eksport.csv'.format(path_data = path_data)))
headers = get_plgov_cols(woj_files, all_id)
base_cols_w = ["wojewodztwo", "liczba_przypadkow", "liczba_na_10_tys_mieszkancow",
"zgony","stan_rekordu_na", "Date", "name"]
cols_w = list(collections.OrderedDict().fromkeys(base_cols_w + headers).keys())
woj_row = collections.namedtuple('woj_row', 
cols_w
)
woj_mapp = {"liczba_wszystkich_zakazen":"liczba_przypadkow","liczba_wszystkich_zakazen_na_10_tys_mieszkancow":"liczba_na_10_tys_mieszkancow"}

res = process_gov(woj_files, ["20210107"], woj_mapp, woj_row, 1, all_id)

list2gzip(path_res_woj, res, cols_w, len(cols_w))

# Powiat Vac
pow_vac_files = sorted(glob.glob('{path_data}/*_pow_szczepienia.csv'.format(path_data = path_data)))
headers = get_plgov_cols(pow_vac_files, all_id)
base_cols_p_v = [ 'wojewodztwo', 'powiat_miasto', 'liczba_szczepien_ogolem', 'liczba_szczepien_ogolnie', 'dawka_1_ogolem', 'dawka_2_ogolem', 'dawka_3_ogolem', 'dawka_1_dziennie', 'dawka_2_dziennie', 'dawka_3_dziennie', 'dawka_przypominajaca_dziennie', 'liczba_szczepien_dziennie', 'dawka_przypominajaca_ogolem', 'teryt', "name", "Date", "stan_rekordu_na"]
cols_p_v = list(collections.OrderedDict().fromkeys(base_cols_p_v + headers).keys())
pow_row_v = collections.namedtuple('woj_row', 
cols_p_v
)

res = process_gov(pow_vac_files, ["20210107"], {}, pow_row_v, -1, all_id)

list2gzip(path_res_pow_vac, res, cols_p_v, len(cols_p_v))

# Wojewodztwo Vac
woj_vac_files = sorted(glob.glob('{path_data}/*_woj_szczepienia.csv'.format(path_data = path_data)))
headers = get_plgov_cols(woj_vac_files, all_id)
base_cols_p_v = [ 'wojewodztwo', 'liczba_szczepien_ogolem', 'liczba_szczepien_ogolnie', 'dawka_1_ogolem', 'dawka_2_ogolem', 'dawka_3_ogolem', 'dawka_1_dziennie', 'dawka_2_dziennie', 'dawka_3_dziennie', 'dawka_przypominajaca_dziennie', 'liczba_szczepien_dziennie', 'dawka_przypominajaca_ogolem', 'teryt', "name", "Date", "stan_rekordu_na"]
cols_w_v = list(collections.OrderedDict().fromkeys(base_cols_p_v + headers).keys())
woj_row_v = collections.namedtuple('woj_row', 
cols_w_v
)

res = process_gov(woj_vac_files, ["20210107"], {}, woj_row_v, -1, all_id)

list2gzip(path_res_woj_vac, res, cols_w_v, len(cols_w_v))
