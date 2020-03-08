local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local CrossBattlefieldModule = Lplus.Extend(ModuleBase, MODULE_NAME)
local CrossBattlefieldProtocol = import(".CrossBattlefieldProtocol")
local CrossBattlefieldUtils = import(".CrossBattlefieldUtils")
local TeamData = require("Main.Team.TeamData")
local ActivityInterface = require("Main.activity.ActivityInterface")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local def = CrossBattlefieldModule.define
def.const("number").MODULE_FEATURE = Feature.TYPE_CROSS_FIELD
def.field("number").m_matchingActId = 0
def.field("table").m_matchDlg = nil
def.field("userdata").m_activeLeaveTimestamp = nil
def.field("boolean").m_clientCheck = true
def.field("number").m_newSeasonTimerId = 0
local instance
def.static("=>", CrossBattlefieldModule).Instance = function()
  if instance == nil then
    instance = CrossBattlefieldModule()
    instance.m_moduleId = ModuleId.CROSS_BATTLEFIELD
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, CrossBattlefieldModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, CrossBattlefieldModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, CrossBattlefieldModule.OnActivityTodo)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, CrossBattlefieldModule.OnNPCService)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, CrossBattlefieldModule.OnFunctionOpenInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, CrossBattlefieldModule.OnFunctionOpenChange)
  CrossBattlefieldProtocol.Init()
end
def.method().ShowBattlefieldsPanel = function(self)
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  local activityId = instance:GetConstant("ACTIVITY_CFG_ID")
  local isNotOpen = not activityInterface:isActivityOpend(activityId)
  if isNotOpen then
    Toast(textRes.activity[270])
    return
  end
  require("Main.CrossBattlefield.ui.BattlefieldsPanel").Instance():ShowPanel()
end
def.method("number", "=>", "boolean").StartMatch = function(self, battlefieldActId)
  if TeamData.Instance():HasTeam() then
    Toast(textRes.CrossBattlefield[2])
    return false
  end
  local isPunished, remainSeconds = self:IsMatchPunished()
  if isPunished then
    local timetext = _G.SeondsToTimeText(remainSeconds)
    Toast(textRes.CrossBattlefield[5]:format(timetext))
    return false
  end
  CrossBattlefieldProtocol.CJoinCrossFieldMatchReq(battlefieldActId)
  return true
end
def.method().CancelMatch = function(self)
  local activityId = self:GetMatchingActivityId()
  CrossBattlefieldProtocol.CCancelCrossFieldMatchReq(activityId)
end
def.method("number").SetMatchingActivityId = function(self, activityId)
  self.m_matchingActId = activityId
end
def.method("=>", "number").GetMatchingActivityId = function(self)
  return self.m_matchingActId
end
def.method("userdata").SetActiveLeaveTimestamp = function(self, timestamp)
  self.m_activeLeaveTimestamp = timestamp
end
def.method("=>", "userdata").GetActiveLeaveTimestamp = function(self)
  if self.m_activeLeaveTimestamp == nil then
    self.m_activeLeaveTimestamp = Int64.new(0)
  end
  return self.m_activeLeaveTimestamp
end
def.method("=>", "boolean", "number").IsMatchPunished = function(self)
  if self.m_clientCheck == false then
    return false, 0
  end
  local leaveTimestamp = self:GetActiveLeaveTimestamp():ToNumber()
  local punishSeconds = self:GetConstant("ACTIVE_LEAVE_FIELD_PUNISH_DURATION_IN_SECOND")
  local curTime = _G.GetServerTime()
  local remainPunishSeconds = punishSeconds - (curTime - leaveTimestamp)
  print("remainPunishSeconds", remainPunishSeconds, leaveTimestamp, curTime)
  if remainPunishSeconds > 0 then
    return true, remainPunishSeconds
  end
  return false, 0
end
def.method("number").ShowMatchingPanel = function(self, activityId)
  self:SetMatchingActivityId(activityId)
  local CommonMatchingDlg = require("GUI.CommonMatchingDlg")
  local ESTIMATED_TIME = 30
  self.m_matchDlg = CommonMatchingDlg.ShowDlg(ESTIMATED_TIME, function()
    self:CancelMatch()
    self.m_matchDlg = nil
  end, nil)
end
def.method().HideMatchingPanel = function(self)
  if self.m_matchDlg then
    self.m_matchDlg:HideDlg()
    self.m_matchDlg = nil
  end
  self:SetMatchingActivityId(0)
end
def.method("number").ShowLoadingPanel = function(self, activityId)
  local BattlefieldLoadingPanel = require("Main.CrossBattlefield.ui.BattlefieldLoadingPanel")
  if BattlefieldLoadingPanel.Instance():IsLoaded() then
    return
  end
  BattlefieldLoadingPanel.Instance():ShowPanel(activityId)
  BattlefieldLoadingPanel.Instance():SetFakeProgressFunc(function(t)
    return math.min(math.log10(1.5 + t), 0.99)
  end)
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  if not _G.IsFeatureOpen(CrossBattlefieldModule.MODULE_FEATURE) then
    return false
  end
  return true
end
def.method("number", "=>", "boolean").IsOpen = function(self, activityId)
  if not self:IsFeatureOpen() then
    print("CrossBattlefield::Feature not open")
    return false
  end
  if not ActivityInterface.Instance():isActivityOpend(activityId) then
    print("CrossBattlefield::activity not open")
    return false
  end
  return true
end
def.method("number", "=>", "boolean").GotoActivityNPC = function(self, activityId)
  if not self:IsOpen(activityId) then
    Toast(textRes.activity[51])
    return false
  end
  local TeamUtils = require("Main.Team.TeamUtils")
  if TeamUtils.CheckIfSelfRestrictedInTeam() then
    return false
  end
  if not _G.PlayerIsTransportable() then
    Toast(textRes.activity[97])
    return false
  end
  local npcid = self:GetConstant("NPC_ID")
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_NPC, {npcid})
  return true
