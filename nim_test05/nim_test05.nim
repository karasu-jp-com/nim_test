##include <dlfcn.h>
#void *dlopen(const char *filename, int flag);
#char *dlerror(void);
#void *dlsym(void *handle, const char *symbol);
#int dlclose(void *handle);

#proc printf(formatstr: cstring) {.header: "<stdio.h>", importc: "printf", varargs.}
proc dlopen(filename:cstring, flag:int):pointer {.header: "<dlfcn.h>",importc.}
proc dlsym(handle:pointer, symbol:cstring):pointer {.header: "<dlfcn.h>",importc.}
proc dlerror():cstring {.header: "<dlfcn.h>",importc.}
proc dlclose(handle:pointer):int {.header: "<dlfcn.h>",importc.}
#const RTLD_LAZY     = 1
const RTLD_NOW      = 2
#const RTLD_NOLOAD   = 4
#const RTLD_NODELETE = 4096
#const RTLD_GLOBAL   = 256
#const RTLD_LOCAL    = 0

type TypeSubModule = proc(msg:cstring):bool {.cdecl.}

echo "Tes05 START Version0006"

#var handle = dlopen("nim_test05_sub01.so", RTLD_NOW)
#if handle == nil:
#  echo "dlopen Fault."
#  echo dlerror()
#  quit(QuitFailure)
#else:
#  echo "dlopen Success."

#var subModule = cast[TypeSubModule](dlsym(handle, "subModule"))
#if subModule == nil:
#  echo "dlsym Fault."
#  echo dlerror()
#  quit(QuitFailure)
#else:
#  echo "dlsym Success."
#
#echo subModule("KANI")

#discard dlclose(handle)

echo "Tes05 END"
