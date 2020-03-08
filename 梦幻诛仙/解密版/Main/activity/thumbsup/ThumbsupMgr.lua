local Lplus = require("Lplus")
local UseType = require("consts.mzm.gsp.giftaward.confbean.UseType")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local ThumbsupMgr = Lplus.Class("ThumbsupMgr")
local def = ThumbsupMgr.define
local instance
def.static("=>", ThumbsupMgr).Instance = function()
  if instance == nil then
    instance = ThumbsupMgr()
  end
  return instance
end
def.field("number")._mThumbsupCount = 0
def.field("number")._mTimerID = 0
def.method().Init = function(self)
  self:CheckOpenState()
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, ThumbsupMgr.OnFunctionOpenChange)
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  if p1.feature == ModuleFunSwitchInfo.TYPE_NEW_CLIENT then
    ThumbsupMgr.Instance():CheckOpenState()
  end
end
def.method().GoThumbsup = function(self)
  require("Main.ECGame").Instance():OpenUrl(self:GetUrl())
  self:OnActivityStart()
end
def.method("=>", "string").GetUrl = function(self)
  local msdklinkcfg = DynamicData.GetRecord(CFG_PATH.DATA_BTN_LINK_CFG, constant.CThumbsupConsts.THUMBSUP_URL_ID)
  local url = msdklinkcfg and msdklinkcfg:GetStringValue("url") or ""
  warn(string.format("[ThumbsupMgr:GetUrl] Get thumbsup Url:{%s}.", url))
  return url
end
def.method().OnActivityStart = function(self)
  self:ClearTimer()
  self._mTimerID = GameUtil.AddGlobalTimer(constant.CThumbsupConsts.FINISH_COUNTDOWN, true, function()
    self:OnActivityEnd()
  end)
end
def.method().OnActivityEnd = function(self)
  self:ClearTimer()
  self:SendCGetGiftReq()
end
def.method().SendCGetGiftReq = function(self)
  local p = require("netio.protocol.mzm.gsp.award.CGetGiftReq").new(UseType.FACE_BOOK__PRAISE)
  gmodule.network.sendProtocol(p)
end
def.method().OnLeaveWorld = function(self)
  self:Reset()
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, ThumbsupMgr.OnFunctionOpenChange)
end
def.method().Reset = function(self)
  self._mThumbsupCount = 0
  self:ClearTimer()
end
def.method().ClearTimer = function(self)
  if self._mTimerID ~= 0 then
    GameUtil.RemoveGlobalTimer(self._mTimerID)
    self._mTimerID = 0
  end
end
def.method("number").SetThumbsupCount = function(self, count)
  self._mThumbsupCount = count
  self:CheckOpenState()
end
def.method().CheckOpenState = function(self)
  if not self:IsActivityOpen() or not self:IsFeatureOpen() then
    activityInterface:addCustomCloseActivity(constant.CThumbsupConsts.ACTIVITY_CFG_ID)
  elseif not self:IsActivityFinished() then
    activityInterface:removeCustomCloseActivity(constant.CThumbsupConsts.ACTIVITY_CFG_ID)
  else
    activityInterface:addCustomCloseActivity(constant.CThumbsupConsts.ACTIVITY_CFG_ID)
  end
end
def.method("=>", "boolean").IsActivityOpen = function(self)
  return _G.IsOverseasVersion()
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  local open = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_NEW_CLIENT)
  return open
end
def.method("=>", "boolean").IsActivityFinished = function(self)
  local cfg = ActivityInterface.GetActivityCfgById(constant.CThumbsupConsts.ACTIVITY_CFG_ID)
  local recommendCount = cfg and cfg.recommendCount or 0
  return recommendCount <= self._mThumbsupCount
end
return ThumbsupMgr.Commit()
