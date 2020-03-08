local Lplus = require("Lplus")
local OutFightDo = Lplus.Class("OutFightDo")
local def = OutFightDo.define
def.field("table")._doList = function()
  return {}
end
local instance
def.static("=>", OutFightDo).Instance = function()
  if instance == nil then
    instance = OutFightDo()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, OutFightDo.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, OutFightDo.OnLeaveFight)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
end
def.method("function", "table").Do = function(self, func, context)
  local isInFight = require("Main.Fight.FightMgr").Instance().isInFight
  if isInFight then
    table.insert(self._doList, func)
  else
    func(context)
  end
end
def.method().Reset = function(self)
  instance._doList = {}
end
def.static("table", "table").OnEnterFight = function()
  instance._doList = {}
end
def.static("table", "table").OnLeaveFight = function(self)
  for i, func in ipairs(instance._doList) do
    func()
  end
  instance._doList = {}
end
return OutFightDo.Commit()
