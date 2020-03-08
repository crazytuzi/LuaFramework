local Lplus = require("Lplus")
local ProtocolsCache = Lplus.Class("ProtocolsCache")
local def = ProtocolsCache.define
local instance
def.static("=>", ProtocolsCache).Instance = function()
  if instance == nil then
    instance = ProtocolsCache()
    instance:Init()
  end
  return instance
end
def.field("table")._cachedProtocols = nil
def.method().Init = function(self)
  self:Reset()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
end
def.method().Reset = function(self)
  self._cachedProtocols = {}
end
def.method().ReleaseCachedProtocols = function(self)
  if ProtocolsCache.NeedCacheProtocols(true, true, true) == true then
    return
  end
  local cachedProtocols = self._cachedProtocols
  self._cachedProtocols = {}
  for k, v in pairs(cachedProtocols) do
    v.f(v.p)
  end
end
def.static("boolean", "boolean", "boolean", "=>", "boolean").NeedCacheProtocols = function(cacheInFight, cacheOnNpcTalk, cacheOnCGPlay)
  if cacheInFight == true and PlayerIsInFight() == true then
    return true
  end
  local npcTalk = require("Main.task.ui.TaskTalk").Instance()
  if cacheOnNpcTalk == true and npcTalk:IsShow() == true then
    return true
  end
  if cacheOnCGPlay == true and _G.CGPlay == true then
    return true
  end
  return false
end
def.method("function", "table", "=>", "boolean").CacheProtocol = function(self, fn, p)
  local ncp = ProtocolsCache.NeedCacheProtocols(true, true, true)
  if ncp == true then
    self:_CacheProtocol(fn, p)
  end
  return ncp
end
def.method("function", "table", "boolean", "boolean", "boolean", "=>", "boolean").CacheProtocol2 = function(self, fn, p, cacheInFight, cacheOnNpcTalk, cacheOnCGPlay)
  local ncp = ProtocolsCache.NeedCacheProtocols(cacheInFight, cacheOnNpcTalk, cacheOnCGPlay)
  if ncp == true then
    self:_CacheProtocol(fn, p)
  end
  return ncp
end
def.method("function", "table")._CacheProtocol = function(self, fn, p)
  local cp = {}
  cp.f = fn
  cp.p = p
  table.insert(self._cachedProtocols, cp)
end
ProtocolsCache.Commit()
return ProtocolsCache
