local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local GangDungeonModule = Lplus.Extend(ModuleBase, "GangDungeonModule")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local GangUtility = require("Main.Gang.GangUtility")
local GangData = require("Main.Gang.data.GangData")
local ActivityInterface = require("Main.activity.ActivityInterface")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local OpenTimeHelper = require("Main.GangDungeon.OpenTimeHelper")
local GangDungeonUtils = require("Main.GangDungeon.GangDungeonUtils")
local GangDungeonProtocol = require("Main.GangDungeon.GangDungeonProtocol")
local MathHelper = require("Common.MathHelper")
local GUIFxMan = require("Fx.GUIFxMan")
local GangDungeonPlayerData = require("Main.GangDungeon.GangDungeonPlayerData")
local def = GangDungeonModule.define
def.const("table").DungeonStage = require("netio.protocol.mzm.gsp.factionpve.SFactionPVEStageBrd")
def.const("number").MODULE_FEATURE = Feature.TYPE_FACTION_PVE
def.field("boolean").m_inGangDungeon = false
def.field("userdata").m_openTimestamp = nil
def.field("boolean").m_cond = true
def.field("number").m_setTimes = 0
def.field("number").m_activateTimes = 0
def.field("number").m_resetTimes = 0
def.field("number").m_lastDungeonStage = -1
def.field("number").m_dungeonStage = -1
def.field("userdata").m_stageEndTime = nil
def.field("table").m_personalGoals = nil
def.field("number").m_personalGoalRound = 1
def.field("table").m_gangGoals = nil
def.field("table").m_bossGoals = nil
def.field("number").m_dungeonOpenTimer = 0
def.field("number").m_preapreRoleNum = 0
local instance
def.static("=>", GangDungeonModule).Instance = function()
  if instance == nil then
    instance = GangDungeonModule()
    instance.m_moduleId = ModuleId.GANG_DUNGEON
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MAINUI_SHOW, GangDungeonModule.OnMainUIReady)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, GangDungeonModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, GangDungeonModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, GangDungeonModule.OnMapChange)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, GangDungeonModule.OnNPCService)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, GangDungeonModule.OnActivityTodo)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, GangDungeonModule.OnActivityReset)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.BtnClickInChat, GangDungeonModule.OnChatBtnClick)
  Event.RegisterEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.DungeonStageChanged, GangDungeonModule.OnDungeonStageChanged)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, GangDungeonModule.OnFunctionOpenInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, GangDungeonModule.OnFunctionOpenChange)
  GangDungeonProtocol.Init()
end
def.override().LateInit = function(self)
  local activityId = self:GetActivityId()
  gmodule.moduleMgr:GetModule(ModuleId.ACTIVITY):RegisterActivityTipFunc(activityId, GangDungeonModule.CanShowActivityTip)
end
def.method("=>", "boolean").IsOpen = function(self)
  if not self:IsFeatureOpen() then
    return false
  end
  return true
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  local isOpen = feature:CheckFeatureOpen(GangDungeonModule.MODULE_FEATURE)
  return isOpen
end
def.method().OpenMainPanel = function(self)
  if not gmodule.moduleMgr:GetModule(ModuleId.GANG):HasGang() then
    local activityName = self:GetActivityName()
    local text = textRes.GangDungeon[24]:format(activityName)
    Toast(text)
    return
  end
  require("Main.GangDungeon.ui.GangDungeonMainPanel").Instance():ShowPanel()
end
def.method("=>", "boolean").CheckOpenGangDungeonAuthority = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local memberInfo = GangData.Instance():GetMemberInfoByRoleId(heroProp.id)
  if nil == memberInfo then
    return false
  end
  local tbl = GangUtility.GetAuthority(memberInfo.duty)
  if tbl.canActivatePVE == false then
    Toast(textRes.GangDungeon[1])
    return false
  end
  return true
