# -*- coding: utf-8 -*-
from collections import namedtuple
import os
import urllib.request
import gzip
import datetime

def list2gzip(path: str, data_list: list, cols: list, n_cols: int, encoding: str = "utf-8") -> None:
    """
    write a gzip file from a list of data rows
    :param path: a target path
    :param data_list: a list of data rows
    :param cols: n first columns to save
    :param encoding: encoding type
    """
    assert isinstance(path, str)
    assert isinstance(data_list, list)
    assert isinstance(cols, list)
    with gzip.open(path, 'w') as file:
        file.write((",".join(cols[:(n_cols + 1)]) + "\n").encode(encoding))
        file.writelines([(",".join(l[:(n_cols + 1)]) + "\n").encode(encoding) for l in data_list])

def resolve_file_encoding(
    bstring: str, 
    look_w: str = "Cały",
    base_encoding: str = "utf-8", 
    alt_encoding: str = "Windows-1250",
    lower: bool = True
  ) -> str:
    """
    resolve a file encoding
    :param bstring: a base text to check
    :param look_w: a reference word
    :param base_encoding: a base encoding
    :param alt_encoding: an alternative encoding
    :param lower: if to lower a base and reference words before the comparision.
    """
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

def get_plgov_cols(paths: list[str], bstring: str) -> list[str]:
    """
    retrive unique values for files first row (columns names) 
    :param paths: files paths
    :param bstring: a word to resolve the encoding
    """
    headers = list()
    for file in paths:
        with open(file, "rb") as csvfile:
            csv_lines = csvfile.readlines()
            row1 = csv_lines[1].strip().split(b";")
            ee = resolve_file_encoding(row1[0], bstring)
            header = [h.strip('"') for h in csv_lines[0].decode(ee).strip().split(";")]
            headers = list(set(headers + header))
    return headers

def process_gov(files: list[str],
                dates_to_skip: list[str],
                mapping: dict, 
                row_ntuple: namedtuple,
                bstring_pos: int, 
                bstring: str):
    """
    a function to process the gov.pl covid19 data
    :param files: files to process
    :param dates_to_skip: dates to omit
    :param mapping: mapping with an old and new names
    :param row_ntuple: one row of the data
    :param bstring_pos: position in first data row to compare with a bstring
    :param bstring_pos: a word which is used to indentify an encoding
    """
    res = []
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

def retry(times, exceptions):
    """
    Retry Decorator
    Retries the wrapped function/method `times` times if the exceptions listed
    in ``exceptions`` are thrown
    :param times: The number of times to repeat the wrapped function/method
    :type times: Int
    :param Exceptions: Lists of exceptions that trigger a retry attempt
    :type Exceptions: Tuple of Exceptions
    """
    def decorator(func):
        def newfn(*args, **kwargs):
            attempt = 0
            while attempt < times:
                try:
                    return func(*args, **kwargs)
                except exceptions:
                    print(f'Exception thrown when attempting to run {func}, attempt {attempt} of {times}')
                    attempt += 1
            return func(*args, **kwargs)
        return newfn
    return decorator

@retry(times=3, exceptions=(ValueError, TypeError))
def get_url(url: str) -> tuple:
    """
    a wrapper around urllib.request.urlretrieve with a 3 times retry
    :param url: str a url to be download
    """
    return urllib.request.urlretrieve(url)
