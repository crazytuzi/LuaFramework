local MemoryDetect = class("MemoryDetect")
function MemoryDetect:ctor()
  self.m_LastMemoryShortageTime = 0
  self.m_LastReleaseMemorySize = 0
  self:DetectReleaseScheduler()
end
function MemoryDetect:DetectReleaseScheduler()
  scheduler.scheduleGlobal(function()
    self:DetectRelease()
  end, 10)
end
function MemoryDetect:MemoryShortage()
  print("MemoryDetect:MemoryShortage--内存不足了-->>")
  local curTime = cc.net.SocketTCP.getTime()
  local lastTime = self.m_LastMemoryShortageTime
  local deltaTime = curTime - lastTime
  if deltaTime < 1 then
    print("间隔两次警告时间过短，有可能down机了..")
  else
    self.m_LastMemoryShortageTime = curTime
    self:DealMemoryShortage()
  end
end
function MemoryDetect:DealMemoryShortage(...)
  printInfo("---------------------------------------------------")
  printInfo("--------------    DealMemoryShortage    -----------")
  CCSpriteFrameCache:sharedSpriteFrameCache():removeUnusedSpriteFrames()
  local textureCache = CCTextureCache:sharedTextureCache()
  textureCache:removeUnusedTextures()
  self.m_LastReleaseMemorySize = textureCache:getCacheTextureMemorySize() / 1048576
  printInfo("---------------------------------------------------")
end
function MemoryDetect:DetectRelease()
  print("\n")
  print("DetectRelease")
  local textureCache = CCTextureCache:sharedTextureCache()
  local totalMem, freeMem, appUsedMem = SyNative.getMemoryInfo()
  print(string.format("总内存:%sMB,空余内存:%sMB,app使用内存:%sMB", tostring(totalMem), tostring(freeMem), tostring(appUsedMem)))
  local isRelease = false
  if freeMem ~= nil then
    if freeMem < 30 then
      print("----------->> 空余内存过少，释放内存")
      self.m_LastMemoryShortageTime = cc.net.SocketTCP.getTime()
      self:DealMemoryShortage()
      isRelease = true
    end
  else
    print("[WARNING]获取不到剩余内存数据")
  end
  if isRelease == false and textureCache.getCacheTextureMemorySize then
    local curTotlaSize = textureCache:getCacheTextureMemorySize() / 1048576
    local dAcc = curTotlaSize - self.m_LastReleaseMemorySize
    print("curTotlaSize:", curTotlaSize, self.m_LastReleaseMemorySize, dAcc)
    if curTotlaSize > 80 and dAcc > 5 or curTotlaSize > 40 and dAcc > 10 then
      self:DealMemoryShortage()
      isRelease = true
    end
  end
  print("\n")
  if g_DetectViewRelease then
    ViewRelease_Print()
  end
end
function MemoryDetect:PrintObjMemory()
  local collectgarbage = collectgarbage
  local scheduler = scheduler
  local pairs = pairs
  local ipairs = ipairs
  local table = table
  local print = print
  local function getCurMem()
    collectgarbage("collect")
    return collectgarbage("count")
  end
  scheduler.scheduleGlobal(function()
    print("LUA MEM:", getCurMem())
  end, 1)
  local allKeys = {}
  local bigMem = {}
  for k, v in pairs(_G) do
    if k ~= "_G" then
      allKeys[#allKeys + 1] = k
    end
  end
  getCurMem()
  getCurMem()
  getCurMem()
  local mem_t = getCurMem()
  local tempMem
  for i, v in ipairs(allKeys) do
    _G[v] = nil
    tempMem = getCurMem()
    local m = mem_t - tempMem
    mem_t = tempMem
    if m > 10 then
      bigMem[#bigMem + 1] = {v, m}
      print("\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t", v, m)
    else
      print("\t", v, m)
    end
  end
  table.sort(bigMem, function(obj1, obj2)
    return obj1[2] > obj2[2]
  end)
  print("--------->> 排序后")
  for i, v in ipairs(bigMem) do
    print("\t\t ", v[1], v[2])
  end
end
g_MemoryDetect = MemoryDetect.new()
