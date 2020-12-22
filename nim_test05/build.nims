withDir "nim_test05":
  exec("nim c -d:debug -d:submodule -o:../bin/nim_test05_sub01.wasm nim_test05_sub01.nim")
  # Windows以外のOSの場合、適当に書き換えて
  exec("cmd /C copy /Y ..\\bin\\nim_test05_sub01.wasm .\\preload\\nim_test05_sub01.so")

  exec("nim c -d:debug -o:../bin/nim_test05.js nim_test05.nim")
  # Windows以外のOSの場合、適当に書き換えて
  exec("cmd /C copy /Y ..\\bin\\nim_test05.* ..\\test\\")