end
def.method("=>", "boolean").CheckValidChangeTime = function(self)
  local timestamp = self:GetRecentlyOpenTimestamp()
  if timestamp == -1 then
    return true
  end
  local ChangeBeforeStartMinutes = GangDungeonUtils.GetConstant("ChangeBeforeStartMinutes")
  local curTime = _G.GetServerTime()
  local lastValidChangTime = timestamp - ChangeBeforeStartMinutes * 60
  if curTime <= lastValidChangTime then
    return true
  else
    local activityName = self:GetActivityName()
    Toast(textRes.GangDungeon[51]:format(activityName, ChangeBeforeStartMinutes))
    return false
  end
end
def.method("table").SetOpenDateTime = function(self, weekDateTime)
  print("SetOpenDateTime wday, hour, min", weekDateTime.wday, weekDateTime.hour, weekDateTime.min)
  GangDungeonProtocol.CSetStartTimeReq(weekDateTime)
end
def.method().ResetOpenDateTime = function(self)
end
def.method("=>", "table").GetOpenDateTime = function(self)
  if self.m_openTimestamp == nil or self.m_openTimestamp:eq(0) then
    return nil
  end
  local t = AbsoluteTimer.GetServerTimeTable(self.m_openTimestamp:ToNumber())
  return t
end
def.method("userdata").SetOpenTimestamp = function(self, timestamp)
  self.m_openTimestamp = timestamp
  self:RemoveDungeonOpenTimer()
  if timestamp and not timestamp:eq(0) then
    local curTime = GetServerTime()
    local leftTime = timestamp:ToNumber() - curTime
    if leftTime > 0 then
      self.m_dungeonOpenTimer = AbsoluteTimer.AddListener(0, 0, GangDungeonModule.OnDungeonOpen, self, leftTime)
    end
  end
end
def.method().RemoveDungeonOpenTimer = function(self)
  if self.m_dungeonOpenTimer ~= 0 then
    AbsoluteTimer.RemoveListener(self.m_dungeonOpenTimer)
    self.m_dungeonOpenTimer = 0
  end
end
def.method("=>", "number").GetRecentlyOpenTimestamp = function(self)
  if self.m_openTimestamp == nil or self.m_openTimestamp:eq(0) then
    return -1
  end
  return self.m_openTimestamp:ToNumber()
end
def.method("=>", "number").GetPrepareEndTimestamp = function(self)
  if self.m_dungeonStage ~= GangDungeonModule.DungeonStage.STG_PREPARE then
    return -1
  end
  return self.m_stageEndTime:ToNumber()
end
def.method("=>", "number").GetTimeoutEndTimestamp = function(self)
  if self.m_openTimestamp == nil or self.m_openTimestamp:eq(0) then
    return -1
  end
  local ActivityMinutes = GangDungeonUtils.GetConstant("ActivityMinutes")
  local openTimestamp = self.m_openTimestamp:ToNumber()
  local endTime = openTimestamp + ActivityMinutes * 60
  return endTime
end
def.method("=>", "boolean").HasSetOpenTime = function(self)
  return self:GetRecentlyOpenTimestamp() ~= -1
end
def.method("=>", "boolean").IsDungeonOpen = function(self)
  if self:IsDungeonClose() then
    return false
  end
  local openTimestamp = self:GetRecentlyOpenTimestamp()
  if openTimestamp == -1 then
    return false
  end
  local curTime = _G.GetServerTime()
  return openTimestamp <= curTime
end
def.method("=>", "boolean").IsDungeonClose = function(self)
  local openTimestamp = self:GetRecentlyOpenTimestamp()
  if openTimestamp == -1 then
    return false
  end
  if self:GetDungeonStage() == GangDungeonModule.DungeonStage.STG_FINISHED then
    return true
  end
  local ActivityMinutes = GangDungeonUtils.GetConstant("ActivityMinutes")
  local endTime = openTimestamp + ActivityMinutes * 60
  local curTime = _G.GetServerTime()
  return endTime <= curTime
end
def.method("=>", "number").GetResetWDay = function(self)
  return OpenTimeHelper.Instance():GetResetDateTime().wday
end
def.method("=>", "number").GetOpenTimeLeftResetTimes = function(self)
  return 1
