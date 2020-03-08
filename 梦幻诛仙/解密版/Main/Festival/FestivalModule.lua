local Lplus = require("Lplus")
local FestivalMgr = require("Main.Festival.FestivalMgr")
local ModuleBase = require("Main.module.ModuleBase")
local FestivalModule = Lplus.Extend(ModuleBase, "FestivalModule")
local def = FestivalModule.define
local instance
def.static("=>", FestivalModule).Instance = function()
  if instance == nil then
    instance = FestivalModule()
    instance.m_moduleId = ModuleId.FESTIVAL
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_ROLE_SUCCESS, FestivalModule.OnLoginSuccess)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, FestivalModule.OnFestivalService)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.festival.SFestivalInfoRes", FestivalModule.OnSFestivalInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.festival.SNextFestivalInfoRes", FestivalModule.OnSNextFestivalInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.festival.STakeFestivalAwardRes", FestivalModule.OnSTakeFestivalAwardRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.festival.SFestivalNormalRet", FestivalModule.OnSFestivalNormalRet)
  require("Main.Festival.FoolsDay.FoolsDayMgr").Instance():Init()
  require("Main.Festival.ChildrensDay.ChildrensDayMgr").Instance():Init()
end
def.static("table", "table").OnLoginSuccess = function(p1, p2)
  FestivalMgr.Instance():RegisterFestivalNPCWait()
end
def.static("table", "table").OnFestivalService = function(p1, p2)
  local NPCServiceConst = require("Main.npc.NPCServiceConst")
  local serviceId = p1[1]
  if serviceId == NPCServiceConst.FestivalDesc then
    FestivalMgr.Instance():OnFestivalDescService()
  elseif serviceId == NPCServiceConst.FestivalAward then
    FestivalMgr.Instance():OnFestivalAwardService()
  end
end
def.static("table").OnSFestivalInfoRes = function(p)
  FestivalMgr.Instance():SetFestivalState(p)
  if FestivalMgr.Instance():IsAwardAvailable() then
    FestivalMgr.Instance():SetFestivalNPCService()
  else
    FestivalMgr.Instance():ReqNextFestivalInfo()
  end
end
def.static("table").OnSNextFestivalInfoRes = function(p)
  FestivalMgr.Instance():SetNextFestivalId(p)
  FestivalMgr.Instance():SetFestivalNPCService()
end
def.static("table").OnSTakeFestivalAwardRes = function(p)
  local festivalInfoRes = require("netio.protocol.mzm.gsp.festival.SFestivalInfoRes")
  local state = {
    festivalAwardid = p.festivalAwardid,
    awardState = festivalInfoRes.TAKED
  }
  FestivalMgr.Instance():SetFestivalState(state)
end
def.static("table").OnSFestivalNormalRet = function(p)
  Toast(textRes.Festival.ErrorCode[p.ret + 1])
end
def.override().OnReset = function(self)
  FestivalMgr.Instance():Reset()
end
FestivalModule.Commit()
return FestivalModule
