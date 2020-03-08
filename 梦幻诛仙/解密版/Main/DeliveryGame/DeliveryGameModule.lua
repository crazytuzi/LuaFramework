local Lplus = require("Lplus")
require("Main.module.ModuleId")
local ModuleBase = require("Main.module.ModuleBase")
local DeliveryGameModule = Lplus.Extend(ModuleBase, "DeliveryGameModule")
local DeliveryGameUtils = require("Main.DeliveryGame.DeliveryGameUtils")
local def = DeliveryGameModule.define
local instance
def.static("=>", DeliveryGameModule).Instance = function()
  if instance == nil then
    instance = DeliveryGameModule()
    instance.m_moduleId = ModuleId.DELIVERY
  end
  return instance
end
def.field("table").rewardsState = nil
def.field("table").myDelivery = nil
def.field("table").relatedSwitch = nil
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gratefuldelivery.SSyncFetchedRewards", DeliveryGameModule.OnSSyncFetchedRewards)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gratefuldelivery.SNotifyDistribution", DeliveryGameModule.OnSNotifyDistribution)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gratefuldelivery.SAvailableFriendRsp", DeliveryGameModule.OnSAvailableFriendRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gratefuldelivery.SDeliveryCountRsp", DeliveryGameModule.OnSDeliveryCountRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gratefuldelivery.SDeliverySuccess", DeliveryGameModule.OnSDeliverySuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gratefuldelivery.SDeliveryFail", DeliveryGameModule.OnSDeliveryFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gratefuldelivery.SNotifyAutoDelivery", DeliveryGameModule.OnSNotifyAutoDelivery)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gratefuldelivery.SNotifyReceiving", DeliveryGameModule.OnSNotifyReceiving)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gratefuldelivery.SNotifyReward", DeliveryGameModule.OnSNotifyReward)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gratefuldelivery.SFetchRewardSuccess", DeliveryGameModule.OnSFetchRewardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gratefuldelivery.SFetchRewardFail", DeliveryGameModule.OnSFetchRewardFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gratefuldelivery.SNotifySpecialEffect", DeliveryGameModule.OnSNotifySpecialEffect)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, DeliveryGameModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, DeliveryGameModule.OnActivityTodo)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, DeliveryGameModule.OnActivityReset)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, DeliveryGameModule.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, DeliveryGameModule.OnFeatureOpenInit)
  self.relatedSwitch = DeliveryGameUtils.GetRelatedSwitch()
  ModuleBase.Init(self)
end
def.static("table").OnSSyncFetchedRewards = function(p)
  local self = DeliveryGameModule.Instance()
  if self.rewardsState == nil then
    self.rewardsState = {}
  end
  local fetchedState = {}
  for k, v in pairs(p.fetched_rewards) do
    fetchedState[k] = true
  end
  self.rewardsState[p.activity_id] = fetchedState
end
def.static("table").OnSNotifyDistribution = function(p)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local actCfg = ActivityInterface.GetActivityCfgById(p.activity_id)
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if heroProp.level < actCfg.levelMin and heroProp.level < actCfg.levelMax then
    return
  end
  local self = DeliveryGameModule.Instance()
  local myRoleId = GetMyRoleID()
  local names = {}
  for k, v in pairs(p.roles) do
    if k == myRoleId then
      return
    else
      local name = GetStringFromOcts(v)
      table.insert(names, name)
    end
  end
  if self.myDelivery then
    self.myDelivery[p.activity_id] = nil
  end
  require("Main.DeliveryGame.ui.DeliveryTo").Close()
  Event.DispatchEvent(ModuleId.DELIVERY, gmodule.notifyId.Delivery.Delivery_Item_Change, {
    activityId = p.activity_id
  })
  self:ShowDeliveryStartPlayers(p.activity_id, names)
