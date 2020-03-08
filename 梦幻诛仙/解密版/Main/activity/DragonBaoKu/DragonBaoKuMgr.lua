local Lplus = require("Lplus")
local DragonBaoKuMgr = Lplus.Class("DragonBaoKuMgr")
local NPCInterface = require("Main.npc.NPCInterface")
local ActivityInterface = require("Main.activity.ActivityInterface")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local def = DragonBaoKuMgr.define
local instance
def.field("userdata").poolYuanbaoNum = nil
def.field("table").freePassInfos = nil
def.field("table").lastWinnerInfo = nil
def.field("table").resetTimerIds = nil
def.field("userdata").lastPoolYuanbaoNum = nil
def.static("=>", DragonBaoKuMgr).Instance = function()
  if instance == nil then
    instance = DragonBaoKuMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawcarnival.SGetDrawInfoRsp", DragonBaoKuMgr.OnSGetDrawInfoRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawcarnival.SDrawRsp", DragonBaoKuMgr.OnSDrawRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawcarnival.SDrawError", DragonBaoKuMgr.OnSDrawError)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawcarnival.SBroadcastYuanBaoChangeInfo", DragonBaoKuMgr.OnSBroadcastYuanBaoChangeInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawcarnival.SBroadcastBigAwardInfo", DragonBaoKuMgr.OnSBroadcastBigAwardInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.drawcarnival.SBroadcastChestAwardInfo", DragonBaoKuMgr.OnSBroadcastChestAwardInfo)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, DragonBaoKuMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, DragonBaoKuMgr.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, DragonBaoKuMgr.OnActivityEnd)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, DragonBaoKuMgr.OnFunctionOpenChange)
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  instance.poolYuanbaoNum = nil
  instance.freePassInfos = nil
  instance.lastWinnerInfo = nil
  instance.lastPoolYuanbaoNum = nil
  if instance.resetTimerIds then
    for i, v in pairs(instance.resetTimerIds) do
      AbsoluteTimer.RemoveListener(v)
    end
    instance.resetTimerIds = {}
  end
end
def.static("table", "table").OnActivityStart = function(p1, p2)
  local activityId = p1[1]
  if activityId == constant.CDrawCarnivalConsts.ACTIVITY_ID then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.ACTIVITY_DRAGON_BAOKU_NOTIFY_CHANGE, nil)
  end
end
def.static("table", "table").OnActivityEnd = function(p1, p2)
  local activityId = p1[1]
  if activityId == constant.CDrawCarnivalConsts.ACTIVITY_ID then
    instance.poolYuanbaoNum = nil
    instance.lastPoolYuanbaoNum = nil
    instance.freePassInfos = nil
    instance.lastWinnerInfo = nil
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if p1.feature == ModuleFunSwitchInfo.TYPE_DRAW_CARNIVAL then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
  end
