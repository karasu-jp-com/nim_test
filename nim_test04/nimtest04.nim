#WebAssemblyテストその２
import jsbind/emscripten

proc emscripten_run_script(scriptstr: cstring)
  {.header: "<emscripten.h>", importc: "emscripten_run_script".}
proc emscripten_run_script_string(scriptstr: cstring):cstring
  {.header: "<emscripten.h>", importc: "emscripten_run_script_string".}

emscripten_run_script("WasmInitialized();")

proc func01*() {.EMSCRIPTEN_KEEPALIVE.} =
  var str = emscripten_run_script_string("ThisIsJSFunc();")
  emscripten_run_script("$('#output1').html('" & $str & "を<br />WebAssemblyから出力しています');")