end
def.static("table").OnSAvailableFriendRsp = function(p)
  local roleList = {}
  local FriendData = require("Main.friend.FriendData")
  for k, v in ipairs(p.roles) do
    local friendInfo = FriendData.Instance():GetFriendInfo(v)
    if friendInfo then
      table.insert(roleList, {
        id = v,
        name = friendInfo.roleName,
        lv = friendInfo.roleLevel,
        occupation = friendInfo.occupationId,
        gender = friendInfo.sex,
        avatarId = friendInfo.avatarId
      })
    end
  end
  require("Main.DeliveryGame.ui.DeliveryTo").ShowDeliveryTo(p.activity_id, roleList)
end
def.static("table").OnSDeliveryCountRsp = function(p)
  require("Main.DeliveryGame.ui.DeliveryInfoPanel").ShowDeliveryInfoPanel(p.activity_id, p.delivery_count)
end
def.static("table").OnSDeliverySuccess = function(p)
  local self = DeliveryGameModule.Instance()
  local res = DeliveryGameUtils.GetActivityRes(p.activity_id)
  local sourceName = res.text[13]
  if self.myDelivery and self.myDelivery[p.activity_id] then
    sourceName = self.myDelivery[p.activity_id].sourceName
    self.myDelivery[p.activity_id] = nil
  end
  local targetName = res.text[14]
  if p.target_id > Int64.new(0) then
    targetName = string.format(res.text[15], GetStringFromOcts(p.target_name))
  end
  self:ShowReceiveResult(p.activity_id, sourceName, targetName)
  Event.DispatchEvent(ModuleId.DELIVERY, gmodule.notifyId.Delivery.Delivery_Item_Change, {
    activityId = p.activity_id
  })
end
def.static("table").OnSDeliveryFail = function(p)
  local res = DeliveryGameUtils.GetActivityRes(p.activity_id)
  local tip = res.text.DeliveryFail[p.retcode]
  if tip then
    Toast(tip)
  end
end
def.static("table").OnSNotifyAutoDelivery = function(p)
  local self = DeliveryGameModule.Instance()
  local res = DeliveryGameUtils.GetActivityRes(p.activity_id)
  local sourceName = res.text[13]
  if self.myDelivery and self.myDelivery[p.activity_id] then
    sourceName = self.myDelivery[p.activity_id].sourceName
    self.myDelivery[p.activity_id] = nil
  end
  local targetName = res.text[14]
  if p.target_id > Int64.new(0) then
    targetName = string.format(res.text[15], GetStringFromOcts(p.target_name))
  end
  self:ShowReceiveResult(p.activity_id, sourceName, targetName)
  Event.DispatchEvent(ModuleId.DELIVERY, gmodule.notifyId.Delivery.Delivery_Item_Change, {
    activityId = p.activity_id
  })
end
def.static("table").OnSNotifyReceiving = function(p)
  local self = DeliveryGameModule.Instance()
  if self.myDelivery == nil then
    self.myDelivery = {}
  end
  local delivery = {
    endTime = p.time,
    sourceId = p.source_id
  }
  if p.source_id > Int64.new(0) then
    delivery.sourceName = GetStringFromOcts(p.source_name)
  else
    local res = DeliveryGameUtils.GetActivityRes(p.activity_id)
    delivery.sourceName = res.text[13]
  end
  self.myDelivery[p.activity_id] = delivery
  self:ShowReceive(p.activity_id, delivery.sourceName, delivery.endTime)
  Event.DispatchEvent(ModuleId.DELIVERY, gmodule.notifyId.Delivery.Delivery_Item_Change, {
    activityId = p.activity_id
  })
end
def.static("table").OnSNotifyReward = function(p)
  local self = DeliveryGameModule.Instance()
  self:ShowReachTimes(p.activity_id, p.count)
  Event.DispatchEvent(ModuleId.DELIVERY, gmodule.notifyId.Delivery.Delivery_Count_Change, {
    activityId = p.activity_id,
    count = p.count
  })
