proc subModule(msg:cstring):bool {.cdecl,exportc.} =
  echo "Message from sub01:", msg
  return true
