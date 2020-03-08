local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local QuickLaunchModule = Lplus.Extend(ModuleBase, "QuickLaunchModule")
local EnterWorldAlertMgr = require("Main.Common.EnterWorldAlertMgr")
local OperationFactory = require("Main.QuickLaunch.OperationFactory")
local ECGame = Lplus.ForwardDeclare("ECGame")
local def = QuickLaunchModule.define
local instance
def.static("=>", QuickLaunchModule).Instance = function()
  if instance == nil then
    instance = QuickLaunchModule()
    instance.m_moduleId = ModuleId.QUICK_LAUNCH
  end
  return instance
end
def.override().Init = function(self)
  EnterWorldAlertMgr.Instance():Register(EnterWorldAlertMgr.CustomOrder.QuickLaunch, QuickLaunchModule.OnEnterWorldAlert, self)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.GAME_RESUME, QuickLaunchModule.OnResumeGame)
end
def.method().ExcuteShortcutOperation = function(self)
  local shortcutMenuKey = ECGame.Instance():GetShortcutMenuKey()
  if shortcutMenuKey == "" then
    return
  end
  local operation = OperationFactory.CreateOperation(shortcutMenuKey)
  operation:Operate(nil)
  ECGame.Instance():ClearShortcutMenuKey()
end
def.method().OnEnterWorldAlert = function(self)
  self:ExcuteShortcutOperation()
  EnterWorldAlertMgr.Instance():Next()
end
def.static("table", "table").OnResumeGame = function()
  if ECGame.Instance():GetGameState() == _G.GameState.GameWorld then
    instance:ExcuteShortcutOperation()
  end
end
return QuickLaunchModule.Commit()
