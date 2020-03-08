local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BattlefieldMiniMapMgr = Lplus.Class(MODULE_NAME)
local MiniMapPanel = Lplus.ForwardDeclare("MiniMapPanel")
local def = BattlefieldMiniMapMgr.define
def.field("table").m_enabledUnits = nil
local instance
def.static("=>", BattlefieldMiniMapMgr).Instance = function()
  if instance == nil then
    instance = BattlefieldMiniMapMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MINI_MAP_READY, BattlefieldMiniMapMgr.OnMiniMapReady)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MINI_MAP_DESTROYED, BattlefieldMiniMapMgr.OnMiniMapDestroyed)
end
def.method().CheckAndInitUnits = function(self)
  if not _G.PlayerIsInState(_G.RoleState.SINGLEBATTLE) then
    return
  end
  local BattleFieldMgr = require("Main.CaptureTheFlag.mgr.BattleFieldMgr")
  local CTFFeature = require("Main.CaptureTheFlag.mgr.CTFFeature")
  local features = BattleFieldMgr.Instance():GetAllActiveFeatures()
  local featureNameMapMgrClass = {
    CTFFeature = "BattlefieldMapFlagMgr",
    BuffFeature = "BattlefieldMapBuffMgr",
    RobGroundResFeature = "BattlefieldMapResMgr"
  }
  self.m_enabledUnits = {}
  for i, v in ipairs(features) do
    local className = featureNameMapMgrClass[v:getType():getName()]
    if className then
      local unit = self:NewUnit(className)
      table.insert(self.m_enabledUnits, unit)
    end
  end
  local unit = self:NewUnit("BattlefieldMapRoleMgr")
  table.insert(self.m_enabledUnits, unit)
end
def.method().DestroyUnits = function(self)
  if self.m_enabledUnits == nil then
    return
  end
  for i, v in ipairs(self.m_enabledUnits) do
    v:Destroy()
  end
  self.m_enabledUnits = nil
end
def.method("string", "=>", "table").NewUnit = function(self, className)
  local ClassType = import("." .. className, MODULE_NAME)
  local obj = ClassType()
  obj:Create({
    miniMap = MiniMapPanel.Instance()
  })
  return obj
end
def.static("table", "table").OnMiniMapReady = function(params, context)
  instance:CheckAndInitUnits()
end
def.static("table", "table").OnMiniMapDestroyed = function(params, context)
  instance:DestroyUnits()
end
return BattlefieldMiniMapMgr.Commit()
