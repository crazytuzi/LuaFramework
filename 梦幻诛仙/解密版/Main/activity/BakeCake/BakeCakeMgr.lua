local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BakeCakeMgr = Lplus.Class(MODULE_NAME)
local def = BakeCakeMgr.define
local BakeCakeUtils = import(".BakeCakeUtils")
local BakeCakeProtocol = import(".BakeCakeProtocol")
local GangModule = Lplus.ForwardDeclare("GangModule")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local GangUtility = require("Main.Gang.GangUtility")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local GangData = require("Main.Gang.data.GangData")
local CakeDetailInfo = require("netio.protocol.mzm.gsp.cake.CakeDetailInfo")
local Stage = {
  None = 0,
  Prepare = 1,
  BakeTime = 2,
  BreakTime = 3,
  End = 4
}
def.const("table").Stage = Stage
def.field("table").m_feature2ActivityId = nil
def.field("table").m_activeActInfo = nil
def.field("number").m_stageTimerId = 0
def.field("table").m_activityInfos = nil
def.field("number").m_maxCakeLevel = -1
local instance
def.static("=>", BakeCakeMgr).Instance = function()
  if instance == nil then
    instance = BakeCakeMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, BakeCakeMgr.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, BakeCakeMgr.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, BakeCakeMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, BakeCakeMgr.OnActivityTodo)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, BakeCakeMgr.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, BakeCakeMgr.OnActivityReset)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, BakeCakeMgr.OnActivityEnd)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.BtnClickInChat, BakeCakeMgr.OnChatBtnClick)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, BakeCakeMgr.OnChangeMap)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, BakeCakeMgr.OnGangChange)
  BakeCakeProtocol.Init(self)
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  ItemTipsMgr.RegisterPostTipsHandler(ItemType.CAKE_AWARD_ITEM, BakeCakeMgr.PostTipsContentHandler)
end
def.method("number", "=>", "boolean").CheckActiveActivityData = function(self, activityId)
  local isOpen = activityInterface:isActivityOpend(activityId)
  if not isOpen then
    return false
  end
  local openTime, activeTimeList, closeTime = activityInterface:getActivityStatusChangeTime(activityId)
  local curTime = GetServerTime()
  local beginTime
  for i, v in ipairs(activeTimeList) do
    if curTime >= v.beginTime and curTime < v.resetTime and openTime <= v.beginTime then
      beginTime = v.beginTime
      break
    end
  end
  if beginTime == nil then
    return false
  end
  self.m_activeActInfo = {}
  self.m_activeActInfo.activityId = activityId
  self.m_activeActInfo.beginTime = beginTime
  local activityInfo = self:GetActivityInfo(activityId)
  if activityInfo == nil then
    self:InitActivityInfo(activityId)
  end
  self:CheckActiveActivityScene()
  return true
end
def.method("=>", "number").ReCheckActiveActivityData = function(self)
  for switchId, activityId in pairs(self.m_feature2ActivityId) do
    if IsFeatureOpen(switchId) and self:CheckActiveActivityData(activityId) then
      return activityId
    end
  end
  return 0
end
def.method().CheckActiveActivityScene = function(self)
  local activityId = self:GetActiveActivityId()
  if activityId == 0 then
    return
  end
  if not GangUtility.IsHeroInSelfGangMap() then
    return
  end
  local stageInfo = self:GetActiveActivityStageInfo()
  if stageInfo.stage == Stage.Prepare then
    self:ShowPrepareUI()
  elseif stageInfo.stage == Stage.BreakTime then
    local activityInfo = self:GetActivityInfo(activityId)
    if activityInfo and stageInfo.round > activityInfo.curTurn + 1 then
      self:ResetRoundData(stageInfo.round)
    end
  elseif stageInfo.stage == Stage.BakeTime then
    local activityInfo = self:GetActivityInfo(activityId)
    if activityInfo and stageInfo.round > activityInfo.curTurn then
      self:ResetRoundData(stageInfo.round)
    end
  end
  self:SetupStageTimer(stageInfo)
