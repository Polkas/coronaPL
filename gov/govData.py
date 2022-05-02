# -*- coding: utf-8 -*-
import os
import tempfile
import urllib
import zipfile
import glob
import gzip
import csv
import collections
import datetime

def list2gzip(path, data_list, cols, n_cols, encoding = "utf-8"):
  assert isinstance(path, str)
  assert isinstance(data_list, list)
  assert isinstance(cols, list)
  with gzip.open(path, 'w') as file:
    file.write((",".join(cols[:(n_cols + 1)]) + "\n").encode(encoding))
    file.writelines([(",".join(l[:(n_cols + 1)]) + "\n").encode(encoding) for l in data_list])

main_url = "https://arcgis.com/sharing/rest/content/items/"
# Looks to be stable
woj_sha = "a8c562ead9c54e13a135b02e0d875ffb"
woj_sha_old = "b03b454aed9b4154ba50df4ba9e1143b"
pow_sha = "e16df1fa98c2452783ec10b0aea4b341"
all_vac_sha = "b860f2797f7f4da789cb6fccf6bd5bc7"

pol_encoding = "Windows-1250"
path_data = tempfile.TemporaryDirectory().name

path_res = "gov/data"
path_res_pow1 = "gov/data/pow_df.csv.gz"
path_res_pow2 = "gov/data/pow_df_full.csv.gz"
path_res_woj = "gov/data/woj_df.csv.gz"
path_res_pow_vac = "gov/data/pow_df_vac.csv.gz"
path_res_woj_vac = "gov/data/woj_df_vac.csv.gz"

try:   
  os.remove(path_res_pow1)
  os.remove(path_res_pow2)
  os.remove(path_res_woj)
  os.remove(path_res_pow_vac)
  os.remove(path_res_woj_vac)
except:
  None
  
tempzip = tempfile.TemporaryFile(suffix = ".zip")
all_id = ["cały kraj", "Cały kraj", "Cały Kraj"]
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
headers = list()
for file in pow_files:
  with open(file, "rb") as csvfile:
    csv_lines = csvfile.readlines()
    row1 = csv_lines[1].strip().split(b";")
    try:
      if row1[0].decode("utf-8") in all_id:
        ee = "utf-8"
      else:
        ee = pol_encoding
    except:
      ee = pol_encoding
    header = [h.strip('"') for h in csv_lines[0].decode(ee).strip().split(";")]
    headers = list(set(headers + header))
    
base_cols_p = ["wojewodztwo", "powiat_miasto", "liczba_przypadkow", "liczba_na_10_tys_mieszkancow",
"zgony","stan_rekordu_na", "Date", "name"]
cols_p = list(collections.OrderedDict().fromkeys(base_cols_p + list(headers)).keys())

pow_row = collections.namedtuple('pow_row', 
cols_p
)

res = list()
for idx, file in enumerate(pow_files):
  file_basename = os.path.basename(file)
  file_basename8 = file_basename[:8]
  file_date = datetime.date(int(file_basename[:4]), int(file_basename[4:6]), int(file_basename[6:8]))
  stan_rekordu_na = str(file_date - datetime.timedelta(days=1))
  file_date = str(file_date)
  if file_basename8 == "20210107":
    continue
  with open(file, "rb") as csvfile:
    csv_lines = csvfile.readlines()
    row1 = csv_lines[1].strip().split(b";")
    try:
      if row1[0].decode("utf-8") in all_id:
        ee = "utf-8"
      else:
        ee = pol_encoding
    except:
      ee = pol_encoding
    header = [h.strip('"') for h in csv_lines[0].decode(ee).strip().split(";")]
    for rowb in csv_lines[1:]:
      row = [r.strip('"') for r in rowb.decode(ee).strip().split(";")]
      row_dict = dict(zip(header, row))
      row_dict["name"] = file_basename
      row_dict["Date"] = file_date
      row_dict["stan_rekordu_na"] = stan_rekordu_na
      if "powiat" not in row_dict.keys():
        row_dict["powiat"] = row_dict["powiat_miasto"]
      if "powiat_miasto" not in row_dict.keys():
        row_dict["powiat_miasto"] = row_dict["powiat"]
      if "liczba_wszystkich_zakazen" not in row_dict.keys():
        row_dict["liczba_wszystkich_zakazen"] = row_dict["liczba_przypadkow"]
      if "liczba_wszystkich_zakazen_na_10_tys_mieszkancow" not in row_dict.keys():
        row_dict["liczba_wszystkich_zakazen_na_10_tys_mieszkancow"] = row_dict["liczba_na_10_tys_mieszkancow"]
      if "liczba_przypadkow" not in row_dict.keys():
        row_dict["liczba_przypadkow"] = row_dict["liczba_wszystkich_zakazen"]
      if "liczba_na_10_tys_mieszkancow" not in row_dict.keys():
        row_dict["liczba_na_10_tys_mieszkancow"] = row_dict["liczba_wszystkich_zakazen_na_10_tys_mieszkancow"]
      lacks = set(cols_p) - set(row_dict.keys())
      if len(lacks) > 0:
        for ll in lacks:
          row_dict[ll] = ""
      res_row = list(pow_row(**row_dict))
      res.append(res_row)

