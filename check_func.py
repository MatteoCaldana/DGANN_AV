import pathlib
import re
from collections import Counter
from pathlib import Path


def find_files(start_path ="./"):
  here = pathlib.Path(start_path)
  ls = list(here.rglob(r"*.m"))
  files = {}
  for file in ls:
    with open(file, 'r') as fp:
      data = fp.read()
    files[file] = data
  return files

def check_charset(files):
  charset = set()
  for file in files:
    for c in files[file]:
      charset.add(ord(c))
  return charset.issubset(set(range(32, 127)) | set([9, 10, 13])) 

def compress_file(file_txt):
  # remove comments
  file_txt = re.sub(r"%.*", "", file_txt)
  # remove carriage return
  file_txt = re.sub(r"\r", "", file_txt)
  # trim duplicate whitespaces
  file_txt = re.sub(r"[ \t]{2,}", " ", file_txt)
  # trim trailing whitespaces
  file_txt = re.sub(r"\s*\n", "\n", file_txt)
  # unravel lines with multiple semicolumns
  file_txt = re.sub(r";", ";\n", file_txt)
  # trim duplicate newlines
  file_txt = re.sub(r"\n{2,}", "\n", file_txt)
  # trim start-end newlines
  if len(file_txt) and file_txt[0] == "\n":
    file_txt = file_txt[1:]
  if len(file_txt) and file_txt[-1] == "\n":
    file_txt = file_txt[:-1]
  # compact line continuation
  file_txt = re.sub(r"\.\.\.\n", " ", file_txt)
  return file_txt


if __name__ == "__main__":
  files = find_files()
  print(f"Found {len(files)} MATLAB file(s)")
  print(f"ASCII charset check: {check_charset(files)}")

  size = sum([len(files[filepath]) for filepath in files])
  print(f"Numbers of chars: {size}")

  print("Compressing files")
  for filepath in files:
    files[filepath] = compress_file(files[filepath])

  size = sum([len(files[filepath]) for filepath in files])
  print(f"Numbers of chars: {size}")

  n_newlines = 0
  n_equals = 0
  n_continuations = 0
  for filepath in files:
    n_newlines += files[filepath].count("\n")
    n_equals += files[filepath].count("=")
    n_continuations += files[filepath].count("...")

  print("n_newlines:", n_newlines)
  print("n_equals:", n_equals)
  print("n_continuations:", n_continuations)

  func_cnts = []
  need_intervention = 0
  for filepath in files:
    matches = re.findall(r"(^|\W)function[\W\n]", files[filepath])
    occurences = len(matches)
    func_cnts.append(occurences)

    if occurences == 0:
      name = Path(filepath).name
      #print(name[:-2])
      called_by = []
      for filepath2 in files:
        if re.search(r"(^|\W)"+name[:-2]+r"[\W\n]", files[filepath2]):
          called_by.append(filepath2)

      if len(called_by):
        need_intervention += 1
        print(filepath, "->", called_by)

  print("Need intervention:", need_intervention)
  print(Counter(func_cnts))

