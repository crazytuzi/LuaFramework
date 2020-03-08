local Lplus = require("Lplus")
local SocialPlatformMgr = Lplus.Class("SocialPlatformMgr")
local PersonalInfoInterface = require("Main.PersonalInfo.PersonalInfoInterface")
local Octets = require("netio.Octets")
local HeroUtility = require("Main.Hero.HeroUtility")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local QingYuanMgr = require("Main.QingYuan.QingYuanMgr")
local def = SocialPlatformMgr.define
def.const("table").SocialGender = {
  ALL = -1,
  MALE = 102100000,
  FEMALE = 102100001
}
def.const("table").SocialLevelOp = {LT = 0, GT = 1}
def.const("table").SocialProvince = {NO_LIMIT = -1}
def.const("table").DataKey = {
  LAST_SEND_SNS_TIME = "LAST_SEND_SNS_TIME",
  LAST_DELETE_SNS_TIME = "LAST_DELETE_SNS_TIME",
  LAST_REFRESH_TIME = "LAST_REFRESH_TIME"
}
def.const("table").SocialTypeId = {QINGYUAN = 103000004}
def.field("table").snsTypeCfg = nil
def.field("table").searchFilter = nil
def.field("table").selfSNSInfo = nil
def.field("table").searchResult = nil
def.field("number").lastOpenTab = constant.SNSConsts.ALL_SUB_TYPE_ID
def.field("number").lastMaxLevel = -1
local instance
def.static("=>", SocialPlatformMgr).Instance = function()
  if instance == nil then
    instance = SocialPlatformMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, SocialPlatformMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, SocialPlatformMgr.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, SocialPlatformMgr.OnFeatureChange)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.SYNC_SERVER_LEVEL, SocialPlatformMgr.OnSynServerLevel)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.personal.SReleaseAdvertSuccess", SocialPlatformMgr.OnPublishInfoSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.personal.SReleaseAdvertFailed", SocialPlatformMgr.OnPublishInfoFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.personal.SAdvertsSuccess", SocialPlatformMgr.OnReceiveSelfSNSInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.personal.SAdvertsFailed", SocialPlatformMgr.OnPullSelfSNSInfoFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.personal.SDeleteAdvertSuccess", SocialPlatformMgr.OnDeleteSelfSNSInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.personal.SDeleteAdvertFailed", SocialPlatformMgr.OnDeleteSelfSNSInfoFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.personal.SSearchAdvertsSuccess", SocialPlatformMgr.OnReceiveWorldSNSInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.personal.SSearchAdvertsFailed", SocialPlatformMgr.OnSearchWorldSNSInfoFail)
end
def.method().Reset = function(self)
  self.selfSNSInfo = nil
  self.searchResult = nil
  self.searchFilter = nil
  self.lastOpenTab = constant.SNSConsts.ALL_SUB_TYPE_ID
  self.lastMaxLevel = -1
end
def.method("number").InitSearchFilter = function(self, advertType)
  if self.searchFilter == nil then
    self.searchFilter = {}
  end
  local filter = {}
  filter.gender = SocialPlatformMgr.SocialGender.ALL
  filter.levelOp = SocialPlatformMgr.SocialLevelOp.LT
  filter.minLevel = self:GetMinRoleLevel()
  filter.maxLevel = self:GetMaxRoleLevel()
  filter.province = SocialPlatformMgr.SocialProvince.NO_LIMIT
  self.searchFilter[advertType] = filter
end
def.method("=>", "number").GetMinRoleLevel = function()
  return constant.SNSConsts.OPEN_LEVEL
end
def.method("=>", "number").GetMaxRoleLevel = function()
  local serverLevelData = require("Main.Server.ServerModule").Instance():GetServerLevelInfo()
  if serverLevelData == nil then
    return constant.SNSConsts.OPEN_LEVEL
  else
    local offsetLevel = HeroUtility.Instance():GetRoleCommonConsts("ROLE_LEVEL_MORE_THAN_SERVER_LEVEL")
    return serverLevelData.level + offsetLevel
  end
