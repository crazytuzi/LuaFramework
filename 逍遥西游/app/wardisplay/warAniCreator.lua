local warAniCreator = {}
function warAniCreator.createAni(plistpath, times, cblistener, autoDestroy, retainToPool, frameRate, rgba4444Mode)
  if times == nil then
    times = 1
  end
  if autoDestroy == nil then
    autoDestroy = true
  end
  if retainToPool == nil then
    retainToPool = false
  end
  local ani = CreateSeqAnimation(plistpath, times, cblistener, autoDestroy, retainToPool, frameRate, rgba4444Mode)
  return ani
end
return warAniCreator
