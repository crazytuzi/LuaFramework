local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local DragonBoatRaceModule = Lplus.Extend(ModuleBase, MODULE_NAME)
local DragonBoatRaceProtocol = require("Main.DragonBoatRace.DragonBoatRaceProtocol")
local DragonBoatRaceData = require("Main.DragonBoatRace.DragonBoatRaceData")
local DragonBoatRaceUtils = require("Main.DragonBoatRace.DragonBoatRaceUtils")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ActivityInterface = require("Main.activity.ActivityInterface")
local LonngBoatCommandType = require("consts.mzm.gsp.lonngboatrace.confbean.LonngBoatCommandType")
local def = DragonBoatRaceModule.define
def.const("table").Command = {
  Up = LonngBoatCommandType.UP,
  Left = LonngBoatCommandType.LEFT,
  Right = LonngBoatCommandType.RIGHT
}
def.const("number").EVENT_ID_NONE = -1
def.field("table").m_allActivities = nil
def.field("number").m_previewActivityId = 0
def.field("number").m_previewRaceId = 0
def.field("table").m_curRace = nil
def.field("userdata").m_syncStartTime = nil
def.field("number").m_syncStartTick = 0
local instance
def.static("=>", DragonBoatRaceModule).Instance = function()
  if instance == nil then
    instance = DragonBoatRaceModule()
    instance.m_moduleId = ModuleId.DRAGON_BOAT_RACE
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, DragonBoatRaceModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, DragonBoatRaceModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, DragonBoatRaceModule.OnActivityTodo)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, DragonBoatRaceModule.OnNPCService)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, DragonBoatRaceModule.OnFunctionOpenInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, DragonBoatRaceModule.OnFunctionOpenChange)
  DragonBoatRaceProtocol.Init()
end
def.method("number", "number").LetTeamMembersShowRuleUI = function(self, activityId, raceId)
  DragonBoatRaceProtocol.CJoinLonngBoatRaceReq(activityId, raceId)
end
def.method().StartRace = function(self)
  local activityId = self.m_previewActivityId
  local canEnter = ActivityInterface.CheckActivityConditionTeamMemberCount(activityId, true)
  if not canEnter then
    return
  end
  local canEnter = ActivityInterface.CheckActivityConditionLevel(activityId, true)
  if not canEnter then
    return
  end
  DragonBoatRaceProtocol.CEntry(activityId, self.m_previewRaceId)
end
def.method().CancelRace = function(self)
  DragonBoatRaceProtocol.CCancelPreview()
end
def.method().ShowRuleUI = function(self)
  require("Main.DragonBoatRace.ui.DragonBoatRaceRulePanel").Instance():ShowPanel()
end
def.method("table").SendControlCommands = function(self, commands)
  local curRace = self:GetCurRace()
  local raceCfgId = curRace:GetRaceCfgId()
  local phaseNo = curRace:GetPhaseNo()
  local round = curRace:GetRound()
  local timesInRound = curRace:GetTimesInRound()
  local commandList = {}
  for i, v in ipairs(commands) do
    table.insert(commandList, v.value)
  end
  DragonBoatRaceProtocol.CSendCommand(raceCfgId, phaseNo, round, timesInRound, commandList)
end
def.method("=>", "table").GetAllRaceActivities = function(self)
  if self.m_allActivities == nil then
    self.m_allActivities = DragonBoatRaceUtils.GetAllRaceActivityCfgs()
  end
  return self.m_allActivities
end
def.method("number", "=>", "table").GetRaceActivityInfo = function(self, activityId)
  local allActivities = self:GetAllRaceActivities()
  return allActivities[activityId]
end
def.method("number", "=>", "boolean").GotoActivityNPC = function(self, activityId)
  local raceActivityInfo = self:GetRaceActivityInfo(activityId)
  if raceActivityInfo == nil then
    warn(string.format("activityId(%d) not belong to DragonBoatRace", activityId))
    return
  end
  if not self:IsOpen(activityId) then
    Toast(textRes.activity[51])
    return false
  end
  local TeamUtils = require("Main.Team.TeamUtils")
  if TeamUtils.CheckIfSelfRestrictedInTeam() then
    return false
  end
  local HeroBehaviorDefine = require("Main.Hero.HeroBehaviorDefine")
  if not HeroBehaviorDefine.CanTransport2TargetState(RoleState.GANG_DUNGEON) then
    Toast(textRes.GangDungeon[20])
    return false
  end
  local npcid = raceActivityInfo.npcId
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_NPC, {npcid})
  return true
