local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local ConstellationModule = Lplus.Extend(ModuleBase, "ConstellationModule")
local ConstellationUtils = import(".ConstellationUtils")
local SStageBrd = require("netio.protocol.mzm.gsp.constellation.SStageBrd")
local ActivityInterface = require("Main.activity.ActivityInterface")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local def = ConstellationModule.define
local CONSTELLATION_UNKONW = -2
local CONSTELLATION_NONE = -1
local Stage = {
  STG_NONE = -1,
  STG_START_COUNTDOWN = SStageBrd.STG_START_COUNTDOWN,
  STG_CARD = SStageBrd.STG_CARD,
  STG_FINISHED = SStageBrd.STG_FINISHED
}
def.const("number").CONSTELLATION_UNKONW = CONSTELLATION_UNKONW
def.const("number").CONSTELLATION_NONE = CONSTELLATION_NONE
def.const("number").CONSTELLATION_QUERY_INTERVAL = 2
def.const("table").Stage = Stage
def.field("number").m_stage = Stage.STG_NONE
def.field("userdata").m_stageEndTime = nil
def.field("table").m_roundInfo = nil
def.field("table").m_stageInfo = nil
def.field("number").m_nlConstellationCT = 0
def.field("number").m_natalConstellation = CONSTELLATION_UNKONW
def.field("number").m_accumulatedExp = 0
def.field("number").m_preNotifyTimeId = -1
def.field("number").m_lastQueryTime = 0
local instance
def.static("=>", ConstellationModule).Instance = function()
  if instance == nil then
    instance = ConstellationModule()
    instance.m_moduleId = ModuleId.CONSTELLATION
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.constellation.SConstellationNormalResult", ConstellationModule.OnSConstellationNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.constellation.SStageBrd", ConstellationModule.OnSStageBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.constellation.SSyncConstellationCards", ConstellationModule.OnSSyncConstellationCards)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.constellation.SConstellationCardsBrd", ConstellationModule.OnSConstellationCardsBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.constellation.SChooseCardNormalRes", ConstellationModule.OnSChooseCardNormalRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.constellation.SChooseCardExtraRes", ConstellationModule.OnSChooseCardExtraRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.constellation.SConstellationRes", ConstellationModule.OnSConstellationRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.constellation.SSetSelfConstellationRes", ConstellationModule.OnSSetSelfConstellationRes)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, ConstellationModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, ConstellationModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, ConstellationModule.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, ConstellationModule.OnActivityEnd)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, ConstellationModule.OnActivityTodo)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, ConstellationModule.OnFunctionOpenInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, ConstellationModule.OnFunctionOpenChange)
end
def.method("=>", "boolean").IsOpen = function(self)
  if not self:IsFeatureOpen() then
    return false
  end
  return true
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  local isOpen = feature:CheckFeatureOpen(Feature.TYPE_CONSTELLATION)
  return isOpen
end
def.method("=>", "boolean").ShowLuck12ConstellationPanel = function(self)
  local stageInfo = self:GetStageInfo()
  if stageInfo.stage == Stage.STG_NONE then
    Toast(textRes.activity[51])
    return false
  end
  if stageInfo.stage == Stage.STG_FINISHED then
    Toast(textRes.activity[66])
    return false
  end
  require("Main.Constellation.ui.Lucky12ConstellationsPanel").Instance():ShowPanel()
  if self.m_natalConstellation == CONSTELLATION_UNKONW then
    self:QueryConstellationInfoReq()
  end
  return true
end
def.method("=>", "number").GetNatalConstellation = function(self)
  return self.m_natalConstellation
end
def.method("=>", "number").GetNatalConstellationLCT = function(self)
  local leftTimes = ConstellationUtils.GetConstant("ChangeTimes") - self.m_nlConstellationCT
  return math.max(leftTimes, 0)
end
def.method("=>", "table").GetStageInfo = function(self)
  if self.m_stageInfo == nil then
    self.m_stageInfo = {}
  end
  self.m_stageInfo.stage = self.m_stage
  self.m_stageInfo.stageEndTime = self.m_stageEndTime
  return self.m_stageInfo
end
def.method("=>", "table").GetRoundInfo = function(self)
  return self.m_roundInfo
end
def.method("=>", "number").GetCurRoundConstellation = function(self)
  if self.m_roundInfo == nil then
    return CONSTELLATION_NONE
  end
  return self.m_roundInfo.constellation
end
def.method("=>", "number").GetAccumulatedExp = function(self)
  return self.m_accumulatedExp
end
def.method().StageFinish = function(self)
  local curTime = _G.GetServerTime()
  local delaySeconds = ConstellationUtils.GetConstant("CloseSeconds")
  local endTime = Int64.new(curTime + delaySeconds)
  self:SetStage(Stage.STG_FINISHED, endTime)
end
def.method("number").SetNatalConstellationReq = function(self, constellation)
  local set_times = self.m_nlConstellationCT
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.constellation.CSetSelfConstellationReq").new(constellation, set_times))
end
def.method().AttemptQueryConstellationInfo = function(self)
  local curTime = os.time()
  local lastTime = self.m_lastQueryTime
  if math.abs(curTime - lastTime) < ConstellationModule.CONSTELLATION_QUERY_INTERVAL then
    return
  end
  self:QueryConstellationInfoReq()
