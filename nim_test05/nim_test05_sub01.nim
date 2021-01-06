proc NimMain() {.importc.}
proc emscripten_run_script(scriptstr: cstring)
  {.header: "<emscripten.h>", importc: "emscripten_run_script".}

var isInitial = false

proc subModule*(msg:cstring):bool {.cdecl,exportc.} =
  if not(isInitial):
    NimMain()
    isInitial = true

  echo "Message from sub01:", msg
  emscripten_run_script("$('#output').html('test');")
  return true