end
def.method().ClearActiveActivityData = function(self)
  self:ClearActiveActivityScene()
  self.m_activeActInfo = nil
end
def.method().ClearActiveActivityScene = function(self)
  local activityId = self:GetActiveActivityId()
  if activityId == 0 then
    return
  end
  self:RemoveStageTimer()
  require("Main.activity.BakeCake.BakeCakeCountDownMgr").Instance():EndCountDown()
  require("Main.activity.BakeCake.ui.BakeCakeMainPanel").Instance():DestroyPanel()
end
def.method().ShowPrepareUI = function(self)
  local curTime = _G.GetServerTime()
  local beginTime = self.m_activeActInfo.beginTime
  local activityId = self.m_activeActInfo.activityId
  local cfg = BakeCakeUtils.GetBakeCakeActivityCfg(activityId)
  if cfg == nil then
    return
  end
  local prepareStageEndTime = beginTime + cfg.prepareTime
  require("Main.activity.BakeCake.BakeCakeCountDownMgr").Instance():StartCountDown(prepareStageEndTime)
end
def.method().ShowMainUI = function(self)
  local selfHasGang = require("Main.Gang.GangModule").Instance():HasGang()
  if not selfHasGang then
    Toast(textRes.BakeCake[28])
    return
  end
  if not GangUtility.IsHeroInSelfGangMap() then
    Toast(textRes.BakeCake[29])
    return
  end
  local activityId = self:GetActiveActivityId()
  if activityId == 0 then
    activityId = self:ReCheckActiveActivityData()
    if activityId == 0 then
      Toast(textRes.activity[51])
      return
    end
  end
  if ActivityInterface.CheckActivityConditionLevel(activityId, true) == false then
    return
  end
  local activityInfo = self:GetActivityInfo(activityId)
  if activityInfo == nil then
    Toast(textRes.BakeCake[31])
    return
  end
  local selfGangId = GangData.Instance():GetGangId()
  if activityInfo.effectFactionId ~= _G.Zero_Int64 and selfGangId ~= activityInfo.effectFactionId then
    Toast(textRes.BakeCake[30])
    return
  end
  local panel = require("Main.activity.BakeCake.ui.BakeCakeMainPanel").Instance()
  panel:ShowPanel()
end
def.method("number").OnActivityFeatureOpen = function(self, activityId)
  activityInterface:removeCustomCloseActivity(activityId)
  gmodule.moduleMgr:GetModule(ModuleId.ACTIVITY):RegisterActivityTipFunc(activityId, function()
    return self:CanShowActivityTip(activityId)
  end)
  self:CheckActiveActivityData(activityId)
end
def.method("number").OnActivityFeatureClose = function(self, activityId)
  activityInterface:addCustomCloseActivity(activityId)
  gmodule.moduleMgr:GetModule(ModuleId.ACTIVITY):RegisterActivityTipFunc(activityId, nil)
  local actActivityId = self:GetActiveActivityId()
  if actActivityId == activityId then
    self:ClearActiveActivityData()
  end
end
def.method("table").SetupStageTimer = function(self, stageInfo)
  local stage = stageInfo.stage
  if stage == Stage.None or stage == Stage.End then
    return
  end
  self:RemoveStageTimer()
  self:OnStageBegin(stageInfo)
  local curTime = _G.GetServerTime()
  self.m_stageTimerId = AbsoluteTimer.AddListener(stageInfo.stageEndTime - curTime, 0, function()
    self:OnStageEnd(stageInfo)
  end, nil, 0)
end
def.method().RemoveStageTimer = function(self)
  if self.m_stageTimerId ~= 0 then
    AbsoluteTimer.RemoveListener(self.m_stageTimerId)
    self.m_stageTimerId = 0
  end
end
def.method("table").OnStageBegin = function(self, stageInfo)
  warn(string.format("BakeCakeMgr:OnStageBegin.........%d,%d", stageInfo.stage, stageInfo.round))
  local stage = stageInfo.stage
  if stage == Stage.BakeTime then
    self:OnBakeStageBegin(stageInfo)
  end
