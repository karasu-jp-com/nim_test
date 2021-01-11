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
  mProcS : proc(p:Promise)                      # Success
  mProcF : proc(p:Promise, e:system.Exception)  # Fault
  mNextP: Promise

proc newPromise(f:proc(p:Promise)): Promise =
  let p = Promise(mProcS:f, mProcF: nil, mNextP:nil)
  f(p)
  return p

proc then(p:Promise, f:proc(p:Promise)): Promise =
  if p.mProcS != nil:
    p.mNextP = Promise(mProcS:f, mProcF:nil, mNextP:nil)
    return p.mNextP
  else:
    p.mProcS = f
    return p

proc catch(p:Promise, f:proc(p:Promise, e:system.Exception)): Promise =
  p.mNextP = Promise(mProcS:nil, mProcF:f, mNextP:nil)
  return p.mNextP

proc resolve(p:Promise) =
  var sucP = p.mNextP
  while sucP != nil and sucP.mProcS == nil:
    sucP = sucP.mNextP

  if sucP != nil:
    sucP.mProcS(sucP)

proc reject(p:Promise, e:Exception) =
  var errP = p.mNextP
  while errP != nil and errP.mProcF == nil:
    errP = errP.mNextP

  if errP != nil:
    errP.mProcF(errP, e)

proc final(p:Promise) =
  var sucP = p.mNextP
  while sucP.mNextP != nil:
    sucP = sucP.mNextP

  if sucP.mProcS != nil:
    sucP.mProcS(sucP)

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

    DoSubModule module, msg

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
