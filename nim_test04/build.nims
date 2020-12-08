withDir "nim_test04":
  exec("nim c -d:debug -o:../bin/nim_test04.js nim_test04.nim")
  # Windows以外のOSの場合、適当に書き換えて
  exec("cmd /C copy /Y ..\\bin\\nim_test04.* ..\\test\\")