end
def.method().QueryConstellationInfoReq = function(self)
  self.m_lastQueryTime = os.time()
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.constellation.CConstellationReq").new())
end
def.method("number", "number").ChooseCardReq = function(self, constellation, index)
  index = index - 1
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.constellation.CChooseCardReq").new(constellation, index))
end
def.method().InitActivity = function(self)
  self.m_nlConstellationCT = 0
  self.m_accumulatedExp = 0
  local curTime = _G.GetServerTime()
  local endTime = curTime + constant.CConstellationConsts.StartCountDown
  self:SetStage(Stage.STG_START_COUNTDOWN, Int64.new(endTime))
end
def.method().Clear = function(self)
  self.m_natalConstellation = CONSTELLATION_UNKONW
  self.m_nlConstellationCT = 0
  self.m_lastQueryTime = 0
  self.m_roundInfo = nil
  self.m_stageInfo = nil
  self.m_stage = Stage.STG_NONE
  self.m_stageEndTime = nil
  self.m_accumulatedExp = 0
  self:RemovePreNotifyTimer()
end
def.method("table").SetFlipCardAward = function(self, p)
  if self.m_roundInfo == nil then
    warn("roundInfo is nil! when SetFlipCardAward({constellation=%d, index=%d}) ", p.constellation, p.index)
    return
  end
  if self.m_roundInfo.constellation ~= p.constellation then
    warn("roundInfo.constellation is %d! when SetFlipCardAward({constellation=%d, index=%d}) ", self.m_roundInfo.constellation, p.constellation, p.index)
    return
  end
  local index = p.index + 1
  self.m_roundInfo.choose_index = index
  local cardInfo = self.m_roundInfo.cards[index]
  cardInfo.award = p.award
  cardInfo.extra_award = p.extra_award
  Event.DispatchEvent(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.FLIP_CARD_SUCCESS, {cardInfo})
