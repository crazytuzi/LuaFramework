local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local ImagePvpModule = Lplus.Extend(ModuleBase, "ImagePvpModule")
require("Main.module.ModuleId")
local ActivityInterface = require("Main.activity.ActivityInterface")
local DlgImagePvp = require("Main.PVP.ui.DlgImagePvp")
local def = ImagePvpModule.define
local instance
def.field("table").data = nil
def.field("number").endTime = 0
def.static("=>", ImagePvpModule).Instance = function()
  if instance == nil then
    instance = ImagePvpModule()
    instance.m_moduleId = ModuleId.IMAGEPVP
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.jingji.SSynJingjiData", ImagePvpModule.OnSSyncImageData)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.jingji.SSynJingjiSeasonEndtime", ImagePvpModule.OnSSyncDate)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.jingji.SResOpponentInfo", ImagePvpModule.OnSRivalChanged)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.jingji.SErrorInfo", ImagePvpModule.OnSErrorInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.jingji.SsynJingjiDataChanged", ImagePvpModule.OnSDataChanged)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.jingji.SsynRewardChanged", ImagePvpModule.OnSRewardChanged)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.jingji.SBuyChallengeCountRes", ImagePvpModule.OnSSyncTimes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.jingji.SJIngjiNoAwardRes", ImagePvpModule.OnSJIngjiNoAwardRes)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, ImagePvpModule.OnActivityTodo)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, ImagePvpModule.OnLeaveWorld)
end
def.static("table").OnSSyncImageData = function(p)
  if instance.data then
    instance.data = p
    DlgImagePvp.Instance():ShowDlg()
  end
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  local activityId = p1[1]
  if activityId and activityId == constant.JingjiActivityCfgConsts.IMAGE_PVP then
    local myRole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
    if myRole and (myRole:IsInState(RoleState.HUG) or myRole:IsInState(RoleState.BEHUG)) then
      Toast(textRes.HeroStatus.ErrorCode[472])
      return
    end
    if myRole and myRole:IsInState(RoleState.UNTRANPORTABLE) then
      Toast(textRes.PVP[12])
      return
    end
    instance.data = instance.data or {}
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.jingji.CJoinJingjiPVPReq").new())
  end
end
def.method("number", "=>", "table").GetPhaseData = function(self, id)
  local record = DynamicData.GetRecord("data/cfg/mzm.gsp.activity.confbean.CJingjiPhaseCfg.bny", id)
  if record == nil then
    warn("[ImagePvp](GetPhaseData) get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.phaseName = record:GetStringValue("phaseName")
  cfg.maxWinPoint = record:GetIntValue("maxWinPoint")
  cfg.minWinPoint = record:GetIntValue("minWinPoint")
  return cfg
end
def.static("table").OnSSyncDate = function(p)
  instance.endTime = p.seasonEndTime:ToNumber()
  DlgImagePvp.Instance():SetEndTime()
end
def.method("string", "=>", "number").GetConst = function(self, k)
  local record = DynamicData.GetRecord("data/cfg/mzm.gsp.activity.confbean.JingjiActivityCfgConsts.bny", k)
  if record == nil then
    return
  end
  return record:GetIntValue("value")
end
def.static("table").OnSRivalChanged = function(p)
  local dlg = require("Main.PVP.ui.DlgImagePvp").Instance()
  dlg.rivalList = p.opponentList
  dlg:SetRivals(p)
end
def.static("table").OnSErrorInfo = function(p)
  local errorStr
  if p.errorCode == p.ROLE_LEVLE_ERROR then
    errorStr = textRes.PVP[10]
  elseif p.errorCode == p.ROLE_IN_TEAM then
    errorStr = textRes.PVP[11]
  elseif p.errorCode == p.FRESH_ERROR then
    errorStr = textRes.PVP[20]
  elseif p.errorCode == p.CHANLLENGE_COUNT_NOT_ENOUGH then
    errorStr = textRes.PVP[21]
  end
  if errorStr then
    Toast(errorStr)
  end
end
def.static("table", "table").OnLeaveWorld = function()
  instance.data = nil
  instance.endTime = 0
end
def.static("table").OnSDataChanged = function(p)
  DlgImagePvp.OnSDataChanged(p)
end
def.static("table").OnSRewardChanged = function(p)
  DlgImagePvp.OnSRewardChanged(p)
end
def.static("table").OnSSyncTimes = function(p)
  DlgImagePvp.OnSSyncTimes(p)
end
def.static("table").OnSJIngjiNoAwardRes = function(p)
  Toast(textRes.PVP[26])
end
ImagePvpModule.Commit()
return ImagePvpModule