end
def.method("=>", "number").GetOpenTimeLeftChangeTimes = function(self)
  local ModifyTimes = GangDungeonUtils.GetConstant("ModifyTimes")
  local leftTimes = ModifyTimes - self.m_setTimes
  return math.max(leftTimes, 0)
end
def.method("=>", "boolean").GoToDungeonEntry = function(self)
  if not gmodule.moduleMgr:GetModule(ModuleId.GANG):HasGang() then
    local activityName = self:GetActivityName()
    local text = textRes.GangDungeon[24]:format(activityName)
    Toast(text)
    return false
  end
  if not GangDungeonModule.Instance():IsDungeonOpen() then
    local ActivityInterface = require("Main.activity.ActivityInterface")
    local activityId = GangDungeonModule.Instance():GetActivityId()
    local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
    local activityName = activityCfg and activityCfg.activityName or "$activity_name"
    if GangDungeonModule.Instance():IsDungeonClose() then
      Toast(textRes.GangDungeon[18]:format(activityName))
    else
      Toast(textRes.GangDungeon[31]:format(activityName))
    end
    return false
  end
  local teamData = require("Main.Team.TeamData").Instance()
  local isNotTmpLeave = teamData:GetStatus() ~= require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_LEAVE
  if teamData:HasTeam() and not teamData:MeIsCaptain() and isNotTmpLeave then
    Toast(textRes.Hero[46])
    return false
  end
  if self:IsInGangDungeon() then
    Toast(textRes.GangDungeon[35])
    return false
  end
  local HeroBehaviorDefine = require("Main.Hero.HeroBehaviorDefine")
  if not HeroBehaviorDefine.CanTransport2TargetState(RoleState.GANG_DUNGEON) then
    Toast(textRes.GangDungeon[20])
    return false
  end
  local npcid = GangDungeonUtils.GetConstant("ENTRY_NPC_ID")
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_NPC, {npcid})
  return true
end
def.method("=>", "boolean").EnterDungeon = function(self)
  local activityId = self:GetActivityId()
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  local heroProp = _G.GetHeroProp()
  if self.m_cond and heroProp.level < activityCfg.levelMin then
    Toast(string.format(textRes.activity[383], activityCfg.levelMin))
    return false
  end
  local joinTime = GangData.Instance():GetHeroJoinTimestamp()
  local curTime = _G.GetServerTime()
  local interval = curTime - joinTime
  local NeedJoinHours = GangDungeonUtils.GetConstant("NeedJoinHours")
  if self.m_cond and interval < NeedJoinHours * 3600 then
    print(string.format("joinTime:%s curTime:%s", tostring(joinTime), tostring(curTime)))
    Toast(textRes.GangDungeon[26]:format(NeedJoinHours))
    return false
  end
  GangDungeonProtocol.CEnterFactionPVEMapReq()
  return true
end
def.method("=>", "boolean").LeaveDungeon = function(self)
  GangDungeonProtocol.CLeaveFactionPVEMapReq()
  return true
end
def.method("=>", "number").GetPrepareSceneRoleNums = function(self)
  return self.m_preapreRoleNum
end
def.method("number", "=>", "boolean").IsGangDungeonMap = function(self, mapId)
  return self:IsPrepareMap(mapId) or self:IsActivityMap(mapId)
end
def.method("number", "=>", "boolean").IsPrepareMap = function(self, mapId)
  return GangDungeonUtils.GetConstant("PREPARE_MAP_ID") == mapId
end
def.method("number", "=>", "boolean").IsActivityMap = function(self, mapId)
  return GangDungeonUtils.GetConstant("ACTIVITY_MAP_ID") == mapId
end
def.method("=>", "boolean").IsInGangDungeon = function(self)
  return self.m_inGangDungeon
end
def.method("=>", "boolean").IsInPrepareMap = function(self)
  local mapId = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapId()
  return self:IsPrepareMap(mapId)
end
def.method("=>", "boolean").IsInActivityMap = function(self)
  local mapId = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapId()
  return self:IsActivityMap(mapId)
