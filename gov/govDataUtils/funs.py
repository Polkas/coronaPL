# -*- coding: utf-8 -*-
import os
import tempfile
import urllib.request
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

def resolve_file_encoding(
    bstring, 
    look_w = "Cały",
    base_encoding = "utf-8", 
    alt_encoding = "Windows-1250",
    lower = True
  ):
  assert isinstance(bstring, bytes), "bstring has to be a bytes"
  assert isinstance(lower, bool), "lower has to be a bool"
  try:
    string_n = bstring.lower() if lower else bstring
    look_w_n = look_w.lower() if lower else look_w
    if string_n.decode(base_encoding) in look_w_n:
      ee = base_encoding
    else:
      ee = alt_encoding
  except:
    ee = alt_encoding
  return ee

def get_plgov_cols(paths, bstring):
  headers = list()
  for file in paths:
    with open(file, "rb") as csvfile:
      csv_lines = csvfile.readlines()
      row1 = csv_lines[1].strip().split(b";")
      ee = resolve_file_encoding(row1[0], bstring)
      header = [h.strip('"') for h in csv_lines[0].decode(ee).strip().split(";")]
      headers = list(set(headers + header))
  return headers

def process_gov(files, dates_to_skip, mapping, row_ntuple, bstring_pos, bstring):
  res = list()
  for file in files:
    file_basename = os.path.basename(file)
    file_date = datetime.date(int(file_basename[:4]), int(file_basename[4:6]), int(file_basename[6:8]))
    stan_rekordu_na = str(file_date - datetime.timedelta(days=1))
    file_date = str(file_date)
    if file_basename[:8] in dates_to_skip:
      continue
    with open(file, "rb") as csvfile:
      csv_lines = csvfile.readlines()
      row1 = csv_lines[bstring_pos].strip().split(b";")
      ee = resolve_file_encoding(row1[0], bstring)
      header = [h.strip('"') for h in csv_lines[0].decode(ee).strip().split(";")]
      for rowb in csv_lines[1:]:
        row = [r.strip('"') for r in rowb.decode(ee).strip().split(";")]
        row_dict = dict(zip(header, row))
        row_dict["name"] = file_basename
        row_dict["Date"] = file_date
        row_dict["stan_rekordu_na"] = stan_rekordu_na
        for k, v in mapping.items():
          if k not in row_dict.keys():
            row_dict[k] = row_dict[v]
          if v not in row_dict.keys():
            row_dict[v] = row_dict[k]
        lacks = set(list(row_ntuple._fields)) - set(row_dict.keys())
        if len(lacks) > 0:
          for ll in lacks:
            row_dict[ll] = ""
        res_row = list(row_ntuple(**row_dict))
        res.append(res_row)
  return res
