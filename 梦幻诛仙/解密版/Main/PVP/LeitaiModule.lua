local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local LeitaiModule = Lplus.Extend(ModuleBase, "LeitaiModule")
require("Main.module.ModuleId")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECPlayer = Lplus.ForwardDeclare("ECPlayer")
local def = LeitaiModule.define
local instance
def.field("table").soloList = nil
def.field("table").teamList = nil
def.field("table").fightList = nil
def.static("=>", LeitaiModule).Instance = function()
  if instance == nil then
    instance = LeitaiModule()
    instance.m_moduleId = ModuleId.LEITAI
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.leitai.SRefreshSingleListRes", LeitaiModule.OnSRefreshSoloList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.leitai.SRefreshTeamListRes", LeitaiModule.OnSRefreshTeamList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.leitai.SRefreshFightListRes", LeitaiModule.OnSFightList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.leitai.SLeiTaiNormalResult", LeitaiModule.OnSNotify)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, LeitaiModule.OnNPCService)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, LeitaiModule.OnLeaveWorld)
end
def.static("table").OnSRefreshSoloList = function(p)
  instance.soloList = p.leitaiRoleList
  Event.DispatchEvent(ModuleId.LEITAI, gmodule.notifyId.PVP.UPDATE_LEITAI_INFO, nil)
end
def.static("table").OnSRefreshTeamList = function(p)
  instance.teamList = p.leitaiTeamRoleList
  Event.DispatchEvent(ModuleId.LEITAI, gmodule.notifyId.PVP.UPDATE_LEITAI_INFO, nil)
end
def.static("table").OnSFightList = function(p)
  instance.fightList = p.leitaiFightInfoList
  Event.DispatchEvent(ModuleId.LEITAI, gmodule.notifyId.PVP.UPDATE_LEITAI_INFO, nil)
end
def.static("table").OnSNotify = function(p)
  local tip
  if p.result == p.class.ALREADY_LEAVE_LEITAI then
    tip = textRes.Leitai[1]
  elseif p.result == p.class.TARGET_LEAVE_LEITAI then
    tip = textRes.Leitai[2]
  elseif p.result == p.class.TARGET_NOT_LEADER then
    tip = textRes.Leitai[3]
  end
  if tip then
    Toast(tip)
  end
end
def.static("table", "table").OnNPCService = function(p1, p2)
  local serviceID = p1[1]
  if serviceID and serviceID == require("Main.npc.NPCServiceConst").LeiTaiPK then
    require("Main.PVP.ui.DlgLeitai").Instance():ShowDlg()
  end
end
def.static("table", "table").OnLeaveWorld = function()
  instance.soloList = nil
  instance.teamList = nil
  instance.fightList = nil
end
LeitaiModule.Commit()
return LeitaiModule
