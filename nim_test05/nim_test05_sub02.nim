proc NimMain() {.importc.}
proc emscripten_run_script(scriptstr: cstring)
  {.header: "<emscripten.h>", importc: "emscripten_run_script".}

var isInitial = false

proc subModule*(msg:cstring):bool {.cdecl,exportc.} =
  if not(isInitial):
    NimMain()
    isInitial = true

  emscripten_run_script("postMessage(\"$('#output2').html('Message from sub02:" & $msg & "');" &
  "$('#output2').css('color','red');\")")

  echo("Message from sub02:" & $msg)
  return true