end
def.method("table").OnBakeStageBegin = function(self, stageInfo)
  local round = stageInfo.round
  local text = textRes.BakeCake[35]:format(round)
  GangModule.ShowInGangChannel(text)
  Toast(text)
end
def.method("table").OnStageEnd = function(self, stageInfo)
  warn(string.format("BakeCakeMgr:OnStageEnd.........%d,%d", stageInfo.stage, stageInfo.round))
  local stage = stageInfo.stage
  if stage == Stage.Prepare then
    self:OnPrepareStageEnd(stageInfo)
  elseif stage == Stage.BreakTime then
    self:OnBreakStageEnd(stageInfo)
  end
  local newStageInfo = self:GetActiveActivityStageInfo()
  if newStageInfo.stage == Stage.End then
    self:OnAllStageEnd(newStageInfo)
    return
  end
  self:SetupStageTimer(newStageInfo)
end
def.method("table").OnPrepareStageEnd = function(self, stageInfo)
end
def.method("table").OnBreakStageEnd = function(self, stageInfo)
  self:ResetRoundData(stageInfo.round)
end
def.method("table").OnAllStageEnd = function(self, stageInfo)
  local activityId = stageInfo.activityId
  local cfg = BakeCakeUtils.GetBakeCakeActivityCfg(activityId)
  if cfg == nil then
    return
  end
  local fxId = cfg.finishTipEffectId
  if fxId == nil then
    warn("no fxId")
    return
  end
  local effRes = GetEffectRes(fxId)
  if effRes then
    local effectPath = effRes.path
    local guiFxMan = require("Fx.GUIFxMan").Instance()
    guiFxMan:Play(effectPath, tostring(fxId), 0, 0, -1, false)
  end
end
def.method("number").InitRoundData = function(self, round)
  local activityId = self:GetActiveActivityId()
  local activityInfo = self:GetActivityInfo(activityId)
  if activityInfo == nil then
    return
  end
  activityInfo.effectFactionId = GangData.Instance():GetGangId()
  activityInfo.roleCakeHistoryList = {}
  local strRoleId = tostring(_G.GetMyRoleID())
  activityInfo.roleCakeHistoryList[strRoleId] = {}
  self:ReqGangMembersCakeInfos(activityId, function()
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_BakeCake_Cake_List_Change, nil)
  end)
end
def.method("number").ResetRoundData = function(self, round)
  local activityId = self:GetActiveActivityId()
  local activityInfo = self:GetActivityInfo(activityId)
  if activityInfo == nil then
    return
  end
  activityInfo.curTurn = round
  activityInfo.cookSelfCount = 0
  activityInfo.cookOtherCount = 0
  if activityInfo.gangCakeInfos then
    local removeCakeInfos = {}
    for key, cakeInfo in pairs(activityInfo.gangCakeInfos) do
      if round >= cakeInfo.curTurn then
        table.insert(removeCakeInfos, key)
      end
    end
    for i, key in ipairs(removeCakeInfos) do
      activityInfo.gangCakeInfos[key] = nil
    end
  end
  activityInfo.effectFactionId = _G.Zero_Int64
  activityInfo.roleCakeHistoryList = nil
  activityInfo.cakeInfo = nil
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_BakeCake_Round_Reset, nil)
end
def.method("=>", "table").GetActiveActivityStageInfo = function(self)
  local function stageInfo(stage, stageBeginTime, stageEndTime, round)
    return {
      stage = stage or Stage.None,
      stageBeginTime = stageBeginTime or 0,
      stageEndTime = stageEndTime or 0,
      round = round or 0,
      activityId = self.m_activeActInfo and self.m_activeActInfo.activityId or 0
    }
  end
  if self.m_activeActInfo == nil then
    return stageInfo(nil)
  end
  local curTime = _G.GetServerTime()
  local beginTime = self.m_activeActInfo.beginTime
  local activityId = self.m_activeActInfo.activityId
  local cfg = BakeCakeUtils.GetBakeCakeActivityCfg(activityId)
  if cfg == nil then
    return stageInfo(nil)
  end
  local activityEndTime = beginTime + cfg.prepareTime + cfg.cookTurn * (cfg.cookTime + cfg.cookPrepareTime)
  if curTime >= activityEndTime then
    return stageInfo(Stage.End)
  end
  local prepareStageEndTime = beginTime + cfg.prepareTime
  if curTime < prepareStageEndTime then
    return stageInfo(Stage.Prepare, beginTime, prepareStageEndTime)
  end
  local stageBeginTime = prepareStageEndTime
  local stageEndTime = stageBeginTime
  local round = 1
  while curTime >= stageEndTime do
    stageEndTime = stageBeginTime + cfg.cookPrepareTime
    if curTime < stageEndTime then
      return stageInfo(Stage.BreakTime, stageBeginTime, stageEndTime, round)
    end
    stageBeginTime = stageEndTime
    stageEndTime = stageBeginTime + cfg.cookTime
    if curTime < stageEndTime then
      return stageInfo(Stage.BakeTime, stageBeginTime, stageEndTime, round)
    end
    stageBeginTime = stageEndTime
    round = round + 1
  end
  return nil