list2gzip(path_res_pow1, res, cols_p, 7)
list2gzip(path_res_pow2, res, cols_p, len(cols_p))

# Wojewodztwo

woj_files = sorted(glob.glob('{path_data}/*_woj_eksport.csv'.format(path_data = path_data)))
headers = list()
for file in woj_files:
  with open(file, "rb") as csvfile:
    csv_lines = csvfile.readlines()
    row1 = csv_lines[1].strip().split(b";")
    try:
      if row1[0].decode("utf-8") in all_id:
        ee = "utf-8"
      else:
        ee = pol_encoding
    except:
      ee = pol_encoding
    header = [h.strip('"') for h in csv_lines[0].decode(ee).strip().split(";")]
    headers = list(set(headers + header))

base_cols_w = ["wojewodztwo", "liczba_przypadkow", "liczba_na_10_tys_mieszkancow",
"zgony","stan_rekordu_na", "Date", "name"]
cols_w = list(collections.OrderedDict().fromkeys(base_cols_w + list(headers)).keys())

woj_row = collections.namedtuple('woj_row', 
cols_w
)

res = list()
for idx, file in enumerate(woj_files):
  file_basename = os.path.basename(file)
  file_date = datetime.date(int(file_basename[:4]), int(file_basename[4:6]), int(file_basename[6:8]))
  stan_rekordu_na = str(file_date - datetime.timedelta(days=1))
  file_date = str(file_date)
  if file_basename[:8] == "20210107":
    continue
  with open(file, "rb") as csvfile:
    csv_lines = csvfile.readlines()
    row1 = csv_lines[1].strip().split(b";")
    try:
      if row1[0].decode("utf-8") in all_id:
        ee = "utf-8"
      else:
        ee = pol_encoding
    except:
      ee = pol_encoding
    header = [h.strip('"') for h in csv_lines[0].decode(ee).strip().split(";")]
    for rowb in csv_lines[1:]:
      row = [r.strip('"') for r in rowb.decode(ee).strip().split(";")]
      row_dict = dict(zip(header, row))
      row_dict["name"] = file_basename
      row_dict["Date"] = file_date
      row_dict["stan_rekordu_na"] = stan_rekordu_na
      if "liczba_wszystkich_zakazen" not in row_dict.keys():
        row_dict["liczba_wszystkich_zakazen"] = row_dict["liczba_przypadkow"]
      if "liczba_wszystkich_zakazen_na_10_tys_mieszkancow" not in row_dict.keys():
        row_dict["liczba_wszystkich_zakazen_na_10_tys_mieszkancow"] = row_dict["liczba_na_10_tys_mieszkancow"]
      if "liczba_przypadkow" not in row_dict.keys():
        row_dict["liczba_przypadkow"] = row_dict["liczba_wszystkich_zakazen"]
      if "liczba_na_10_tys_mieszkancow" not in row_dict.keys():
        row_dict["liczba_na_10_tys_mieszkancow"] = row_dict["liczba_wszystkich_zakazen_na_10_tys_mieszkancow"]
      lacks = set(cols_w) - set(row_dict.keys())
      if len(lacks) > 0:
        for ll in lacks:
          row_dict[ll] = ""
      res_row = list(woj_row(**row_dict))
      res.append(res_row)

list2gzip(path_res_woj, res, cols_w, len(cols_w))

# Powiat Vac

pow_vac_files = sorted(glob.glob('{path_data}/*_pow_szczepienia.csv'.format(path_data = path_data)))
headers = list()
for file in pow_vac_files:
  with open(file, "rb") as csvfile:
    csv_lines = csvfile.readlines()
    row1 = csv_lines[1].strip().split(b";")
    try:
      if row1[0].decode("utf-8") in all_id:
        ee = "utf-8"
      else:
        ee = pol_encoding
    except:
      ee = pol_encoding
    header = [h.strip('"') for h in csv_lines[0].decode(ee).strip().split(";")]
    headers = list(set(headers + header))