end
def.method("string", "=>", "dynamic").GetConstant = function(self, key)
  return _G.constant.CCrossFieldConsts[key]
end
def.method("=>", "table").GetVisibleBattlefields = function(self)
  local battlefieldCfgs = CrossBattlefieldUtils.GetAllCrossBattlefieldCfgs()
  local battlefields = {}
  for i, v in ipairs(battlefieldCfgs) do
    if _G.IsFeatureOpen(v.moduleid) then
      table.insert(battlefields, v)
    end
  end
  return battlefields
end
def.method("number", "=>", "table").GetDuanweiInfoByStarNum = function(self, starNum)
  local duanweiCfg = CrossBattlefieldUtils.GetDuanweiCfgByStarNum(starNum)
  local duanweiInfo = {}
  duanweiInfo.sortId = duanweiCfg.sort_id
  duanweiInfo.name = duanweiCfg.desc
  duanweiInfo.icon = duanweiCfg.icon_id
  duanweiInfo.starNum = starNum
  duanweiInfo.localStarNum = starNum - duanweiCfg.star_num_lower_limit
  if duanweiCfg.star_num_lower_limit ~= 0 then
    duanweiInfo.localStarNum = duanweiInfo.localStarNum + 1
  end
  duanweiInfo.fullName = textRes.CrossBattlefield[6]:format(duanweiInfo.name, duanweiInfo.localStarNum)
  return duanweiInfo
end
def.method().OpenCreditShop = function(self)
  local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.CREDITS_SHOP, {
    TokenType.SINGLE_CROSS_FIELD_SCORE
  })
end
def.method().ShowAwardPreviewPanel = function(self)
  require("Main.CrossBattlefield.ui.AwardPreviewPanel").Instance():ShowPanel()
end
def.method().OnFeatureStatusChange = function(self)
  local isOpen = self:IsFeatureOpen()
  local activityId = self:GetConstant("ACTIVITY_CFG_ID")
  if isOpen then
    ActivityInterface.Instance():removeCustomCloseActivity(activityId)
  else
    ActivityInterface.Instance():addCustomCloseActivity(activityId)
  end
  local npcid = self:GetConstant("NPC_ID")
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {npcid = npcid, show = isOpen})
end
def.method("boolean").EnableClientCheck = function(self, isEnable)
  self.m_clientCheck = isEnable
end
def.method().StartNewSeasonTimer = function(self)
  self:StopNewSeasonTimer()
  local _, nextSeasonInfo = CrossBattlefieldUtils.GetRecentlySeasonInfo()
  if nextSeasonInfo then
    local v = nextSeasonInfo
    self.m_newSeasonTimerId = AbsoluteTimer.AddServerTimeEvent(v.year, v.month, v.day, v.hour, v.minute, 1, 0, CrossBattlefieldModule.OnNewSeason, self)
  end
end
def.method().StopNewSeasonTimer = function(self)
  if self.m_newSeasonTimerId ~= 0 then
    AbsoluteTimer.RemoveListener(self.m_newSeasonTimerId)
    self.m_newSeasonTimerId = 0
  end
end
def.method().OnNewSeason = function(self)
  local seasonMgr = require("Main.CrossBattlefield.CrossBattlefieldSeasonMgr").Instance()
  seasonMgr:Reset()
  seasonMgr:AutoSetSeason()
  self:StartNewSeasonTimer()
end
def.method().Clear = function(self)
  self.m_matchingActId = 0
end
def.static("table", "table").OnEnterWorld = function(params, context)
  local self = instance
  if self.m_matchingActId ~= 0 then
    self:ShowMatchingPanel(self.m_matchingActId)
  end
  local seasonMgr = require("Main.CrossBattlefield.CrossBattlefieldSeasonMgr").Instance()
  seasonMgr:AutoSetSeason()
  self:StartNewSeasonTimer()
  CrossBattlefieldProtocol.OnEnterWorld(params, context)
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  CrossBattlefieldProtocol.OnLeaveWorld(params, context)
  local self = instance
  self:Clear()
  self:StopNewSeasonTimer()
end
def.static("table", "table").OnActivityTodo = function(params, context)
  local activityId = params[1]
  local selfActivityId = instance:GetConstant("ACTIVITY_CFG_ID")
  if activityId ~= selfActivityId then
    return
  end
  instance:GotoActivityNPC(activityId)
end
def.static("table", "table").OnNPCService = function(params, context)
  local serviceID = params[1]
  local joinBattlefieldServiceId = instance:GetConstant("ATTEND_ACTIVITY_NPC_SERVICE_ID")
  local scoreExchangeServiceId = instance:GetConstant("POINT_EXCHANGE_NPC_SERVICE_ID")
  local awardPreviewServiceId = instance:GetConstant("GRADE_INSTRUCTION_NPC_SERVICE_ID")
  if serviceID == joinBattlefieldServiceId then
    instance:ShowBattlefieldsPanel()
  elseif serviceID == scoreExchangeServiceId then
    instance:OpenCreditShop()
  elseif serviceID == awardPreviewServiceId then
    instance:ShowAwardPreviewPanel()
  end
end
def.static("table", "table").OnFunctionOpenInit = function(params, context)
  instance:OnFeatureStatusChange()
end
def.static("table", "table").OnFunctionOpenChange = function(params, context)
  if params and params.feature == CrossBattlefieldModule.MODULE_FEATURE then
    instance:OnFeatureStatusChange()
  end
end
return CrossBattlefieldModule.Commit()
