local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local GiftActivityMgr = Lplus.Class(CUR_CLASS_NAME)
local ItemUtils = require("Main.Item.ItemUtils")
local CustomActivityInterface = require("Main.CustomActivity.CustomActivityInterface")
local def = GiftActivityMgr.define
def.field("table").m_activityGiftInfos = nil
def.field("table").m_allActivityIds = nil
local instance
def.static("=>", GiftActivityMgr).Instance = function()
  if instance == nil then
    instance = GiftActivityMgr()
  end
  return instance
end
def.method().Init = function(self)
  self.m_allActivityIds = CustomActivityInterface.GetAllTimeLimitedActivityIds()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, GiftActivityMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, GiftActivityMgr.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, GiftActivityMgr.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, GiftActivityMgr.OnActivityEnd)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, GiftActivityMgr.OnActivityTodo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SSyncTimeLimitGiftActivityInfo", GiftActivityMgr.OnSSyncTimeLimitGiftActivityInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SSynGiftActivityAwardRes", GiftActivityMgr.OnSSynGiftActivityAwardRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGetGiftActivityAwardRes", GiftActivityMgr.OnSGetGiftActivityAwardRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGetTimeLimitGiftFailedRes", GiftActivityMgr.OnSGetTimeLimitGiftFailedRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGetGiftInfoRsp", GiftActivityMgr.OnSGetGiftInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGetGiftInfoError", GiftActivityMgr.OnSGetGiftInfoError)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGiftRsp", GiftActivityMgr.OnSGiftRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGiftError", GiftActivityMgr.OnSGiftError)
end
def.method("number", "number", "number", "=>", "boolean").GetGiftAwardReq = function(self, activity_id, gift_bag_id, num)
  print("CGetGiftActivityAwardReq", activity_id, ",", gift_bag_id)
  local activityGiftInfo = self:GetActivityGiftInfo(activity_id)
  if activityGiftInfo == nil then
    warn(string.format("activity_id=%d not exist in m_activityGiftInfos!", activity_id))
    return false
  end
  local remain_count = activityGiftInfo.gift_bag_id_2_remain_count[gift_bag_id]
  if remain_count == nil then
    warn(string.format("activity_id=%d, gift_bag_id=%d not exist in m_activityGiftInfos!", activity_id, gift_bag_id))
    return false
  end
  local p = require("netio.protocol.mzm.gsp.qingfu.CGetGiftActivityAwardReq").new(activity_id, gift_bag_id, remain_count, num)
  gmodule.network.sendProtocol(p)
  return true
end
def.method("=>", "table").GetAllActivityGiftInfos = function(self)
  return self.m_activityGiftInfos
end
def.method("number", "=>", "table").GetActivityGiftInfo = function(self, activity_id)
  if self.m_activityGiftInfos == nil then
    return nil
  end
  return self.m_activityGiftInfos[activity_id]
end
def.method("number", "=>", "table").GetActivityGiftInfosByGiftBagType = function(self, giftBagType)
  if self.m_activityGiftInfos == nil then
    return {}
  end
  local infos = {}
  for k, v in pairs(self.m_activityGiftInfos) do
    local activityId = k
    local cfg = CustomActivityInterface.GetGiftBagTypeCfgByActivityId(activityId)
    if cfg.giftBagType == giftBagType then
      table.insert(infos, {
        activityId = activityId,
        giftBags = v.gift_bag_id_2_remain_count
      })
    end
  end
  return infos
end
def.static("table", "table").OnLeaveWorld = function(...)
  instance.m_activityGiftInfos = nil
end
def.static("table", "table").OnActivityStart = function(params)
  local activityId = params and params[1] or 0
  if instance.m_allActivityIds[activityId] == nil then
    return
  end
  local cfgs = CustomActivityInterface.GetTimeLimitedGiftBagCfgsByActivityId(activityId)
  instance.m_activityGiftInfos = instance.m_activityGiftInfos or {}
  instance.m_activityGiftInfos[activityId] = {}
  local activityInfo = instance.m_activityGiftInfos[activityId]
  activityInfo.gift_bag_id_2_remain_count = {}
  for i, v in ipairs(cfgs) do
    activityInfo.gift_bag_id_2_remain_count[v.id] = v.maxCount
  end
  CustomActivityInterface.Instance():calcTimeLimitedGiftRedPoint()
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, {activityId = activityId})
end
def.static("table", "table").OnActivityEnd = function(params)
  local activityId = params and params[1] or 0
  warn("activityClose", activityId)
  if instance.m_allActivityIds[activityId] == nil then
    return
  end
  if instance.m_activityGiftInfos ~= nil then
    instance.m_activityGiftInfos[activityId] = nil
    CustomActivityInterface.Instance():calcTimeLimitedGiftRedPoint()
    Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, {activityId = activityId})
  end
  warn("instance.m_activityGiftInfos[activityId]", activityId, instance.m_activityGiftInfos[activityId])
