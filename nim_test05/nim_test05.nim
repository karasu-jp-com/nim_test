#import os
import jsbind/emscripten
import promise

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
proc DoSubModule(module:string, msg:string) {.discardable.} =
  type TypeSubModule = proc(msg:cstring):bool {.cdecl.}
  
  let handle = dlopen(module, RTLD_NOW)
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
# LoadSubModule
#######################################
proc LoadSubModule(p:Promise, module:string, msg:string) =
  emscripten_async_wget_data(module
  , proc(data: pointer, sz: cint) =
    echo "emscripten_async_wget_data Success. " & module

    let f:File = open(module, FileMode.fmWrite)
    defer:
      f.close
    discard f.writeBuffer(data, sz)

    DoSubModule(module, msg)

    p.resolve
  , proc() =
    p.reject Exception(msg:"emscripten_async_wget_data Fault. " & module)
  )

#######################################
# main
#######################################
discard newPromise(proc(p:Promise) =
  echo "Test05 START"

  p.LoadSubModule("nim_test05_sub01.wasm", "KANI")

).then(proc(p:Promise) =
  p.LoadSubModule("nim_test05_sub02.wasm", "TAKO")

#).then(proc(p:Promise) =
#  for f in walkDir("/"):
#    echo f.path
#
#  p.resolve
#
).catch(proc(p:Promise, e:Exception) =
  echo e.msg
  p.final

).then(proc(p:Promise) =
  echo "Tes05 END"
)
