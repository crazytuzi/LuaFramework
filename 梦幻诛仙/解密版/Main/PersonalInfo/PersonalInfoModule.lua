local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local PersonalInfoModule = Lplus.Extend(ModuleBase, "PersonalInfoModule")
local PersonalInfoInterface = require("Main.PersonalInfo.PersonalInfoInterface")
local personalInfoInterface = PersonalInfoInterface.Instance()
local FieldType = require("consts.mzm.gsp.personal.confbean.FieldType")
local PersonalRet = require("netio.protocol.mzm.gsp.personal.PersonalRet")
local SocialPlatformMgr = require("Main.PersonalInfo.mgr.SocialPlatformMgr")
local def = PersonalInfoModule.define
local instance
def.static("=>", PersonalInfoModule).Instance = function()
  if instance == nil then
    instance = PersonalInfoModule()
    instance.m_moduleId = ModuleId.PERSONAL_INFO
  end
  return instance
end
def.override().Init = function()
  SocialPlatformMgr.Instance():Init()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.personal.SQueryPersonalInfoSuccess", PersonalInfoModule.OnSQueryPersonalInfoSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.personal.SQueryPersonalInfoFailed", PersonalInfoModule.OnSQueryPersonalInfoFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.personal.SEditPersonalInfoSuccess", PersonalInfoModule.OnSEditPersonalInfoSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.personal.SEditPersonalInfoFailed", PersonalInfoModule.OnSEditPersonalInfoFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.personal.SPraisePersonalSuccess", PersonalInfoModule.OnSPraisePersonalSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.personal.SPraisePersonalFailed", PersonalInfoModule.OnSPraisePersonalFailed)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, PersonalInfoModule.OnNPCService)
end
def.override().OnReset = function()
end
def.static("table").OnSQueryPersonalInfoSuccess = function(p)
  personalInfoInterface:setPersonalInfo(p.roleId, p.personalInfo)
  PersonalInfoModule.ShowPlayerInfoPanel(p.roleId)
end
def.static("userdata").ShowPlayerInfoPanel = function(roleId)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  if heroProp.id == roleId then
    require("Main.PersonalInfo.ui.PersonalInfoPanel").Instance():ShowPanel(roleId)
  else
    require("Main.PersonalInfo.ui.PlayerInfoPanel").ShowPanel(roleId)
  end
end
def.static("table").OnSQueryPersonalInfoFailed = function(p)
  warn("-------OnSQueryPersonalInfoFailed:", p.roleId, p.retcode)
  if p.retcode == PersonalRet.ROLE_NOT_EXIST then
    Toast(textRes.Personal[18])
  end
end
def.static("table").OnSEditPersonalInfoSuccess = function(p)
  personalInfoInterface:setPersonalEditInfo(p.roleId, p.personalInfo)
  Event.DispatchEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.EDIT_SUCCESS, {})
end
def.static("table").OnSEditPersonalInfoFailed = function(p)
  warn("-------OnSEditPersonalInfoFailed:", p.roleId, p.retcode)
  if p.retcode == PersonalRet.SIGN_INVALID then
    Toast(textRes.Personal[15])
  elseif p.retcode == PersonalRet.SIGN_LENGTH_INVALID then
    Toast(textRes.Personal[16])
  elseif p.retcode == PersonalRet.SCHOOL_LENGTH_INVALID then
    Toast(textRes.Personal[17])
  end
end
def.static("table").OnSPraisePersonalSuccess = function(p)
  local personalInfo = personalInfoInterface:getPersonalInfo(p.roleId)
  personalInfo:setPraiseNum(p.praiseNum, p.praise)
  Event.DispatchEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.PRAISE_SUCCESS, {
    p.roleId
  })
end
def.static("table").OnSPraisePersonalFailed = function(p)
  warn("------OnSPraisePersonalFailed:", p.roleId, p.retcode)
  if p.retcode == PersonalRet.DAILY_PRAISE_SOMEONE_MAX then
    Toast(textRes.Personal[19])
  elseif p.retcode == PersonalRet.DAILY_PRAISE_MAX then
    Toast(textRes.Personal[20])
  elseif p.retcode == PersonalRet.PRAISE_MAX then
    Toast(textRes.Personal[21])
  end
end
def.static("number").OpenPublishSNSInfoPanel = function(subTypeId)
  require("Main.PersonalInfo.ui.PublishSNSInfoPanel").Instance():ShowPublishSNSInfoPanel(subTypeId)
end
def.static("number").OpenSNSFilterPanel = function(advertType)
  require("Main.PersonalInfo.ui.SNSFilterPanel").Instance():ShowSNSFilterPanel(advertType)
end
def.static().OpenSNSInfoManagePanel = function()
  require("Main.PersonalInfo.ui.ManageSNSInfoPanel").Instance():ShowManageSNSInfoPanel()
end
def.static().QuickEditPersonalInfo = function()
  Event.DispatchEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.QUICK_EDIT_INFO, nil)
end
def.static("table", "table").OnNPCService = function(params, context)
  local npcId = params[2]
  local serviceId = params[1]
  local snsTypeCfg = PersonalInfoInterface.GetSNSSubTypeByNPCService(serviceId)
  if snsTypeCfg ~= nil then
    if not SocialPlatformMgr.IsReachTargetLevel() then
      Toast(string.format(textRes.Personal[236], constant.SNSConsts.OPEN_LEVEL))
      return
    end
    if not SocialPlatformMgr.IsOpen() then
      Toast(textRes.Personal[234])
      return
    end
    local advertType = snsTypeCfg.id
    SocialPlatformMgr.Instance():SetOpenAdvertType(advertType)
    local PersonalInfoPanel = require("Main.PersonalInfo.ui.PersonalInfoPanel")
    PersonalInfoPanel.Instance():SetStartTabNodeId(PersonalInfoPanel.NodeId.SOCIAL_PLATFORM)
    PersonalInfoInterface.Instance():CheckPersonalInfo(GetMyRoleID(), "")
  end
end
def.method("userdata").LoadPlayerSocialSpaceData = function(self, roleId)
  if roleId == nil then
    warn("LoadPlayerSocialSpaceData roleId is nil")
    return
  end
  if gmodule.moduleMgr:GetModule(ModuleId.SOCIAL_SPACE):IsFeatureOpen() then
    gmodule.moduleMgr:GetModule(ModuleId.SOCIAL_SPACE):LoadSpaceData(roleId, function(spaceData)
      if spaceData == nil then
        return
      end
      Event.DispatchEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.RECEIVE_SPACE_DATA, spaceData)
    end, {uptodate = true})
  end
end
return PersonalInfoModule.Commit()