end
def.method("=>", "number", "number", "number").GetActiveActivityStage = function(self)
  local stageInfo = self:GetActiveActivityStageInfo()
  return stageInfo.stage, stageInfo.stageBeginTime, stageInfo.stageEndTime
end
def.method("=>", "boolean").CanJoinActivity = function(self)
  if not gmodule.moduleMgr:GetModule(ModuleId.GANG):HasGang() then
    return false
  end
  return true
end
def.method("=>", "number").GetMaxCakeLevel = function(self)
  if self.m_maxCakeLevel == -1 then
    self.m_maxCakeLevel = BakeCakeUtils.GetMaxCakeLevel()
  end
  return self.m_maxCakeLevel
end
def.method("=>", "number").GetMinCakeLevel = function(self)
  return 1
end
def.method("number", "=>", "boolean").CanShowActivityTip = function(self, activityId)
  if not self:CanJoinActivity() then
    return false
  end
  return true
end
def.method("number").GotoParticipateActivity = function(self, activityId)
  local cfg = BakeCakeUtils.GetBakeCakeActivityCfg(activityId)
  if cfg == nil then
    return
  end
  if not _G.IsFeatureOpen(cfg.switchId) then
    Toast(textRes.activity[51])
    warn(string.format("BakeCakeMgr: feature(%d) not open", cfg.switchId))
    return
  end
  if not gmodule.moduleMgr:GetModule(ModuleId.GANG):HasGang() then
    Toast(textRes.BakeCake[1])
    return
  end
  GangModule.Instance():GotoGangMap()
end
def.method("number", "=>", "boolean").IsBakeCakeActivity = function(self, todoActivityId)
  if self.m_feature2ActivityId == nil then
    return false
  end
  for switchId, activityId in pairs(self.m_feature2ActivityId) do
    if todoActivityId == activityId then
      return true
    end
  end
  return false
end
def.method("number", "=>", "boolean").IsOpendBakeCakeActivity = function(self, todoActivityId)
  if self.m_feature2ActivityId == nil then
    return false
  end
  for switchId, activityId in pairs(self.m_feature2ActivityId) do
    if todoActivityId == activityId then
      if IsFeatureOpen(switchId) then
        return true
      else
        return false
      end
    end
  end
  return false
end
def.method("number").OnBakeCakeActivityStart = function(self, activityId)
  self:CheckActiveActivityData(activityId)
  if not gmodule.moduleMgr:GetModule(ModuleId.GANG):HasGang() then
    return
  end
  self:ShowActivityStartMsg(activityId)
end
def.method("number").OnBakeCakeActivityEnd = function(self, activityId)
  local actActivityId = self:GetActiveActivityId()
  if actActivityId == activityId then
    self:ClearActiveActivityData()
  elseif self.m_activityInfos then
    self.m_activityInfos[activityId] = nil
  end
