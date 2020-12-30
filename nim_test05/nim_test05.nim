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

#######################################
# DoSubModule
#######################################
proc DoSubModule(name:string, msg:string) {.discardable.} =
  type TypeSubModule = proc(msg:cstring):bool {.cdecl.}
  
  let handle = dlopen(name, RTLD_NOW)
  if handle == nil:
    echo "dlopen Fault.", dlerror()
    quit(QuitFailure)
#  else:
#    echo "dlopen Success."

  let subModule = cast[TypeSubModule](dlsym(handle, "subModule"))
  if subModule == nil:
    echo "dlsym Fault.", dlerror()
    quit(QuitFailure)
#  else:
#    echo "dlsym Success."

  discard subModule(msg)

  discard dlclose(handle)

#######################################
# main
#######################################
echo "Test05 START"

DoSubModule "nim_test05_sub01.so", "KANI"
DoSubModule "nim_test05_sub02.so", "TAKO"

echo "Tes05 END"