end
def.method("number", "number", "number", "number", "number", "number").SetSearchFilter = function(self, advertType, gender, levelOp, minLevel, maxLevel, province)
  local filter = self:GetSearchFilter(advertType)
  if filter == nil then
    return
  end
  local hasChange = false
  if filter.gender ~= gender then
    filter.gender = gender
    hasChange = true
  end
  if filter.minLevel ~= minLevel then
    filter.minLevel = minLevel
    hasChange = true
  end
  if filter.maxLevel ~= maxLevel then
    filter.maxLevel = maxLevel
    hasChange = true
  end
  if filter.province ~= province then
    filter.province = province
    hasChange = true
  end
  if filter.levelOp ~= levelOp then
    filter.levelOp = levelOp
    hasChange = true
  end
  if hasChange then
    Event.DispatchEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.SEARCH_FILTER_CHANGE, nil)
  end
end
def.method("number", "=>", "table").GetSearchFilter = function(self, advertType)
  if self.searchFilter == nil or self.searchFilter[advertType] == nil then
    self:InitSearchFilter(advertType)
  end
  return self.searchFilter[advertType]
end
def.method("=>", "table").GetSNSTypeCfg = function(self)
  if self.snsTypeCfg == nil then
    self:LazyLoadSNSTypeCfg()
  end
  return self.snsTypeCfg
end
def.method().LazyLoadSNSTypeCfg = function(self)
  self.snsTypeCfg = PersonalInfoInterface.GetSNSTypeCfgList()
end
def.method("=>", "table").GetSelfSNSInfo = function(self)
  if self.selfSNSInfo == nil then
    return {}
  else
    return self.selfSNSInfo
  end
end
def.method("number").RemoveSelfSNSInfoByType = function(self, advertType)
  if self.selfSNSInfo ~= nil then
    for idx, SNSInfo in ipairs(self.selfSNSInfo) do
      if SNSInfo.advertType == advertType then
        table.remove(self.selfSNSInfo, idx)
        return
      end
    end
  end
end
def.method("table").SetSearchResult = function(self, p)
  if self.searchResult == nil then
    self.searchResult = {}
  end
  local key = string.format("%d", p.advertType)
  if self.searchResult[key] == nil then
    self.searchResult[key] = {}
    self.searchResult[key].page = p.page
    self.searchResult[key].totalSize = 0
    self.searchResult[key].SNSInfoList = nil
  end
  local result = self.searchResult[key]
  result.page = p.page
  result.totalSize = p.size
  result.SNSInfoList = p.adverts
end
def.method("number", "=>", "table").GetCurrentSearchResult = function(self, advertType)
  if self.searchResult == nil then
    return nil
  end
  local key = string.format("%d", advertType)
  return self.searchResult[key]
end
def.method("number", "number", "=>", "table").GetSNSInfoByAdvertId = function(self, advertType, advertId)
  if self.searchResult == nil then
    return nil
  end
  local key = string.format("%d", advertType)
  local curResult = self.searchResult[key]
  if curResult == nil then
    return nil
  end
  for idx, sns in pairs(curResult.SNSInfoList) do
    if Int64.eq(sns.advertId, advertId) then
      return sns
    end
  end
  return nil
end
def.method("number", "=>", "boolean").HasSearchResultOfType = function(self, advertType)
  if self.searchResult == nil then
    return false
  end
  local key = string.format("%d", advertType)
  return self.searchResult[key] ~= nil
end
def.method("number", "=>", "number").GetLastSearchPageOfType = function(self, advertType)
  if self:HasSearchResultOfType(advertType) then
    local key = string.format("%d", advertType)
    return self.searchResult[key].page
  else
    return 1
  end
end
def.method("number").SetOpenAdvertType = function(self, advertType)
  self.lastOpenTab = advertType
end
def.method("=>", "number").GetOpenAdvertType = function(self)
  return self.lastOpenTab
end
def.method().VerifySearchFilter = function(self)
  if self.lastMaxLevel == -1 or self.searchFilter == nil then
    return
  end
  for advertType, filter in pairs(self.searchFilter) do
    if filter.minLevel == self.lastMaxLevel then
      filter.minLevel = self:GetMaxRoleLevel()
    end
    if filter.maxLevel == self.lastMaxLevel then
      filter.maxLevel = self:GetMaxRoleLevel()
    end
  end
  Event.DispatchEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.SEARCH_FILTER_AJUST, nil)