base_cols_p_v = [ 'wojewodztwo', 'powiat_miasto', 'liczba_szczepien_ogolem', 'liczba_szczepien_ogolnie', 'dawka_1_ogolem', 'dawka_2_ogolem', 'dawka_3_ogolem', 'dawka_1_dziennie', 'dawka_2_dziennie', 'dawka_3_dziennie', 'dawka_przypominajaca_dziennie', 'liczba_szczepien_dziennie', 'dawka_przypominajaca_ogolem', 'teryt', "name", "Date", "stan_rekordu_na"]
cols_p_v = list(collections.OrderedDict().fromkeys(base_cols_p_v + list(headers)).keys())

pow_row_v = collections.namedtuple('woj_row', 
cols_p_v
)

res = list()
for idx, file in enumerate(pow_vac_files):
  file_basename = os.path.basename(file)
  file_date = datetime.date(int(file_basename[:4]), int(file_basename[4:6]), int(file_basename[6:8]))
  stan_rekordu_na = str(file_date - datetime.timedelta(days=1))
  file_date = str(file_date)
  if file_basename[:8] == "20210107":
    continue
  with open(file, "rb") as csvfile:
    csv_lines = csvfile.readlines()
    rowl = csv_lines[-1].strip().split(b";")
    try:
      if rowl[0].decode("utf-8") in all_id:
        ee = "utf-8"
      else:
        ee = pol_encoding
    except:
      ee = pol_encoding
    header = [h.strip('"') for h in csv_lines[0].decode(ee).strip().split(";")]
    for rowb in csv_lines[1:]:
      row = [r.strip('"') for r in rowb.decode(ee).strip().split(";")]
      row_dict = dict(zip(header, row))
      row_dict["name"] = file_basename
      row_dict["Date"] = file_date
      row_dict["stan_rekordu_na"] = stan_rekordu_na
      lacks = set(cols_p_v) - set(row_dict.keys())
      if len(lacks) > 0:
        for ll in lacks:
          row_dict[ll] = ""
      res_row = list(pow_row_v(**row_dict))
      res.append(res_row)

list2gzip(path_res_pow_vac, res, cols_p_v, len(cols_p_v))

# Wojewodztwo Vac

woj_vac_files = sorted(glob.glob('{path_data}/*_woj_szczepienia.csv'.format(path_data = path_data)))
headers = list()
for file in woj_vac_files:
  with open(file, "rb") as csvfile:
    csv_lines = csvfile.readlines()
    row1 = csv_lines[1].strip().split(b";")
    try:
      if row1[0].decode("utf-8") in all_id:
        ee = "utf-8"
      else:
        ee = pol_encoding
    except:
      ee = pol_encoding
    header = [h.strip('"') for h in csv_lines[0].decode(ee).strip().split(";")]
    headers = list(set(headers + header))

base_cols_p_v = [ 'wojewodztwo', 'liczba_szczepien_ogolem', 'liczba_szczepien_ogolnie', 'dawka_1_ogolem', 'dawka_2_ogolem', 'dawka_3_ogolem', 'dawka_1_dziennie', 'dawka_2_dziennie', 'dawka_3_dziennie', 'dawka_przypominajaca_dziennie', 'liczba_szczepien_dziennie', 'dawka_przypominajaca_ogolem', 'teryt', "name", "Date", "stan_rekordu_na"]
cols_w_v = list(collections.OrderedDict().fromkeys(base_cols_p_v + list(headers)).keys())

woj_row_v = collections.namedtuple('woj_row', 
cols_w_v
)

res = list()
for idx, file in enumerate(woj_vac_files):
  file_basename = os.path.basename(file)
  file_date = datetime.date(int(file_basename[:4]), int(file_basename[4:6]), int(file_basename[6:8]))
  stan_rekordu_na = str(file_date - datetime.timedelta(days=1))
  file_date = str(file_date)
  if file_basename[:8] == "20210107":
    continue
  with open(file, "rb") as csvfile:
    csv_lines = csvfile.readlines()
    rowl = csv_lines[-1].strip().split(b";")
    try:
      if rowl[0].decode("utf-8") in all_id:
        ee = "utf-8"
      else:
        ee = pol_encoding
    except:
      ee = pol_encoding
    header = [h.strip('"') for h in csv_lines[0].decode(ee).strip().split(";")]
    for rowb in csv_lines[1:]:
      row = [r.strip('"') for r in rowb.decode(ee).strip().split(";")]
      row_dict = dict(zip(header, row))
      row_dict["name"] = file_basename
      row_dict["Date"] = file_date
      row_dict["stan_rekordu_na"] = stan_rekordu_na
      lacks = set(cols_w_v) - set(row_dict.keys())
      if len(lacks) > 0:
        for ll in lacks:
          row_dict[ll] = ""
      res_row = list(woj_row_v(**row_dict))
      res.append(res_row)

list2gzip(path_res_woj_vac, res, cols_w_v, len(cols_w_v))