end
def.static("number", "=>", "table").GetOrigDrawCarnivalPassItemCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ORIG_DRAW_CARNIVAL_PASS_ITEM_CFG, id)
  if record == nil then
    warn("!!!!!!!GetOrigDrawCarnivalPassItemCfg got nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.passTypeId = record:GetIntValue("passTypeId")
  return cfg
end
def.static("number", "=>", "table").GetDrawCarnivalPassItemCfg = function(passTypeId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DRAW_CARNIVAL_PASS_ITEM_CFG, passTypeId)
  if record == nil then
    warn("!!!!!!!GetDrawCarnivalPassItemCfg got nil record for id: ", passTypeId)
    return nil
  end
  local cfg = {}
  cfg.passTypeId = passTypeId
  cfg.itemCfgIdList = {}
  local rec2 = record:GetStructValue("itemCfgIdListStruct")
  local count = rec2:GetVectorSize("itemCfgIdList")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("itemCfgIdList", i - 1)
    local id = rec3:GetIntValue("id")
    table.insert(cfg.itemCfgIdList, id)
  end
  return cfg
end
def.static("number", "=>", "table").GetDrawCarnivalPassTypeCfg = function(passTypeId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DEAW_CARNIVAL_PASS_TYPE_CFG, passTypeId)
  if record == nil then
    warn("!!!!!!!GetDrawCarnivalPassTypeCfg got nil record for id: ", passTypeId)
    return nil
  end
  local cfg = {}
  cfg.passTypeId = passTypeId
  cfg.name = record:GetStringValue("name")
  cfg.icon = record:GetIntValue("icon")
  cfg.desc = record:GetStringValue("desc")
  cfg.type = record:GetIntValue("type")
  cfg.effect = record:GetStringValue("effect")
  cfg.level = record:GetIntValue("level")
  cfg.yuanBaoPrice = record:GetIntValue("yuanBaoPrice")
  cfg.drawCountPerPass = record:GetIntValue("drawCountPerPass")
  cfg.freePassCountPerDay = record:GetIntValue("freePassCountPerDay")
  cfg.freePassResetTime = record:GetIntValue("freePassResetTime")
  cfg.freePassLotteryViewCfgId = record:GetIntValue("freePassLotteryViewCfgId")
  cfg.passLotteryViewCfgId = record:GetIntValue("passLotteryViewCfgId")
  return cfg
end
def.static("number", "=>", "table").GetOrigDrawCarnivalBigAwardCfg = function(randomTypeCfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ORIG_DRAW_CARNIVAL_BIG_AWARD_CFG, randomTypeCfgId)
  if record == nil then
    warn("!!!!!!!GetOrigDrawCarnivalBigAwardCfg got nil record for id: ", randomTypeCfgId)
    return nil
  end
  local cfg = {}
  cfg.randomTypeCfgId = randomTypeCfgId
  cfg.awardName = record:GetStringValue("awardName")
  return cfg
end
def.static("table").OnSGetDrawInfoRsp = function(p)
  warn("---->>>>OnSGetDrawInfoRsp:", p.award_pool_yuan_bao_count)
  instance:setPoolYuanbaoNum(p.award_pool_yuan_bao_count)
  instance.freePassInfos = p.pass_type_id2info
  instance.lastWinnerInfo = p.last_winner_info
  instance:registerResetTimer()
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.ACTIVITY_DRAGON_BAOKU_NOTIFY_CHANGE, nil)
end
def.static("table").OnSDrawRsp = function(p)
  warn("-----------OnSDrawRsp:", p.pass_type_id, p.pass_count)
  instance.freePassInfos = instance.freePassInfos or {}
  local freeNum = instance:getFreeNumByPassType(p.pass_type_id)
  instance.freePassInfos[p.pass_type_id] = p.free_pass_info
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.ACTIVITY_DRAGON_BAOKU_NOTIFY_CHANGE, nil)
  if p.pass_count > 1 or freeNum <= 0 then
    local yuanbaoStr = ""
    local passTypeCfg = DragonBaoKuMgr.GetDrawCarnivalPassTypeCfg(p.pass_type_id)
    local yuanbaoBuyPassNum = 0
    if 0 < p.is_use_yuan_bao then
      yuanbaoBuyPassNum = p.cost_yuan_bao_count / passTypeCfg.yuanBaoPrice
      yuanbaoStr = string.format(textRes.activity.DragonBaoKu[6], p.cost_yuan_bao_count, yuanbaoBuyPassNum)
    end
    local str = string.format(textRes.activity.DragonBaoKu[5], p.pass_count, passTypeCfg.name, yuanbaoStr, p.add_point_count)
    Toast(str)
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.ACTIVITY_DRAGON_BAOKU_LOTTERY_INFO, {
    passCount = p.pass_count,
    awardInfo = p.pass_award_info_list
  })
end
def.static("table").OnSDrawError = function(p)
  warn("!!!!!!!!!!OnSDrawError:", p.code, p.pass_type_id, p.pass_count, is_use_yuan_bao)
  local str = textRes.activity.DragonBaoKu.DrawError[p.code]
  if str then
    Toast(str)
  end
end
def.static("table").OnSBroadcastYuanBaoChangeInfo = function(p)
  warn("-------OnSBroadcastYuanBaoChangeInfo:", p.award_pool_yuan_bao_count)
  instance:setPoolYuanbaoNum(p.award_pool_yuan_bao_count)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.ACTIVITY_DRAGON_BAOKU_POOL_YUANBAO_CHANGE, nil)
end
def.static("table").OnSBroadcastBigAwardInfo = function(p)
  warn("------OnSBroadcastBigAwardInfo")
  instance.lastWinnerInfo = p.winner_info
  local effectId = constant.CDrawCarnivalConsts.BIG_AWARD_EFFECT_ID
  local effectCfg = GetEffectRes(effectId)
  if effectCfg then
    require("Fx.GUIFxMan").Instance():Play(effectCfg.path, "BigAward", 0, 0, -1, false)
  end
  local bigAwardCfg = DragonBaoKuMgr.GetOrigDrawCarnivalBigAwardCfg(p.winner_info.random_type_id)
  local typeStr = ""
  if bigAwardCfg then
    typeStr = bigAwardCfg.awardName
  end
  local str = string.format(textRes.activity.DragonBaoKu[13], _G.GetStringFromOcts(p.winner_info.role_name), typeStr, tostring(p.winner_info.award_count), tostring(p.orig_yuan_bao_count), tostring(p.yuan_bao_count))
  instance:announcementTip(str)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.ACTIVITY_DRAGON_BAOKU_BIG_AWARD, nil)
