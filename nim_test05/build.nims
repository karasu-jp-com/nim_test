withDir "nim_test05":
  exec("nim c -d:release -d:submodule -o:../bin/nim_test05_sub01.js nim_test05_sub01.nim")

  exec("nim c -d:release -o:../bin/nim_test05.js nim_test05.nim")
  # Windows以外のOSの場合、適当に書き換えて
  exec("cmd /C copy /Y ..\\bin\\nim_test05.* ..\\test\\")