end
def.method("number", "=>", "boolean").IsOpen = function(self, activityId)
  local raceActivityInfo = self:GetRaceActivityInfo(activityId)
  if raceActivityInfo == nil then
    warn(string.format("activityId(%d) not belong to DragonBoatRace", activityId))
    return false
  end
  if not _G.IsFeatureOpen(raceActivityInfo.switchId) then
    warn("Feature not open")
    return false
  end
  if not ActivityInterface.Instance():isActivityOpend(activityId) then
    warn("activity not open")
    return false
  end
  return true
end
def.method("table").OnFeatureStatusChange = function(self, activityInfo)
  local isOpen = _G.IsFeatureOpen(activityInfo.switchId)
  local activityId = activityInfo.activityId
  if isOpen then
    ActivityInterface.Instance():removeCustomCloseActivity(activityId)
  else
    ActivityInterface.Instance():addCustomCloseActivity(activityId)
    Event.DispatchEvent(ModuleId.DRAGON_BOAT_RACE, gmodule.notifyId.DragonBoatRace.FeatureClose, nil)
  end
  local npcid = activityInfo.npcId
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {npcid = npcid, show = isOpen})
end
def.method("number", "number").CreateRace = function(self, activityId, raceId)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirmCoundDown("", textRes.DragonBoatRace[1], "", "", 1, 30, function(s)
    if s == 1 then
      self:LetTeamMembersShowRuleUI(activityId, raceId)
    end
  end, nil)
end
def.method("number", "number").SetPreviewInfo = function(self, activityId, raceId)
  self.m_previewActivityId = activityId
  self.m_previewRaceId = raceId
end
def.method("=>", "number").GetPreviewActivityId = function(self)
  return self.m_previewRaceId
end
def.method("=>", "number").GetPreviewRaceId = function(self)
  return self.m_previewRaceId
end
def.method("=>", DragonBoatRaceData).GetCurRace = function(self)
  return self.m_curRace
end
def.method("=>", "userdata").GetMilliServerTime = function(self)
  if self.m_syncStartTime then
    return self.m_syncStartTime + GameUtil.GetTickCount() - self.m_syncStartTick
  end
  return gmodule.moduleMgr:GetModule(ModuleId.SERVER):GetMilliServerTime()
end
def.method("userdata").SetMilliServerTime = function(self, serverTime)
  self.m_syncStartTime = serverTime
  self.m_syncStartTick = GameUtil.GetTickCount()
end
def.method("userdata").InitRace = function(self, myTeamId)
  self.m_curRace = DragonBoatRaceData()
  self.m_curRace:SetMyTeamId(myTeamId)
end
def.method().Clear = function(self)
  self.m_allActivities = nil
  self.m_previewActivityId = 0
  self.m_previewRaceId = 0
  self.m_curRace = nil
  self.m_syncStartTime = nil
  self.m_syncStartTick = 0
end
def.static("table", "table").OnEnterWorld = function(params, context)
  if _G.IsCrossingServer() then
    return
  end
  local curRace = instance:GetCurRace()
  if curRace == nil then
    return
  end
  local myTeamId = require("Main.Team.TeamData").Instance().teamId
  if myTeamId == nil then
    warn("OnEnterWorld: myTeamId is nil")
    return
  end
  curRace:SetMyTeamId(myTeamId)
  require("Main.DragonBoatRace.ui.DragonBoatRaceMainPanel").Instance():ShowPanel()
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  instance:Clear()
end
def.static("table", "table").OnActivityTodo = function(params, context)
  local activityId = params[1]
  local raceActivityInfo = instance:GetRaceActivityInfo(activityId)
  if raceActivityInfo == nil then
    return
  end
  instance:GotoActivityNPC(activityId)
end
def.static("table", "table").OnNPCService = function(params, context)
  local serviceID = params[1]
  local npcId = params[2]
  local allActivities = instance:GetAllRaceActivities()
  for k, v in pairs(allActivities) do
    if v.npcId == npcId and v.joinActivityServiceId == serviceID then
      instance:CreateRace(v.activityId, v.raceId)
      break
    end
  end
end
def.static("table", "table").OnFunctionOpenInit = function(params, context)
  local allActivities = instance:GetAllRaceActivities()
  for k, v in pairs(allActivities) do
    instance:OnFeatureStatusChange(v)
  end
end
def.static("table", "table").OnFunctionOpenChange = function(params, context)
  local allActivities = instance:GetAllRaceActivities()
  for k, v in pairs(allActivities) do
    if v.switchId == params.feature then
      instance:OnFeatureStatusChange(v)
    end
  end
end
return DragonBoatRaceModule.Commit()
