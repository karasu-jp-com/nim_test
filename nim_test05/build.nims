withDir "nim_test05":
  exec("nim c -d:debug -d:submodule -o:../bin/nim_test05_sub02.wasm nim_test05_sub02.nim")
  exec("cmd /C copy /Y ..\\bin\\nim_test05_sub02.wasm .\\preload\\nim_test05_sub02.so")

  exec("nim c -d:debug -d:submodule -o:../bin/nim_test05_sub01.wasm nim_test05_sub01.nim")
  exec("cmd /C copy /Y ..\\bin\\nim_test05_sub01.wasm .\\preload\\nim_test05_sub01.so")

  exec("nim c -d:debug -o:../bin/nim_test05.js nim_test05.nim")
  exec("cmd /C copy /Y ..\\bin\\nim_test05.* ..\\test\\")
