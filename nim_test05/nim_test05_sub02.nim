proc NimMain() {.importc.}

var isInitial = false

proc subModule*(msg:cstring):bool {.cdecl,exportc.} =
  if not(isInitial):
    NimMain()
    isInitial = true

  echo "Message from sub02:", msg
  return true
