local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local FightModule = Lplus.Extend(ModuleBase, "FightModule")
require("Main.module.ModuleId")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECPlayer = Lplus.ForwardDeclare("ECPlayer")
local def = FightModule.define
local instance
local fightMgr = require("Main.Fight.FightMgr").Instance()
def.static("=>", FightModule).Instance = function()
  if instance == nil then
    instance = FightModule()
    instance.m_moduleId = ModuleId.FIGHT
  end
  return instance
end
def.override().Init = function(self)
  fightMgr:Init()
  ModuleBase.Init(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, FightModule.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, FightModule.OnLeaveFight)
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  require("Main.Fight.ui.DlgFunctionBtns").Instance():ShowDlg()
end
def.static("table", "table").OnLeaveFight = function(p1, p2)
  require("Main.Fight.ui.DlgFunctionBtns").Instance():Hide()
end
FightModule.Commit()
return FightModule
