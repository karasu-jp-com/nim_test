type Promise * = ref object
  mProcS : proc(p:Promise)                      # Success
  mProcF : proc(p:Promise, e:Exception)  # Fault
  mNextP: Promise

proc newPromise*(f:proc(p:Promise)): Promise =
  let p = Promise(mProcS:f, mProcF: nil, mNextP:nil)
  f(p)
  return p

proc then*(p:Promise, f:proc(p:Promise)): Promise =
  if p.mProcS != nil:
    p.mNextP = Promise(mProcS:f, mProcF:nil, mNextP:nil)
    return p.mNextP
  else:
    p.mProcS = f
    return p

proc catch*(p:Promise, f:proc(p:Promise, e:Exception)): Promise =
  p.mNextP = Promise(mProcS:nil, mProcF:f, mNextP:nil)
  return p.mNextP

proc resolve*(p:Promise) =
  var sucP = p.mNextP
  while sucP != nil and sucP.mProcS == nil:
    sucP = sucP.mNextP

  if sucP != nil:
    sucP.mProcS(sucP)

proc reject*(p:Promise, e:Exception) =
  var errP = p.mNextP
  while errP != nil and errP.mProcF == nil:
    errP = errP.mNextP

  if errP != nil:
    errP.mProcF(errP, e)

proc final*(p:Promise) =
  var sucP = p.mNextP
  while sucP.mNextP != nil:
    sucP = sucP.mNextP

  if sucP.mProcS != nil:
    sucP.mProcS(sucP)