end
def.static("table", "table").OnActivityTodo = function(params)
  local activityId = params and params[1] or 0
  if instance.m_allActivityIds[activityId] == nil then
    return
  end
  local myActivityId = CustomActivityInterface.Instance():GetTimeLimitedGiftActivityId()
  if activityId ~= myActivityId then
    return
  end
  require("Main.CustomActivity.ui.CustomActivityPanel").Instance():ShowPanelWithTabName("Tab_LimitGiftBa")
end
def.static("table").OnSSyncTimeLimitGiftActivityInfo = function(p)
  instance.m_activityGiftInfos = p.activity_id_2_gift_info
  CustomActivityInterface.Instance():calcTimeLimitedGiftRedPoint()
end
def.static("table").OnSSynGiftActivityAwardRes = function(p)
  print("OnSSynGiftActivityAwardRes p.activity_id", p.activity_id)
  instance.m_activityGiftInfos = instance.m_activityGiftInfos or {}
  instance.m_activityGiftInfos[p.activity_id] = p.gift_bag_id_2_remain_count
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GIFT_ACTIVITY_INFO_CHANGE, {
    activityId = p.activity_id
  })
  CustomActivityInterface.Instance():calcTimeLimitedGiftRedPoint()
end
def.static("table").OnSGetGiftActivityAwardRes = function(p)
  print("OnSGetGiftActivityAwardRes p.activity_id, p.gift_bag_id, p.remain_count", p.activity_id, p.gift_bag_id, p.remain_count)
  local giftInfos = instance.m_activityGiftInfos[p.activity_id]
  giftInfos.gift_bag_id_2_remain_count[p.gift_bag_id] = p.remain_count
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GET_GIFT_ACTIVITY_AWARD_SUCCESS, {
    activityId = p.activity_id,
    giftBagId = p.gift_bag_id,
    remainTimes = p.remain_count
  })
  local activityId = CustomActivityInterface.Instance():GetTimeLimitedGiftActivityId()
  if activityId == p.activity_id then
    CustomActivityInterface.Instance():calcTimeLimitedGiftRedPoint()
  end
end
def.static("table").OnSGetTimeLimitGiftFailedRes = function(p)
  local retcode = p.retcode
  local text = textRes.customActivity.SGetTimeLimitGiftFailedRes[retcode]
  if text then
    Toast(text)
  else
    warn(string.format("OnSGetTimeLimitGiftFailedRes not handle retcode=%d", retcode))
  end
end
def.static("=>", "boolean").IsGiftGivingFeatureOpen = function(self)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
  local bOpen = FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_TIME_LIMIT_GIFT_BAG_ACTIVITY_GIFT_TO_FRIENDS)
  return bOpen
end
def.static("number", "number").SendGetGiftInfoReq = function(actId, giftBagId)
  local p = require("netio.protocol.mzm.gsp.qingfu.CGetGiftInfoReq").new(actId, giftBagId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetGiftInfoRes = function(p)
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GET_GIVING_INFO_OK, p)
end
def.static("table").OnSGetGiftInfoError = function(p)
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GET_GIVING_INFO_FAILED, p)
end
def.static("number", "number", "userdata").CGiveGiftReq = function(activityId, giftBagId, roleId)
  local p = require("netio.protocol.mzm.gsp.qingfu.CGiftReq").new(activityId, giftBagId, roleId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGiftRsp = function(p)
  Toast(textRes.customActivity[322])
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GIVING_OK, p)
end
def.static("table").OnSGiftError = function(p)
  local ERROR_CODE = require("netio.protocol.mzm.gsp.qingfu.SGiftError")
  local giftBagCfg = require("Main.CustomActivity.CustomActivityInterface").GetTimeLimitedGiftBagCfg(p.gift_bag_cfg_id)
  local txtConst = textRes.customActivity
  if p.code == ERROR_CODE.RECEIVER_REACH_MAX then
    Toast(txtConst[306]:format(giftBagCfg.desc))
  elseif p.code == ERROR_CODE.SENDER_REACH_MAX then
    Toast(txtConst[305])
  elseif p.code == ERROR_CODE.P2P_REACH_MAX then
    Toast(txtConst[307]:format(giftBagCfg.desc))
  elseif p.code == ERROR_CODE.INTIMACY_LOW then
    Toast(txtConst[310])
  elseif p.code == ERROR_CODE.SEND_MAIL_FAIL then
    Toast(txtConst[311])
  elseif p.code == ERROR_CODE.MONEY_NOT_ENOUGH then
    Toast(txtConst[312])
  end
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GIVING_FAILED, p)
end
return GiftActivityMgr.Commit()