end
def.method("number").ShowActivityStartMsg = function(self, activityId)
  local activityName = self:GetActivityName(activityId)
  local text = textRes.BakeCake[2]:format(activityName)
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local link = string.format("<a href='btn_joinBakeCakeActivity_%d' id=btn_joinBakeCakeActivity_%d><font color=#%s><u>[%s]</u></font></a>", activityId, activityId, link_defalut_color, textRes.BakeCake[3])
  local content = string.format("%s%s", textRes.BakeCake[2]:format(activityName), link)
  ChatModule.Instance():SendNoteMsg(content, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = content})
end
def.method("number", "=>", "string").GetActivityName = function(self, activityId)
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  local activityName = activityCfg and activityCfg.activityName or "$activity_name"
  return activityName
end
def.method("number").InitActivityInfo = function(self, activityId)
  local stageInfo = self:GetActiveActivityStageInfo()
  local RoleCakeInfo = require("netio.protocol.mzm.gsp.cake.RoleCakeInfo")
  local activityInfo = RoleCakeInfo.new(0, 0)
  activityInfo.curTurn = stageInfo.round
  activityInfo.cookSelfCount = 0
  activityInfo.cookOtherCount = 0
  activityInfo.effectFactionId = _G.Zero_Int64
  activityInfo.cakeInfo = nil
  self:SetActivityInfo(activityId, activityInfo)
end
def.method("table").SetActivityInfos = function(self, activityInfos)
  self.m_activityInfos = {}
  for activityId, activityInfo in pairs(activityInfos) do
    self:SetActivityInfo(activityId, activityInfo)
  end
  if GangUtility.IsHeroInSelfGangMap() then
    self:CheckActiveActivityScene()
  end
end
def.method("number", "table").SetActivityInfo = function(self, activityId, activityInfo)
  self.m_activityInfos = self.m_activityInfos or {}
  self.m_activityInfos[activityId] = activityInfo
end
def.method("number", "=>", "table").GetActivityInfo = function(self, activityId)
  if self.m_activityInfos == nil then
    return nil
  end
  return self.m_activityInfos[activityId]
end
def.method("=>", "number").GetActiveActivityId = function(self)
  if self.m_activeActInfo == nil then
    return 0
  end
  return self.m_activeActInfo.activityId
end
def.method("number", "=>", "number").GetBakeSelfsCakeLeftTimes = function(self, activityId)
  local cfg = BakeCakeUtils.GetBakeCakeActivityCfg(activityId)
  if cfg == nil then
    return 0
  end
  local activityInfo = self:GetActivityInfo(activityId)
  if activityInfo == nil then
    return 0
  end
  return math.max(0, cfg.selfCookCountMax - activityInfo.cookSelfCount)
end
def.method("number", "=>", "number").GetBakeOthersCakeLeftTimes = function(self, activityId)
  local cfg = BakeCakeUtils.GetBakeCakeActivityCfg(activityId)
  if cfg == nil then
    return 0
  end
  local activityInfo = self:GetActivityInfo(activityId)
  if activityInfo == nil then
    return 0
  end
  return math.max(0, cfg.helpCookCountMax - activityInfo.cookOtherCount)
end
def.method("number").IncBakeSelfsCakeLeftTimes = function(self, activityId)
  local activityInfo = self:GetActivityInfo(activityId)
  if activityInfo == nil then
    return
  end
  activityInfo.cookSelfCount = activityInfo.cookSelfCount + 1
end
def.method("number").IncBakeOthersCakeLeftTimes = function(self, activityId)
  local activityInfo = self:GetActivityInfo(activityId)
  if activityInfo == nil then
    return
  end
  activityInfo.cookOtherCount = activityInfo.cookOtherCount + 1
end
def.method("number", "userdata", "table").SetRoleCakeInfo = function(self, activityId, roleId, cakeInfo)
  local activityInfo = self:GetActivityInfo(activityId)
  if activityInfo == nil then
    warn(string.format("Attmpt to set role(%s) cakeInfo, but the activityInfo is nil for activityId = %d", tostring(roleId), activityId))
    return
  end
  if roleId == _G.GetMyRoleID() then
    activityInfo.cakeInfo = cakeInfo
  end
  if activityInfo.gangCakeInfos == nil then
    return
  end
  activityInfo.gangCakeInfos[tostring(roleId)] = cakeInfo