end
def.static("number", "string").PublicshSNSInfo = function(subTypeId, content)
  if not SocialPlatformMgr.IsOpen() then
    Toast(textRes.Personal[234])
    return
  end
  local advert = require("netio.protocol.mzm.gsp.personal.SimpleAdvertInfo").new(subTypeId, Octets.rawFromString(content))
  local req = require("netio.protocol.mzm.gsp.personal.CReleaseAdvert").new(advert)
  gmodule.network.sendProtocol(req)
end
def.static("table").OnPublishInfoSuccess = function(p)
  Toast(textRes.Personal[203])
  Event.DispatchEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.PUBLISH_INFO_SUCCESS, nil)
  SocialPlatformMgr.SaveSendSNSTime(p.advertType, GetServerTime())
end
def.static("table").OnPublishInfoFail = function(p)
  if textRes.Personal.AdvertRet[p.retcode] ~= nil then
    Toast(textRes.Personal.AdvertRet[p.retcode])
  else
    Toast(textRes.Personal[204])
  end
  Event.DispatchEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.PUBLISH_INFO_FAIL, nil)
end
def.static().PullSelfSNSInfo = function()
  if not SocialPlatformMgr.IsOpen() then
    Toast(textRes.Personal[234])
    return
  end
  local req = require("netio.protocol.mzm.gsp.personal.CAdverts").new()
  gmodule.network.sendProtocol(req)
end
def.static("table").OnReceiveSelfSNSInfo = function(p)
  local self = instance
  self.selfSNSInfo = p.adverts
  if self.selfSNSInfo == nil or #self.selfSNSInfo == 0 then
    Toast(textRes.Personal[206])
    return
  end
  Event.DispatchEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.RECEIVE_SELF_SNS, nil)
end
def.static("table").OnPullSelfSNSInfoFail = function(p)
  if textRes.Personal.AdvertRet[p.retcode] ~= nil then
    Toast(textRes.Personal.AdvertRet[p.retcode])
  else
    Toast(textRes.Personal[205])
  end
end
def.static("number").DeleteSelfSNSInfo = function(advertType)
  if not SocialPlatformMgr.IsOpen() then
    Toast(textRes.Personal[234])
    return
  end
  local req = require("netio.protocol.mzm.gsp.personal.CDeleteAdvert").new(advertType)
  gmodule.network.sendProtocol(req)
end
def.static("table").OnDeleteSelfSNSInfo = function(p)
  local self = instance
  self:RemoveSelfSNSInfoByType(p.advertType)
  Event.DispatchEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.SELF_SNS_CHANGE, nil)
  SocialPlatformMgr.SaveDeleteSNSTime(p.advertType, GetServerTime())
  Toast(textRes.Personal[221])
end
def.static("table").OnDeleteSelfSNSInfoFail = function(p)
  if textRes.Personal.AdvertRet[p.retcode] ~= nil then
    Toast(textRes.Personal.AdvertRet[p.retcode])
  else
    Toast(textRes.Personal[208])
  end
end
def.static("number", "number").SearchWorldSNSInfo = function(advertType, pageNum)
  if not SocialPlatformMgr.IsOpen() then
    Toast(textRes.Personal[234])
    return
  end
  local self = instance
  if self ~= nil then
    local searchFilter = self:GetSearchFilter(advertType)
    if searchFilter == nil then
      return
    end
    local condition = require("netio.protocol.mzm.gsp.personal.ConditionInfo").new(searchFilter.gender, searchFilter.minLevel, searchFilter.maxLevel, searchFilter.province)
    local req = require("netio.protocol.mzm.gsp.personal.CSearchAdverts").new(advertType, pageNum, 0, condition)
    gmodule.network.sendProtocol(req)
  end
end
def.static("number", "number").RefreshWorldSNSInfo = function(advertType, pageNum)
  if not SocialPlatformMgr.IsOpen() then
    Toast(textRes.Personal[234])
    return
  end
  local self = instance
  if self ~= nil then
    local searchFilter = self:GetSearchFilter(advertType)
    if searchFilter == nil then
      return
    end
    local condition = require("netio.protocol.mzm.gsp.personal.ConditionInfo").new(searchFilter.gender, searchFilter.minLevel, searchFilter.maxLevel, searchFilter.province)
    local req = require("netio.protocol.mzm.gsp.personal.CSearchAdverts").new(advertType, pageNum, 1, condition)
    gmodule.network.sendProtocol(req)
    SocialPlatformMgr.SaveLastRefreshTime(GetServerTime())
  end
