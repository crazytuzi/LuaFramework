local MODULE_NAME = (...)
local Lplus = require("Lplus")
local HomelandModule = require("Main.Homeland.HomelandModule")
local HomelandNPCNavigator = Lplus.Class(MODULE_NAME)
local def = HomelandNPCNavigator.define
def.field("table").m_gotoInfo = nil
local instance
def.static("=>", HomelandNPCNavigator).Instance = function()
  if instance == nil then
    instance = HomelandNPCNavigator()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.ENTER_HOMELAND, HomelandNPCNavigator.OnEnterHomeland)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, HomelandNPCNavigator.OnLeaveWorld)
end
def.method("number", "number", "=>", "boolean").GotoHomelandNPC = function(self, mapId, npcId)
  TODO("\231\155\174\229\137\141\229\143\170\229\174\158\231\142\176\228\186\134\229\175\187\232\183\175\229\136\176\229\186\173\233\153\162npc\231\154\132\233\128\187\232\190\145")
  self.m_gotoInfo = {mapId = mapId, npcId = npcId}
  if HomelandModule.Instance():IsInSelfCourtyard() then
    self:CheckAndFinishMission()
    return true
  else
    local state = HomelandModule.Instance():ReturnHome()
    if state == false then
      self.m_gotoInfo = nil
    end
    return state
  end
end
def.method().CheckAndFinishMission = function(self)
  if self.m_gotoInfo == nil then
    return
  end
  local npcId = self.m_gotoInfo.npcId
  self.m_gotoInfo = nil
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npcId})
end
def.method().Clear = function(self)
  self.m_gotoInfo = nil
end
def.static("table", "table").OnEnterHomeland = function(params, context)
  instance:CheckAndFinishMission()
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  instance:Clear()
end
return HomelandNPCNavigator.Commit()
