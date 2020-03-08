local Lplus = require("Lplus")
local OutFightPlay = Lplus.Class("OutFightPlay")
local def = OutFightPlay.define
def.field("table")._playList = function()
  return {}
end
local instance
def.static("=>", OutFightPlay).Instance = function()
  if instance == nil then
    instance = OutFightPlay()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, OutFightPlay.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, OutFightPlay.OnLeaveFight)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
end
def.method("function").Play = function(self, func)
  local isInFight = require("Main.Fight.FightMgr").Instance().isInFight
  if isInFight then
    table.insert(self._playList, func)
  else
    func()
  end
end
def.method().Reset = function(self)
  instance._playList = {}
end
def.static("table", "table").OnEnterFight = function()
  instance._playList = {}
end
def.static("table", "table").OnLeaveFight = function(self)
  for i, func in ipairs(instance._playList) do
    func()
  end
  instance._playList = {}
end
return OutFightPlay.Commit()