end
def.method("=>", "number").GetActivityId = function(self)
  return GangDungeonUtils.GetConstant("ACTIVITY_ID")
end
def.method("=>", "string").GetActivityName = function(self)
  local activityId = self:GetActivityId()
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  local activityName = activityCfg and activityCfg.activityName or "$activity_name"
  return activityName
end
def.method("=>", "number").GetCostGangMoney = function(self)
  return GangDungeonUtils.GetConstant("CostFactionMoney")
end
def.method("=>", "boolean").IsGangMoneyEnough = function(self)
  if not self.m_cond then
    return true
  end
  local info = GangData.Instance():GetGangBasicInfo()
  return info.money >= self:GetCostGangMoney()
end
def.method("=>", "boolean").IsGangMoneyEnoughForMaintain = function(self)
  local data = require("Main.Gang.data.GangData").Instance()
  local gangInfo = data:GetGangBasicInfo()
  if not gangInfo then
    return false
  end
  local curTotalMaintainCost = GangUtility.GetGangMaintainceCost()
  local costFund = self:GetCostGangMoney() + curTotalMaintainCost
  local gangFund = gangInfo.money
  return costFund <= gangFund
end
def.method("=>", "number").GetRequiredGangCreateHours = function(self)
  return GangDungeonUtils.GetConstant("NeedJoinHours")
end
def.method("=>", "boolean").IsGangCreateTimeSatisfy = function(self)
  if not self.m_cond then
    return true
  end
  local info = GangData.Instance():GetGangBasicInfo()
  local curTime = _G.GetServerTime()
  local requireSeconds = self:GetRequiredGangCreateHours() * 3600
  local requireMinTime = info.createTime + requireSeconds
  return curTime > requireMinTime
end
def.method("=>", "number").GetDungeonStage = function(self)
  return self.m_dungeonStage
end
def.method("=>", "userdata").GetStageEndTime = function(self)
  return self.m_stageEndTime
end
def.method("=>", "number").GetStageEndLeftSeconds = function(self)
  local endTime = self:GetStageEndTime()
  if endTime == nil then
    return 0
  end
  endTime = endTime:ToNumber()
  local curTime = _G.GetServerTime()
  return math.max(0, endTime - curTime)
end
def.method("=>", "table").GetPersonalGoals = function(self)
  if self.m_personalGoals == nil then
    self:InitPersonalGoals()
  end
  return self.m_personalGoals
end
def.method().InitPersonalGoals = function(self)
  local allCfgs = GangDungeonUtils.GetAllMonsterGoalCfgs()
  self.m_personalGoals = {}
  for i, v in ipairs(allCfgs) do
    local goal = {
      monsterId = v.monsterId,
      curNum = 0,
      total = v.personGoal
    }
    table.insert(self.m_personalGoals, goal)
  end
end
def.method("=>", "number").GetPersonalGoalRound = function(self)
  return self.m_personalGoalRound
end
def.method("=>", "number").GetClampedPersonalGoalRound = function(self)
  local PersonGoalCount = GangDungeonUtils.GetConstant("PersonGoalCount")
  return MathHelper.Clamp(self.m_personalGoalRound, 1, PersonGoalCount)
end
def.method("=>", "boolean").HasPersonalGoalAllRoundFinished = function(self)
  local maxRound = GangDungeonUtils.GetConstant("PersonGoalCount")
  local round = self:GetPersonalGoalRound()
  if maxRound > round then
    return false
  end
  if maxRound < round then
    return true
  end
  local goals = self:GetPersonalGoals()
  for i, v in ipairs(goals) do
    if v.curNum < v.total then
      return false
    end
  end
  return true
end
def.method("=>", "table").GetGangGoals = function(self)
  if self.m_gangGoals == nil then
    self:InitGangGoals()
  end
  return self.m_gangGoals