end
def.static("table").OnSFetchRewardSuccess = function(p)
  local self = DeliveryGameModule.Instance()
  if self.rewardsState == nil then
    self.rewardsState = {}
  end
  if self.rewardsState[p.activity_id] == nil then
    self.rewardsState[p.activity_id] = {}
  end
  self.rewardsState[p.activity_id][p.stage] = true
  Event.DispatchEvent(ModuleId.DELIVERY, gmodule.notifyId.Delivery.Delivery_Rewards_Change, {
    activityId = p.activity_id
  })
end
def.static("table").OnSFetchRewardFail = function(p)
  local res = DeliveryGameUtils.GetActivityRes(p.activity_id)
  local tip = res.text.FetchRewardFail[p.retcode]
  if tip then
    Toast(tip)
  end
end
def.static("table").OnSNotifySpecialEffect = function(p)
  local deliveryCfg = DeliveryGameUtils.GetDeliveryCfg(p.activity_id)
  if deliveryCfg then
    local effectPath = GetEffectRes(deliveryCfg.sendCardSpecialEffectId)
    if effectPath then
      require("Fx.GUIFxMan").Instance():Play(effectPath.path, "watchmoon", 0, 0, -1, false)
    end
  end
  local res = DeliveryGameUtils.GetActivityRes(p.activity_id)
  require("GUI.InteractiveAnnouncementTip").InteractiveAnnounceWithPriority(res.text[17], 0)
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local self = DeliveryGameModule.Instance()
  for k, v in pairs(self.relatedSwitch) do
    local isOpen = _G.IsFeatureOpen(k)
    for k1, v1 in ipairs(v) do
      if isOpen then
        ActivityInterface.Instance():removeCustomCloseActivity(v1)
      else
        ActivityInterface.Instance():addCustomCloseActivity(v1)
      end
    end
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local self = DeliveryGameModule.Instance()
  if p1 and self.relatedSwitch[p1.feature] then
    local ActivityInterface = require("Main.activity.ActivityInterface")
    local acts = self.relatedSwitch[p1.feature]
    if p1.open then
      for k, v in pairs(acts) do
        ActivityInterface.Instance():removeCustomCloseActivity(v)
      end
    else
      for k, v in pairs(acts) do
        ActivityInterface.Instance():addCustomCloseActivity(v)
      end
    end
  end
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  local self = DeliveryGameModule.Instance()
  self.rewardsState = nil
  self.myDelivery = nil
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  local activityId = p1 and p1[1]
  if nil == activityId then
    return
  end
  local deliveryCfg = DeliveryGameUtils.GetDeliveryCfg(activityId)
  if deliveryCfg then
    local self = DeliveryGameModule.Instance()
    self:ShowDeliveryGamePanel(activityId)
  end
end
def.static("table", "table").OnActivityReset = function(p1, p2)
  local activityId = p1[1]
  local deliveryCfg = DeliveryGameUtils.GetDeliveryCfg(activityId)
  if deliveryCfg then
    local self = DeliveryGameModule.Instance()
    if self.rewardsState then
      self.rewardsState[activityId] = nil
    end
    Event.DispatchEvent(ModuleId.DELIVERY, gmodule.notifyId.Delivery.Delivery_Rewards_Change, {activityId = activityId})
    Event.DispatchEvent(ModuleId.DELIVERY, gmodule.notifyId.Delivery.Delivery_Count_Change, {activityId = activityId, count = 0})
  end
end
def.method("number", "=>", "boolean").IsClose = function(self, actId)
  local deliveryCfg = DeliveryGameUtils.GetDeliveryCfg(actId)
  if deliveryCfg then
    local isOpen = _G.IsFeatureOpen(deliveryCfg.switchId)
    if isOpen then
      return false
    else
      Toast(textRes.DeliveryGame[3])
      return true
    end
  else
    return false
  end