end
def.method("number", "userdata", "=>", "table").GetRoleCakeInfo = function(self, activityId, roleId)
  local activityInfo = self:GetActivityInfo(activityId)
  if activityInfo == nil then
    return nil
  end
  if roleId == _G.GetMyRoleID() then
    return activityInfo.cakeInfo
  end
  if activityInfo.gangCakeInfos == nil then
    return nil
  end
  return activityInfo.gangCakeInfos[roleId:tostring()]
end
def.method("number", "userdata", "=>", "string").GetRoleNameInActivity = function(self, activityId, roleId)
  local myRoleId = _G.GetMyRoleID()
  if roleId == myRoleId then
    return _G.GetHeroProp().name
  else
    local unknowName = "player unknow"
    local activityInfo = self:GetActivityInfo(activityId)
    if activityInfo == nil then
      return unknowName
    end
    if activityInfo.gangMemberNames == nil then
      return unknowName
    end
    return activityInfo.gangMemberNames[roleId:tostring()] or unknowName
  end
end
def.method("number", "userdata", "string").SetRoleNameInActivity = function(self, activityId, roleId, roleName)
  local activityInfo = self:GetActivityInfo(activityId)
  if activityInfo == nil then
    return
  end
  if activityInfo.gangMemberNames == nil then
    return
  end
  activityInfo.gangMemberNames[roleId:tostring()] = roleName
end
def.method("number", "function").LoadGangMembersCakeInfos = function(self, activityId, callback)
  local activityInfo = self:GetActivityInfo(activityId)
  if activityInfo == nil then
    return
  end
  if activityInfo.gangCakeInfos then
    _G.SafeCallback(callback)
    return
  end
  self:ReqGangMembersCakeInfos(activityId, callback)
end
def.method("number", "function").ReqGangMembersCakeInfos = function(self, activityId, callback)
  local gangId = GangData.Instance():GetGangId()
  BakeCakeProtocol.CGetFactionCakeInfoReq(activityId, gangId, function(p)
    local activityInfo = self:GetActivityInfo(activityId)
    activityInfo.gangCakeInfos = {}
    activityInfo.gangMemberNames = {}
    for roleId, roleCakeInfo in pairs(p.factionCakeInfo) do
      local strRoleId = roleId:tostring()
      local cakeInfo, roleName
      if roleCakeInfo.roleName then
        cakeInfo = roleCakeInfo.cakeInfo
        roleName = _G.GetStringFromOcts(roleCakeInfo.roleName)
        activityInfo.gangMemberNames[strRoleId] = roleName
      else
        cakeInfo = roleCakeInfo
      end
      activityInfo.gangCakeInfos[strRoleId] = cakeInfo
    end
    _G.SafeCallback(callback)
  end)
end
def.method("number", "=>", "table").GetGangMembersCakeInfos = function(self, activityId)
  local activityInfo = self:GetActivityInfo(activityId)
  if activityInfo == nil then
    return nil
  end
  return activityInfo.gangCakeInfos
end
def.method("number", "userdata", "function").LoadGangMemberCakeHistoryList = function(self, activityId, roleId, callback)
  local historyList = self:GetGangMemberCakeHistoryList(activityId, roleId)
  if historyList then
    _G.SafeCallback(callback, activityId, roleId, historyList)
    return
  end
  local gangId = GangData.Instance():GetGangId()
  BakeCakeProtocol.CCheckCakeHistoryReq(activityId, gangId, roleId, function(p)
    local activityInfo = self:GetActivityInfo(activityId)
    activityInfo.roleCakeHistoryList = activityInfo.roleCakeHistoryList or {}
    local historyList = p.history
    table.sort(historyList, function(lhs, rhs)
      return lhs.recordTime > rhs.recordTime
    end)
    activityInfo.roleCakeHistoryList[roleId:tostring()] = historyList
    _G.SafeCallback(callback, activityId, roleId, historyList)
  end)
