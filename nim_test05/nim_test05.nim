proc dlopen(filename:cstring, flag:cint): pointer {.header:"<dlfcn.h>", importc.}
proc dlsym(handle:pointer, symbol:cstring): pointer {.header:"<dlfcn.h>", importc.}
proc dlclose(handle:pointer): int {.header:"<dlfcn.h>", importc.}

type TypeSubModule = proc(msg:cstring):bool {.cdecl.}

let handle = dlopen("test", 0)
let subModule = cast[TypeSubModule](dlsym(handle, "subModule"))

echo subModule("TAKO")

discard dlclose(handle)