end
def.method("table").SetRoundInfoFromProtocol = function(self, p)
  self.m_roundInfo = {}
  self.m_roundInfo.constellation = p.constellation
  self.m_roundInfo.stars = p.stars
  self.m_roundInfo.fortune = p.fortune + 1
  local cards = {}
  for i, v in ipairs(p.stars) do
    local cardInfo = {}
    cardInfo.index = i
    cardInfo.star = v
    cards[#cards + 1] = cardInfo
  end
  self.m_roundInfo.cards = cards
end
def.method("number", "userdata").SetStage = function(self, stage, stageEndTime)
  local lastStage = self.m_stage
  self.m_stage = stage
  self.m_stageEndTime = stageEndTime or self.m_stageEndTime
  if lastStage ~= stage then
    Event.DispatchEvent(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.STAGE_UPDATE, {
      self.m_stage,
      self.m_stageEndTime
    })
  end
end
def.method("number").SetRoundEndTimeByStartTime = function(self, startTime)
  self.m_stageEndTime = Int64.new(startTime + ConstellationUtils.GetConstant("PerTurnLastSeconds") + ConstellationUtils.GetConstant("PauseSeconds"))
end
def.method().OnPreNotifyTime = function(self)
  if not self:IsOpen() then
    print("OnPreNotifyTimeFailed: ConstellationModule is not open")
    return
  end
  if _G.IsCrossingServer() then
    print("OnPreNotifyTimeFailed: IsCrossingServer")
    return
  end
  local AnnouncementTip = require("GUI.AnnouncementTip")
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local preNotifyMinutes = constant.CConstellationConsts.BeforeNotifyMinutes or 5
  local activityId = constant.CConstellationConsts.Activityid
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  local activityName = activityCfg and activityCfg.activityName or "nil"
  local str = string.format(textRes.Constellation[15], activityName, preNotifyMinutes)
  AnnouncementTip.Announce(str)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
end
def.method().RemovePreNotifyTimer = function(self)
  if self.m_preNotifyTimeId ~= -1 then
    AbsoluteTimer.RemoveListener(self.m_preNotifyTimeId)
    self.m_preNotifyTimeId = -1
  end
end
def.method().OnFeatureStatusChange = function(self)
  local isOpen = self:IsFeatureOpen()
  local activityId = constant.CConstellationConsts.Activityid
  if isOpen then
    ActivityInterface.Instance():removeCustomCloseActivity(activityId)
  else
    ActivityInterface.Instance():addCustomCloseActivity(activityId)
    Event.DispatchEvent(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.FEATURE_CLOSE, nil)
  end
end
def.method().OnConstellationNotOpen = function(self)
end
def.static("table").OnSConstellationNormalResult = function(p)
  print("OnSConstellationNormalResult ", p.result)
  if p.result == p.class.CONSTELLATION__NOT_OPEN then
    instance:OnConstellationNotOpen()
    return
  end
  local text = textRes.Constellation.SConstellationNormalResult[p.result]
  if text then
    Toast(text)
  end
end
def.static("table").OnSStageBrd = function(p)
  print("OnSStageBrd ", p.stage, tostring(p.end_millis))
  local self = instance
  local endTime = p.end_millis / 1000
  self:SetStage(p.stage, endTime)
end
def.static("table").OnSSyncConstellationCards = function(p)
  local self = instance
  self:SetRoundInfoFromProtocol(p.cards)
  self.m_roundInfo.choose_index = p.choose_index + 1
  self:SetStage(Stage.STG_CARD, nil)
  Event.DispatchEvent(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.CONSTELLATION_ROUND_UPDATE, {
    p.cards.constellation
  })
end
def.static("table").OnSConstellationCardsBrd = function(p)
  local self = instance
  self:SetRoundInfoFromProtocol(p.cards)
  local curTime = _G.GetServerTime()
  self:SetRoundEndTimeByStartTime(curTime)
  self:SetStage(Stage.STG_CARD, nil)
  Event.DispatchEvent(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.CONSTELLATION_ROUND_UPDATE, {
    p.cards.constellation
  })
end
def.static("table").OnSChooseCardNormalRes = function(p)
  local self = instance
  self:SetFlipCardAward(p)
  self.m_accumulatedExp = self.m_accumulatedExp + p.award.roleExp
  Event.DispatchEvent(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.ACCUMULATED_EXP_UPDATE, {
    self.m_accumulatedExp
  })
end
def.static("table").OnSChooseCardExtraRes = function(p)
  local self = instance
  self:SetFlipCardAward(p)
  self.m_accumulatedExp = self.m_accumulatedExp + p.award.roleExp + p.extra_award.roleExp
  Event.DispatchEvent(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.ACCUMULATED_EXP_UPDATE, {
    self.m_accumulatedExp
  })
end
def.static("table").OnSConstellationRes = function(p)
  local self = instance
  local constellation = p.constellation
  self.m_natalConstellation = constellation
  self.m_nlConstellationCT = p.set_times
  self.m_accumulatedExp = p.sum_exp or 0
  Event.DispatchEvent(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.NATAL_CONSTELLATION_UPDATE, {constellation})
  Event.DispatchEvent(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.ACCUMULATED_EXP_UPDATE, {
    self.m_accumulatedExp
  })
end
def.static("table").OnSSetSelfConstellationRes = function(p)
  local self = instance
  local constellation = p.constellation
  self.m_natalConstellation = constellation
  self.m_nlConstellationCT = p.set_times
  Event.DispatchEvent(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.SET_NATAL_CONSTELLATION_SUCCESS, {constellation})
  Event.DispatchEvent(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.NATAL_CONSTELLATION_UPDATE, {constellation})
  Toast(textRes.Constellation[13])
end
def.static("table", "table").OnEnterWorld = function()
  local activityId = constant.CConstellationConsts.Activityid
  local openTime, activeTimeList, closeTime = ActivityInterface.Instance():getActivityStatusChangeTime(activityId)
  local preNotifyMinutes = constant.CConstellationConsts.BeforeNotifyMinutes or 5
  local preNotifySeconds = preNotifyMinutes * 60
  local curTime = _G.GetServerTime()
  local preNotifyTime
  for idx, timeInfo in ipairs(activeTimeList) do
    preNotifyTime = timeInfo.beginTime - preNotifySeconds
    if curTime <= preNotifyTime then
      break
    end
  end
  if preNotifyTime == nil then
    return
  end
  local leftTime = preNotifyTime - curTime
  if leftTime < 0 then
    return
  end
  local tick = _G.ONE_DAY_SECONDS
  instance:RemovePreNotifyTimer()
  instance.m_preNotifyTimeId = AbsoluteTimer.AddListener(tick, -1, ConstellationModule.OnPreNotifyTime, instance, leftTime - tick)
end
def.static("table", "table").OnLeaveWorld = function()
  instance:Clear()
end
def.static("table", "table").OnActivityStart = function(params)
  local activityId = params and params[1] or 0
  if activityId ~= constant.CConstellationConsts.Activityid then
    return
  end
  print("CM:OnActivityStart", activityId)
  local self = instance
  self:InitActivity()
end
def.static("table", "table").OnActivityEnd = function(params)
  local activityId = params and params[1] or 0
  if activityId ~= constant.CConstellationConsts.Activityid then
    return
  end
  print("CM:OnActivityEnd", activityId)
  local self = instance
  self:SetStage(Stage.STG_FINISHED, nil)
end
def.static("table", "table").OnActivityTodo = function(params)
  local activityId = params and params[1] or 0
  if activityId ~= constant.CConstellationConsts.Activityid then
    return
  end
  local self = instance
  self:ShowLuck12ConstellationPanel()
end
def.static("table", "table").OnFunctionOpenInit = function(params)
  instance:OnFeatureStatusChange()
end
def.static("table", "table").OnFunctionOpenChange = function(params)
  if params and params.feature == Feature.TYPE_CONSTELLATION then
    instance:OnFeatureStatusChange()
  end
end
return ConstellationModule.Commit()