end
def.method("number", "userdata", "=>", "table").GetGangMemberCakeHistoryList = function(self, activityId, roleId)
  local activityInfo = self:GetActivityInfo(activityId)
  if activityInfo == nil then
    return nil
  end
  if activityInfo.roleCakeHistoryList == nil then
    return nil
  end
  return activityInfo.roleCakeHistoryList[roleId:tostring()]
end
def.method("number", "userdata", "table").AddCakeHistory = function(self, activityId, roleId, newHistory)
  local activityInfo = self:GetActivityInfo(activityId)
  if activityInfo == nil then
    return
  end
  if activityInfo.roleCakeHistoryList == nil then
    return
  end
  local strRoleId = roleId:tostring()
  local historyList = activityInfo.roleCakeHistoryList[strRoleId]
  if historyList == nil then
    return
  end
  local index
  for i, history in ipairs(historyList) do
    if newHistory.recordTime > history.recordTime then
      index = i
      break
    end
  end
  index = index or #historyList + 1
  table.insert(historyList, index, newHistory)
  activityInfo.roleCakeHistoryList[strRoleId] = historyList
end
def.method("table", "=>", "string").ConvertHistoryToLogText = function(self, history)
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local minLevel = self:GetMinCakeLevel()
  local maxLevel = self:GetMaxCakeLevel()
  local myName = _G.GetHeroProp().name
  local operatorName = _G.GetStringFromOcts(history.makeRoleName)
  if myName == operatorName then
    operatorName = textRes.BakeCake[22]
  end
  local ownerName = _G.GetStringFromOcts(history.masterName)
  if myName == ownerName then
    ownerName = textRes.BakeCake[22]
  end
  local newLevel = history.newRank
  local itemName = HtmlHelper.GetColoredItemName(history.itemId)
  local text
  if maxLevel <= newLevel then
    local useText = textRes.BakeCake[21]:format(itemName, newLevel, ownerName)
    text = textRes.BakeCake[19]:format(operatorName, useText)
  elseif minLevel >= newLevel then
    local useText = textRes.BakeCake[21]:format(itemName, newLevel, ownerName)
    text = textRes.BakeCake[20]:format(operatorName, useText)
  else
    text = textRes.BakeCake[18]:format(operatorName, itemName, newLevel, ownerName)
  end
  text = HtmlHelper.ConvertHtmlColorToBBCode(text)
  return text
end
def.method("number").ReqAddCake = function(self, activityId)
  local stageInfo = self:GetActiveActivityStageInfo()
  BakeCakeProtocol.CAddCakeReq(activityId, stageInfo.round)
end
def.method("number", "userdata", "number").ReqAddFavoring = function(self, activityId, cakeOwnerId, itemId)
  local ItemModule = require("Main.Item.ItemModule")
  local bagId = ItemModule.Instance():GetBagIdByItemId(itemId)
  local items = ItemModule.Instance():GetItemsByItemID(bagId, itemId)
  local itemNum = table.nums(items)
  if itemNum == 0 then
    print(("ReqAddFavoring: no item(%d) in bag(%d)"):format(itemId, bagId))
    return
  end
  local _, item = next(items)
  local itemUUID = item.uuid[1]
  local stageInfo = self:GetActiveActivityStageInfo()
  local useNum = 1
  BakeCakeProtocol.CMakeCakeReq(activityId, cakeOwnerId, itemUUID, useNum, stageInfo.round)
end
def.method("number", "userdata").ReqUseCakeItem = function(self, itemId, itemUUID)
  local ItemModule = require("Main.Item.ItemModule")
  local useNum = 1
  BakeCakeProtocol.CUseCakeItem(itemUUID, useNum)
end
def.method().Clear = function(self)
  self:ClearActiveActivityData()
  self.m_feature2ActivityId = nil
  self.m_activityInfos = nil