end
def.static("table").OnReceiveWorldSNSInfo = function(p)
  local self = instance
  self:SetSearchResult(p)
  Event.DispatchEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.RECEIVE_WORLD_SNS, nil)
end
def.static("table").OnSearchWorldSNSInfoFail = function(p)
  if textRes.Personal.AdvertRet[p.retcode] ~= nil then
    Toast(textRes.Personal.AdvertRet[p.retcode])
  else
    Toast(textRes.Personal[211])
  end
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  if instance ~= nil then
    instance:Reset()
  end
end
def.static("table", "table").OnSynServerLevel = function(params, context)
  if instance ~= nil then
    instance:VerifySearchFilter()
    instance.lastMaxLevel = instance:GetMaxRoleLevel()
  end
end
def.static("number", "number").SaveSendSNSTime = function(advertType, t)
  LuaPlayerPrefs.SetRoleNumber(SocialPlatformMgr.DataKey.LAST_SEND_SNS_TIME .. "_" .. advertType, t)
end
def.static("number", "number").SaveDeleteSNSTime = function(advertType, t)
  LuaPlayerPrefs.SetRoleNumber(SocialPlatformMgr.DataKey.LAST_DELETE_SNS_TIME .. "_" .. advertType, t)
end
def.static("number", "=>", "number").GetLeftTimeBeforeSendSNS = function(advertType)
  local lastSendTime = LuaPlayerPrefs.GetRoleNumber(SocialPlatformMgr.DataKey.LAST_SEND_SNS_TIME .. "_" .. advertType)
  local lastDeleteTime = LuaPlayerPrefs.GetRoleNumber(SocialPlatformMgr.DataKey.LAST_DELETE_SNS_TIME .. "_" .. advertType)
  local leftCDTime = 0
  if lastSendTime < lastDeleteTime then
    leftCDTime = constant.SNSConsts.RELEASE_INTERVAL * 60 - (GetServerTime() - lastDeleteTime)
  else
    leftCDTime = constant.SNSConsts.VALID_MAX_TIME * 60 - (GetServerTime() - lastSendTime)
  end
  return leftCDTime > 0 and leftCDTime or 0
end
def.static("number").SaveLastRefreshTime = function(t)
  LuaPlayerPrefs.SetRoleNumber(SocialPlatformMgr.DataKey.LAST_REFRESH_TIME, t)
end
def.static("=>", "number").GetLeftTimeBeforeRefresh = function()
  local lastRefreshTime = LuaPlayerPrefs.GetRoleNumber(SocialPlatformMgr.DataKey.LAST_REFRESH_TIME)
  local leftCDTime = constant.SNSConsts.REFRESH_INTERVAL - (GetServerTime() - lastRefreshTime)
  return leftCDTime > 0 and leftCDTime or 0
end
def.static("=>", "boolean").IsReachTargetLevel = function(self)
  local heroProp = require("Main.Hero.mgr.HeroPropMgr").Instance():GetHeroProp()
  if heroProp == nil then
    return false
  end
  return heroProp.level >= constant.SNSConsts.OPEN_LEVEL
end
def.static("=>", "boolean").IsOpen = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_SNS) then
    return false
  end
  return SocialPlatformMgr.IsReachTargetLevel()
end
def.static("table", "table").OnHeroLevelUp = function(p1, p2)
  if SocialPlatformMgr.IsReachTargetLevel() then
    Event.DispatchEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.SOCIAL_PLATFORM_OPEN_CHANGE, {
      open = SocialPlatformMgr.IsOpen()
    })
  end
end
def.static("table", "table").OnFeatureChange = function(p1, p2)
  local feature = p1.feature
  if feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_SNS and SocialPlatformMgr.IsReachTargetLevel() then
    Event.DispatchEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.SOCIAL_PLATFORM_OPEN_CHANGE, {
      open = SocialPlatformMgr.IsOpen()
    })
  end
end
def.static("number", "=>", "boolean").IsSocialTypeFunctionOpen = function(typeId)
  if typeId == SocialPlatformMgr.SocialTypeId.QINGYUAN and not QingYuanMgr.Instance():IsQingYuanFunctionOpen() then
    return false
  end
  return true
end
return SocialPlatformMgr.Commit()
