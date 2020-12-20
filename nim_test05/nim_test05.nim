##include <dlfcn.h>
#void *dlopen(const char *filename, int flag);
#char *dlerror(void);
#void *dlsym(void *handle, const char *symbol);
#int dlclose(void *handle);

#proc printf(formatstr: cstring) {.header: "<stdio.h>", importc: "printf", varargs.}
proc dlopen(filename:cstring, flag:int):pointer {.header: "<dlfcn.h>",importc.}
proc dlsym(handle:pointer, symbol:cstring):pointer {.header: "<dlfcn.h>",importc.}
proc dlclose(handle:pointer):int {.header: "<dlfcn.h>",importc.}
#const RTLD_LAZY     = 1
const RTLD_NOW      = 2
#const RTLD_NOLOAD   = 4
#const RTLD_NODELETE = 4096
#const RTLD_GLOBAL   = 256
#const RTLD_LOCAL    = 0

type TypeSubModule = proc(msg:cstring):bool {.cdecl.}

var handle = dlopen("nim_test05_sub01.wasm", RTLD_NOW)
var subModule = cast[TypeSubModule](dlsym(handle, "subModule"))
echo subModule("KANI")
discard dlclose(handle)

