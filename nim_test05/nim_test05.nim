import os
import jsbind/emscripten

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

type Promise = ref object
  mIsFault: bool
  mProc : proc(p:Promise) or proc(p:Promise, e:system.Exception)
  mNextP: Promise

proc newPromise(f:proc(p:Promise)): Promise =
  let p = Promise(mIsFault:false, mProc:f, mNextP:nil)
  f(p)
  return p

proc then(p:Promise, f:proc(p:Promise)): Promise =
  p.mNextP = Promise(mIsFault:false, mProc:f, mNextP:nil)
  return p.mNextP

proc catch(p:Promise, f:proc(p:Promise, e:system.Exception)): Promise =
  p.mNextP = Promise(mIsFault:true, mProc:f, mNextP:nil)
  return p.mNextP

proc resolve(p:Promise) =
  if p.mNextP != nil and not(p.mNextP.mIsFault):
    p.mNextP.mProc(p.mNextP)

proc reject(p:Promise, e:Exception) =
  var errP = p.mNextP
  while not(errP.mIsFault):
    errP

  if p.mNextP != nil and not(p.mNextP.mIsFault):
    p.mNextP.mProc(p.mNextP)

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
# ListFile
#######################################
proc ListFile() {.discardable.} =
  for f in walkDir("/"):
    echo f.path

#######################################
# WriteFile
#######################################
proc WriteFile() {.discardable.} =
  let f:File = open("Test.xxx", FileMode.fmWrite)
  defer:
    f.close
  f.write("AIUEO KAKIKUKEO")

#######################################
# LoadData
#######################################
proc LoadData(module:string) {.discardable.} =
  emscripten_async_wget_data(
    module
  , proc(data: pointer, sz: cint) =
    echo "emscripten_async_wget_data Success."
  , proc() =
    echo "emscripten_async_wget_data Falt."
  )

#######################################
# main
#######################################
echo "Test05 START"

#WriteFile()

discard newPromise(proc(p:Promise) =

  emscripten_async_wget_data("nim_test05_sub01.wasm"
  , proc(data: pointer, sz: cint) =
    echo "emscripten_async_wget_data Success."
    p.reject
  , nil)
).then(proc(p:Promise) =

  ListFile()
)


#DoSubModule "nim_test05_sub01.so", "KANI"
#DoSubModule "nim_test05_sub02.so", "TAKO"

echo "Tes05 END"