end
def.static("table").OnSBroadcastChestAwardInfo = function(p)
  warn("-----OnSBroadcastChestAwardInfo")
  local effectId = constant.CDrawCarnivalConsts.CHEST_AWARD_EFFECT_ID
  local effectCfg = GetEffectRes(effectId)
  if effectCfg then
    require("Fx.GUIFxMan").Instance():Play(effectCfg.path, "BoxAward", 0, 0, -1, false)
  end
  local str = string.format(textRes.activity.DragonBaoKu[12], _G.GetStringFromOcts(p.winner_info.role_name), tostring(p.orig_yuan_bao_count), tostring(p.yuan_bao_count))
  instance:announcementTip(str)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.ACTIVITY_DRAGON_BAOKU_BOX_AWARD, nil)
end
def.method("string").announcementTip = function(self, str)
  local RareItemAnnouncementTip = require("GUI.RareItemAnnouncementTip")
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  RareItemAnnouncementTip.AnnounceRareItem(str)
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.method().registerResetTimer = function(self)
  if self.freePassInfos then
    local curTime = _G.GetServerTime()
    for i, v in pairs(self.freePassInfos) do
      local delayTime = v.reset_time_stamp:ToNumber() - curTime
      local timerId
      if self.resetTimerIds and self.resetTimerIds[i] then
        timerId = self.resetTimerIds[i]
      end
      if timerId == nil and delayTime > 0 then
        timerId = AbsoluteTimer.AddListener(1, 0, DragonBaoKuMgr.OnResetFreeInfo, {passType = i}, delayTime)
        self.resetTimerIds = self.resetTimerIds or {}
        self.resetTimerIds[i] = timerId
        warn("---->>>>>>>>registerDragonTimer:", i, timerId, delayTime)
      else
      end
    end
  end
end
def.static("table").OnResetFreeInfo = function(param)
  local self = instance
  local passType = param.passType
  if passType and self.freePassInfos and self.freePassInfos[passType] then
    local passTypeCfg = DragonBaoKuMgr.GetDrawCarnivalPassTypeCfg(passType)
    if passTypeCfg then
      self.freePassInfos[passType].count = passTypeCfg.freePassCountPerDay
      local resetTime = self.freePassInfos[passType].reset_time_stamp:ToNumber()
      self.freePassInfos[passType].reset_time_stamp = Int64.new(resetTime + 86400)
      self.resetTimerIds[passType] = nil
      self:registerResetTimer()
      Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.ACTIVITY_DRAGON_BAOKU_NOTIFY_CHANGE, nil)
    else
      warn("!!!!!!!OnResetFreeInfo passTypeCfg is nil:", passType)
    end
  end
end
def.method("number", "=>", "number").getFreeNumByPassType = function(self, passType)
  if self.freePassInfos and self.freePassInfos[passType] then
    return self.freePassInfos[passType].count
  end
  local passTypeCfg = DragonBaoKuMgr.GetDrawCarnivalPassTypeCfg(passType)
  return passTypeCfg.freePassCountPerDay
end
def.method("number", "=>", "number").getResetTimeStamp = function(self, passType)
  if self.freePassInfos and self.freePassInfos[passType] then
    return self.freePassInfos[passType].reset_time_stamp:ToNumber()
  end
  return 0
end
def.method("userdata").setPoolYuanbaoNum = function(self, yuanbao)
  self.lastPoolYuanbaoNum = self.poolYuanbaoNum
  self.poolYuanbaoNum = yuanbao
end
def.method("=>", "userdata").getPoolYuanbaoNum = function(self)
  return self.poolYuanbaoNum
end
def.method("=>", "userdata").getLastPoolYuanbaoNum = function(self)
  return self.lastPoolYuanbaoNum
end
def.method("=>", "string").getLastWinnerInfoStr = function(self)
  if self.lastWinnerInfo then
    local bigAwardCfg = DragonBaoKuMgr.GetOrigDrawCarnivalBigAwardCfg(self.lastWinnerInfo.random_type_id)
    if bigAwardCfg then
      return string.format(textRes.activity.DragonBaoKu[8], bigAwardCfg.awardName, _G.GetStringFromOcts(self.lastWinnerInfo.role_name), tostring(self.lastWinnerInfo.award_count))
    end
  end
  return textRes.activity.DragonBaoKu[2]
end
def.method("=>", "boolean").isOpen = function(self)
  if _G.IsCrossingServer() then
    return false
  end
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_DRAW_CARNIVAL) then
    return false
  end
  local activityId = constant.CDrawCarnivalConsts.ACTIVITY_ID
  local activityInterface = ActivityInterface.Instance()
  if activityInterface:isAchieveActivityLevel(activityId) and activityInterface:isActivityOpend2(activityId) then
    return true
  end
  return false
end
def.method("=>", "boolean").isNotify = function(self)
  if self:isOpen() then
    if self.freePassInfos then
      for i, v in pairs(self.freePassInfos) do
        if v.count > 0 then
          return true
        end
      end
    else
      return true
    end
  end
  return false
end
return DragonBaoKuMgr.Commit()
