local Lplus = require("Lplus")
local LuckyStarUIMgr = Lplus.Class("LuckyStarUIMgr")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local def = LuckyStarUIMgr.define
local instance
def.static("=>", LuckyStarUIMgr).Instance = function()
  if instance == nil then
    instance = LuckyStarUIMgr()
  end
  return instance
end
def.method("=>", "boolean").IsShowLuckyStarEntry = function(self)
  return require("Main.LuckyStar.LuckyStarModule").Instance():IsLuckyStarOpened()
end
def.method("=>", "boolean").HasLuckyStarNotify = function(self)
  if not require("Main.LuckyStar.LuckyStarModule").Instance():IsLuckyStarOpened() then
    return false
  end
  local LuckyStarMgr = require("Main.LuckyStar.mgr.LuckyStarMgr")
  if LuckyStarMgr.Instance():HasBuyAllLuckyStar() then
    return false
  end
  return not self:HasTodayShow()
end
def.method("=>", "number").GetDateKey = function(self)
  local serverTime = _G.GetServerTime()
  local key = tonumber(os.date("%Y%m%d", serverTime))
  return key
end
local keyPrefix = "LuckyStarDate_"
def.method("=>", "string").GetStorageKey = function(self, dateKey)
  local dateKey = self:GetDateKey()
  return keyPrefix .. tostring(dateKey)
end
def.method("=>", "boolean").HasTodayShow = function(self)
  local storageKey = self:GetStorageKey()
  if LuaPlayerPrefs.HasRoleKey(storageKey) then
    return true
  end
  return false
end
def.method().MarkTodayAsShowed = function(self)
  local storageKey = self:GetStorageKey()
  LuaPlayerPrefs.SetRoleString(storageKey, "1")
  Event.DispatchEvent(ModuleId.LUCKYSTAR, gmodule.notifyId.LuckyStar.LUCKYSTAR_NOTIFY_CHANGE, nil)
end
LuckyStarUIMgr.Commit()
return LuckyStarUIMgr