end
def.method().InitGangGoals = function(self)
  local allCfgs = GangDungeonUtils.GetAllMonsterGoalCfgs()
  self.m_gangGoals = {}
  local isFinished = self:GetDungeonStage() > GangDungeonModule.DungeonStage.STG_KILL_MONSTER
  for i, v in ipairs(allCfgs) do
    local goal = {
      monsterId = v.monsterId,
      curNum = 0,
      total = v.factionGoal
    }
    if isFinished then
      goal.curNum = goal.total
    end
    table.insert(self.m_gangGoals, goal)
  end
end
def.method("=>", "table").GetBossGoals = function(self)
  if self.m_bossGoals == nil then
    self:InitBossGoals()
  end
  return self.m_bossGoals
end
def.method().InitBossGoals = function(self)
  local allCfgs = GangDungeonUtils.GetAllBossGoalCfgs()
  self.m_bossGoals = {}
  for i, v in ipairs(allCfgs) do
    local goal = {
      monsterId = v.bossId,
      curNum = 0,
      total = v.bossNumber
    }
    table.insert(self.m_bossGoals, goal)
  end
end
def.method("=>", "number").GetSelfParticipateLeftTimes = function(self)
  local totalTimes = GangDungeonUtils.GetConstant("ParticipateTimes") or 0
  local participateTimes = GangDungeonPlayerData.Instance():GetParticipateTimes()
  return math.max(0, totalTimes - participateTimes)
end
def.method("number").SetActivateTimes = function(self, activateTimes)
  self.m_activateTimes = activateTimes
end
def.method("number").EvalSetTimes = function(self, setTimes)
  self.m_setTimes = setTimes
end
def.method("number").SetDungeonStage = function(self, stage)
  self.m_lastDungeonStage = self.m_dungeonStage
  self.m_dungeonStage = stage
end
def.method("userdata").SetStageEndTime = function(self, endTime)
  self.m_stageEndTime = endTime
end
def.method("table", "number").SetPersonalGoals = function(self, goals, round)
  if self.m_personalGoals == nil then
    self:InitPersonalGoals()
  end
  for i, v in ipairs(self.m_personalGoals) do
    v.curNum = goals[v.monsterId] or 0
  end
  self.m_personalGoalRound = round
end
def.method("table").SetGangGoals = function(self, goals)
  if self.m_gangGoals == nil then
    self:InitGangGoals()
  end
  for i, v in ipairs(self.m_gangGoals) do
    v.curNum = goals[v.monsterId] or 0
  end
end
def.method("table").SetBossGoals = function(self, goals)
  if self.m_bossGoals == nil then
    self:InitBossGoals()
  end
  for i, v in ipairs(self.m_bossGoals) do
    v.curNum = goals[v.monsterId] or 0
  end
end
def.method("number").SetPrepareRoleNum = function(self, roleNum)
  self.m_preapreRoleNum = roleNum
end
def.method("=>", "number").GetActivateTimes = function(self)
  return self.m_activateTimes
end
def.method("=>", "number").GetTotalActivateTimes = function(self)
  return GangDungeonUtils.GetConstant("ActivateTimes")
end
def.method("=>", "boolean").HaveLeftActivateTimes = function(self)
  return self.m_activateTimes < self:GetTotalActivateTimes()
end
def.method("number").OnEnterGangDungeon = function(self, mapId)
  gmodule.moduleMgr:GetModule(ModuleId.HERO):SetState(_G.RoleState.GANG_DUNGEON)
  self.m_inGangDungeon = true
  Event.DispatchEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.EnterGangDungeon, nil)
  self:UpdateGangMapUI(mapId)
end
def.method().OnLeaveGangDungeon = function(self)
  gmodule.moduleMgr:GetModule(ModuleId.HERO):RemoveState(_G.RoleState.GANG_DUNGEON)
  self.m_inGangDungeon = false
  self.m_preapreRoleNum = 0
  Event.DispatchEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.LeaveGangDungeon, nil)
  local CommonActivityPanel = require("GUI.CommonActivityPanel")
  CommonActivityPanel.Instance():HidePanel(CommonActivityPanel.ActivityType.GANG_DUNGEON)
  require("Main.GangDungeon.ui.GangDungeonActivityTip").Instance():DestroyPanel()
