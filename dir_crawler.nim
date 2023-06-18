import strutils
import os

proc loadResources*() =
  let module = open("dir_result.nim", fmWrite)

  for file in walkFiles("res/beasts/*.nim"):
    module.write("include " & file[0..^5].replace(r"\", "/") & "\n")
    echo file
  for file in walkFiles("res/items/*.nim"):
    module.write("include " & file[0..^5].replace(r"\", "/") & "\n")
    echo file
  for file in walkFiles("res/locations/*.nim"):
    module.write("include " & file[0..^5].replace(r"\", "/") & "\n")
    echo file
  for file in walkFiles("root/beasts/*.nim"):
    module.write("include " & file[0..^5].replace(r"\", "/") & "\n")
    echo file
  for file in walkFiles("root/items/*.nim"):
    module.write("include " & file[0..^5].replace(r"\", "/") & "\n")
    echo file
  for file in walkFiles("root/locations/*.nim"):
    module.write("include " & file[0..^5].replace(r"\", "/") & "\n")
    echo file

  module.close