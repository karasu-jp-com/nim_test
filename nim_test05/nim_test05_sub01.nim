proc NimMain() {.importc.}
proc emscripten_run_script(scriptstr: cstring)
  {.header: "<emscripten.h>", importc: "emscripten_run_script".}

var isInitial = false

proc subModule*(msg:cstring):bool {.cdecl,exportc.} =
  if not(isInitial):
    NimMain()
    isInitial = true

  emscripten_run_script("$('#output1').html('Message from sub01:" & $msg & "');" &
  "$('#output1').css('background-color','green');")

  echo("Message from sub01:" & $msg)
  return true