end
def.method("number", "number").OnChangeGangDeungeonMap = function(self, mapId, lastMapId)
  Event.DispatchEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.ChangeGangDungeonMap, nil)
  self:UpdateGangMapUI(mapId)
end
def.method("number").UpdateGangMapUI = function(self, mapId)
  if self:IsPrepareMap(mapId) then
    require("Main.GangDungeon.ui.PrepareCountDownPanel").Instance():ShowPanel()
  end
  if self:IsActivityMap(mapId) then
    require("Main.GangDungeon.ui.GangDungeonGoalPanel").Instance():ShowPanel()
  end
  local TeamUtils = require("Main.Team.TeamUtils")
  local CommonActivityPanel = require("GUI.CommonActivityPanel")
  CommonActivityPanel.Instance():ShowActivityPanel(true, true, function()
    TeamUtils.JoinTeam()
  end, nil, function()
    if TeamUtils.CheckIfSelfRestrictedInTeam() then
      return
    end
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    local desc
    if self:IsInPrepareMap() then
      desc = textRes.Common[250]
    else
      desc = textRes.GangDungeon[25]
    end
    CommonConfirmDlg.ShowConfirm("", desc, function(s)
      if s == 1 then
        self:LeaveDungeon()
      end
    end, nil)
  end, nil, false, CommonActivityPanel.ActivityType.GANG_DUNGEON)
  require("Main.GangDungeon.ui.GangDungeonActivityTip").Instance():ShowPanel()
end
def.method().OnFeatureStatusChange = function(self)
  local isOpen = self:IsFeatureOpen()
  local activityId = self:GetActivityId()
  if isOpen then
    ActivityInterface.Instance():removeCustomCloseActivity(activityId)
  else
    ActivityInterface.Instance():addCustomCloseActivity(activityId)
    Event.DispatchEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.FeatureClose, nil)
  end
  local npcid = GangDungeonUtils.GetConstant("ENTRY_NPC_ID")
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {npcid = npcid, show = isOpen})
end
def.method().OnEnterDungeonService = function(self)
  self:EnterDungeon()
end
def.method().OnDungeonOpen = function(self)
  local activityId = self:GetActivityId()
  ActivityInterface.Instance():displayActivityTip(activityId, true)
  self:SendDungeonOpenMsgToGangChannel()
end
def.method().SendDungeonOpenMsgToGangChannel = function(self)
  if not self:IsOpen() then
    return
  end
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local link = string.format("<a href='btn_joinGangDungeon' id=btn_joinGangDungeon><font color=#%s><u>[%s]</u></font></a>", link_defalut_color, textRes.GangDungeon[30])
  local content = string.format("%s%s", textRes.GangDungeon[28], link)
  ChatModule.Instance():SendNoteMsg(content, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
end
def.override().OnReset = function(self)
  self.m_inGangDungeon = false
  self:RemoveDungeonOpenTimer()
  self:ResetActivityData()
  Event.DispatchEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.ActivityReset, nil)
end
def.method().ResetActivityData = function(self)
  GangDungeonPlayerData.Instance():Clear()
  self.m_activateTimes = 0
  self:ResetActivateData()
end
def.method().ResetActivateData = function(self)
  self.m_setTimes = 0
  self.m_resetTimes = 0
  self.m_dungeonStage = -1
  self.m_lastDungeonStage = -1
  self.m_openTimestamp = nil
  self.m_personalGoals = nil
  self.m_personalGoalRound = 1
  self.m_gangGoals = nil
  self.m_bossGoals = nil
  self.m_preapreRoleNum = 0
end
def.method("userdata").InviteGang = function(self, gangId)
end
def.method("userdata").AcceptInvitation = function(self, gangId)
end
def.method("userdata").RefuseInvitation = function(self, gangId)
end
def.static("table", "table").OnMainUIReady = function(params, context)
  if not instance:IsOpen() then
    return
  end
  if instance:IsDungeonOpen() then
    local preapreEndTime = instance:GetPrepareEndTimestamp()
    local curTime = _G.GetServerTime()
    if preapreEndTime > curTime then
      instance:SendDungeonOpenMsgToGangChannel()
    end
  end