end
def.static("table", "=>", "userdata").GetRoleIdFromItem = function(item)
  if item == nil then
    return nil
  end
  local ItemUtils = require("Main.Item.ItemUtils")
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local roleId = ItemUtils.GetRoleIdByItem(item, ItemXStoreType.CAKE_MAKER_ID_LOW, ItemXStoreType.CAKE_MAKER_ID_HIGH)
  return roleId
end
def.static("table", "table").OnFeatureOpenInit = function(params, context)
  local briefCfgs = BakeCakeUtils.GetAllBakeCakeActivityBriefCfgs()
  instance.m_feature2ActivityId = {}
  for i, v in ipairs(briefCfgs) do
    if IsFeatureOpen(v.switchId) then
      instance:OnActivityFeatureOpen(v.activityId)
    else
      instance:OnActivityFeatureClose(v.activityId)
    end
    instance.m_feature2ActivityId[v.switchId] = v.activityId
  end
end
def.static("table", "table").OnFeatureOpenChange = function(params, context)
  if instance.m_feature2ActivityId == nil then
    return
  end
  local switchId = params.feature
  local activityId = instance.m_feature2ActivityId[switchId]
  if activityId == nil then
    return
  end
  if IsFeatureOpen(switchId) then
    instance:OnActivityFeatureOpen(activityId)
  else
    instance:OnActivityFeatureClose(activityId)
  end
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  instance:Clear()
end
def.static("table", "table").OnActivityTodo = function(params, context)
  local todoActivityId = params[1]
  if instance.m_feature2ActivityId == nil then
    return
  end
  if instance:IsBakeCakeActivity(todoActivityId) then
    instance:GotoParticipateActivity(todoActivityId)
  end
end
def.static("table", "table").OnActivityStart = function(params, context)
  local activityId = params[1]
  if instance:IsOpendBakeCakeActivity(activityId) then
    warn("OnBakeCakeActivityStart_" .. activityId)
    instance:OnBakeCakeActivityStart(activityId)
  end
end
def.static("table", "table").OnActivityReset = function(params, context)
  local activityId = params[1]
  if instance:IsOpendBakeCakeActivity(activityId) then
    warn("OnBakeCakeActivityReset_" .. activityId)
  end
end
def.static("table", "table").OnActivityEnd = function(params, context)
  local activityId = params[1]
  if instance:IsOpendBakeCakeActivity(activityId) then
    warn("OnBakeCakeActivityEnd_" .. activityId)
    instance:OnBakeCakeActivityEnd(activityId)
  end
end
def.static("table", "table").OnChatBtnClick = function(params, context)
  local id = params.id
  if string.sub(id, 1, #"joinBakeCakeActivity") == "joinBakeCakeActivity" then
    local strs = id:split("_")
    local activityId = tonumber(strs[#strs])
    instance:GotoParticipateActivity(activityId)
  end
end
def.static("table", "table").OnChangeMap = function(params, context)
  if instance.m_activeActInfo == nil then
    return
  end
  if GangUtility.IsHeroInSelfGangMap() then
    instance:CheckActiveActivityScene()
  else
    instance:ClearActiveActivityScene()
  end
end
def.static("table", "table").OnGangChange = function(params, context)
  if instance.m_activeActInfo == nil then
    return
  end
  if GangUtility.IsHeroInSelfGangMap() then
    instance:CheckActiveActivityScene()
  else
    instance:ClearActiveActivityScene()
  end
end
def.static("table", "table", "table").PostTipsContentHandler = function(item, itemBase, itemTips)
  if itemTips == nil then
    return
  end
  local roleId = BakeCakeMgr.GetRoleIdFromItem(item)
  if roleId == nil then
    return
  end
  gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):AsyncGetRoleName(roleId, function(retRoleId, roleName)
    if not itemTips:IsShow() then
      return
    end
    roleName = roleName or textRes.Item[13202]
    local desc = itemTips.desc
    itemTips.desc = ""
    local appendHtml = desc:format(roleName)
    itemTips:AppendContent(appendHtml)
  end)
end
return BakeCakeMgr.Commit()