end
def.method("number", "table").ShowDeliveryStartPlayers = function(self, actId, players)
  local res = DeliveryGameUtils.GetActivityRes(actId)
  local count = #players
  local nameStr = table.concat(players, textRes.Common.Dunhao)
  local allStage = DeliveryGameUtils.GetDeliverStageCfg(actId)
  local content = string.format(res.text[1], count, nameStr, allStage.stages[#allStage.stages].count)
  require("Main.DeliveryGame.ui.DeliveryNotice").ShowDeliveryNoticeBig(actId, content, function()
    self:ShowDeliveryGamePanel(actId)
  end)
end
def.method("number", "string", "number").ShowReceive = function(self, actId, name, endTime)
  warn("ShowReceive", endTime, GetServerTime())
  local waitTime = endTime - GetServerTime()
  if waitTime > 1 then
    local res = DeliveryGameUtils.GetActivityRes(actId)
    require("GUI.CommonConfirmDlg").ShowConfirmCoundDown(res.text[3], string.format(res.text[2], name), res.text[4], "nil", 1, waitTime, function(sel)
      if sel == 1 and 1 < endTime - GetServerTime() then
        self:ShowRelatedPlayer(actId)
      end
    end, {m_level = 0})
  end
end
def.method("number").ShowDeliveryGamePanel = function(self, actId)
  if self:IsClose(actId) then
    return
  end
  self:RequestServerDeliveryCount(actId)
end
def.method("number").ShowRelatedPlayer = function(self, actId)
  if self:IsClose(actId) then
    return
  end
  local myDeliveryInfo = self:GetDeliveryState(actId)
  if myDeliveryInfo and myDeliveryInfo.endTime > GetServerTime() then
    require("Main.DeliveryGame.ui.DeliveryInfoPanel").Close()
    self:RequestRelatedPlayers(actId)
  else
    local res = DeliveryGameUtils.GetActivityRes(actId)
    Toast(res.text[16])
  end
end
def.method("number").RequestServerDeliveryCount = function(self, actId)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gratefuldelivery.CDeliveryCountReq").new(actId))
end
def.method("number").RequestRelatedPlayers = function(self, actId)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gratefuldelivery.CAvailableFriendReq").new(actId))
end
def.method("number", "userdata").Delivery = function(self, actId, roleId)
  local myDeliveryInfo = self:GetDeliveryState(actId)
  if myDeliveryInfo and myDeliveryInfo.endTime > GetServerTime() then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gratefuldelivery.CDeliveryReq").new(roleId, actId))
  else
    local res = DeliveryGameUtils.GetActivityRes(actId)
    Toast(res.text[16])
  end
end
def.method("number", "string", "string").ShowReceiveResult = function(self, actId, sourceName, targetName)
  local res = DeliveryGameUtils.GetActivityRes(actId)
  local content = string.format(res.text[5], sourceName, targetName)
  require("Main.DeliveryGame.ui.DeliveryNotice").ShowDeliveryNoticeSmall(actId, content, function()
    self:ShowDeliveryGamePanel(actId)
  end)
  require("Main.DeliveryGame.ui.DeliveryTo").Close()
end
def.method("number", "number").ShowReachTimes = function(self, actId, num)
  local res = DeliveryGameUtils.GetActivityRes(actId)
  require("GUI.CommonConfirmDlg").ShowConfirmCoundDown(res.text[3], string.format(res.text[6], num), "", "", 0, 30, function(sel)
    if sel == 1 then
      self:ShowDeliveryGamePanel(actId)
    end
  end, {m_level = 0})
end
def.method("number", "number").FetchTimesReward = function(self, actId, stage)
  if self:IsClose(actId) then
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gratefuldelivery.CFetchRewardReq").new(stage, actId))
end
def.method("number", "=>", "table").GetRewardState = function(self, actId)
  if self.rewardsState then
    return self.rewardsState[actId]
  else
    return nil
  end
end
def.method("number", "=>", "table").GetDeliveryState = function(self, actId)
  if self.myDelivery then
    return self.myDelivery[actId]
  else
    return nil
  end
end
DeliveryGameModule.Commit()
return DeliveryGameModule