end
def.static("table", "table").OnEnterWorld = function(params, context)
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  instance:Reset()
end
def.static("table", "table").OnMapChange = function(params, context)
  local mapId, lastMapId = params[1], params[2]
  local self = instance
  if self:IsInGangDungeon() then
    if self:IsGangDungeonMap(mapId) then
      self:OnChangeGangDeungeonMap(mapId, lastMapId)
    else
      self:OnLeaveGangDungeon()
    end
  elseif self:IsGangDungeonMap(mapId) then
    self:OnEnterGangDungeon(mapId)
  end
end
def.static("table", "table").OnNPCService = function(params, context)
  local serviceID = params[1]
  local GANG_DUNGEON_ENTER_DUNGEON_SERVICE_ID = GangDungeonUtils.GetConstant("ENTER_DUNGEON_SERVICE_ID")
  if serviceID == GANG_DUNGEON_ENTER_DUNGEON_SERVICE_ID then
    instance:OnEnterDungeonService()
  end
end
def.static("table", "table").OnActivityTodo = function(params, context)
  local activityId = params[1]
  local selfActivityId = instance:GetActivityId()
  if activityId ~= selfActivityId then
    return
  end
  instance:OpenMainPanel()
end
def.static("table", "table").OnActivityReset = function(params, context)
  local activityId = params[1]
  local selfActivityId = instance:GetActivityId()
  if activityId ~= selfActivityId then
    return
  end
  instance:ResetActivityData()
end
def.static("table", "table").OnChatBtnClick = function(params, context)
  local id = params.id
  if string.sub(id, 1, #"joinGangDungeon") == "joinGangDungeon" then
    instance:GoToDungeonEntry()
  elseif string.sub(id, 1, #"viewGangDungeon") == "viewGangDungeon" then
    instance:OpenMainPanel()
  end
end
def.static("table", "table").OnDungeonStageChanged = function(params, context)
  if instance:GetDungeonStage() == GangDungeonModule.DungeonStage.STG_BOSS_COUNTDOWN then
    GangDungeonModule.OnBossAppearCountDown()
  elseif instance:GetDungeonStage() == GangDungeonModule.DungeonStage.STG_KILL_BOSS then
    if instance.m_lastDungeonStage == GangDungeonModule.DungeonStage.STG_BOSS_COUNTDOWN then
      GangDungeonModule.OnBossAppear()
    end
  elseif instance:GetDungeonStage() == GangDungeonModule.DungeonStage.STG_FINISHED and instance:HaveLeftActivateTimes() then
    instance:ResetActivateData()
    Event.DispatchEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.OpenTimeChanged, nil)
  end
end
def.static("table", "table").OnFunctionOpenInit = function(params, context)
  instance:OnFeatureStatusChange()
end
def.static("table", "table").OnFunctionOpenChange = function(params, context)
  if params and params.feature == GangDungeonModule.MODULE_FEATURE then
    instance:OnFeatureStatusChange()
  end
end
def.static("=>", "boolean").CanShowActivityTip = function()
  if not instance:IsOpen() then
    return false
  end
  if not instance:IsDungeonOpen() then
    return false
  end
  return true
end
def.static().OnBossAppearCountDown = function()
  if not instance:IsInGangDungeon() then
    return
  end
  local GangModule = require("Main.Gang.GangModule")
  GangModule.ShowInGangChannel(textRes.GangDungeon[54])
end
def.static().OnBossAppear = function()
  if not instance:IsInGangDungeon() then
    return
  end
  local GangModule = require("Main.Gang.GangModule")
  GangModule.ShowInGangChannel(textRes.GangDungeon[50])
  local effectId = GangDungeonUtils.GetConstant("BossAppearEffect")
  if effectId then
    local effectCfg = GetEffectRes(effectId)
    if effectCfg then
      GUIFxMan.Instance():Play(effectCfg.path, "GangDungeonBossAppear", 0, 0, -1, false)
    end
  end
end
return GangDungeonModule.Commit()
