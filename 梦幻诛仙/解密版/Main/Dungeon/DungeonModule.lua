local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
require("Main.module.ModuleId")
local DungeonModule = Lplus.Extend(ModuleBase, "DungeonModule")
local SoloDungeonMgr = require("Main.Dungeon.SoloDungeonMgr")
local TeamDungeonMgr = require("Main.Dungeon.TeamDungeonMgr")
local DungeonType = require("consts.mzm.gsp.instance.confbean.InstanceType")
local DungeonConst = require("netio.protocol.mzm.gsp.instance.InstanceConst")
local DungeonUtils = require("Main.Dungeon.DungeonUtils")
local TeamDungeonType = require("consts.mzm.gsp.instance.confbean.InstanceDisType")
local ActivityInterface = require("Main.activity.ActivityInterface")
local def = DungeonModule.define
local _instance
def.const("table").DungeonState = {
  OUT = 0,
  SOLO = DungeonType.SINGLE,
  TEAM = DungeonType.TEAM,
  FACTION = DungeonType.FACTION,
  GLOBAL = DungeonType.GLOBAL
}
def.field("number").State = 0
def.field("number").CurDungeon = 0
def.field("table").soloMgr = nil
def.field("table").teamMgr = nil
def.field("number").singleFailTimes = 0
def.field("table").singleDungeonInfo = function()
  return {}
end
def.field("table").mutilDungeonInfo = function()
  return {}
end
def.static("=>", DungeonModule).Instance = function()
  if _instance == nil then
    _instance = DungeonModule()
    _instance.m_moduleId = ModuleId.DUNGEON
  end
  return _instance
end
def.override().Init = function(self)
  self.soloMgr = SoloDungeonMgr()
  self.soloMgr:Init()
  self.teamMgr = TeamDungeonMgr()
  self.teamMgr:Init()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.instance.SSynInstanceInfo", DungeonModule.onSSynInstanceInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.instance.SSynSingleInstanceInfo", DungeonModule.onSSynSingleInstanceInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.instance.SUpdateSingleInfo", DungeonModule.onUpdateSingleInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.instance.STeamInstanceProcess", DungeonModule.onUpdateMultiInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.instance.SEnterInstanceRes", DungeonModule.onEnterDungeon)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.instance.SLeaveInstanceRes", DungeonModule.onLeaveDungeon)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.instance.SInstanceNormalResult", DungeonModule.onCommonResult)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, DungeonModule.onActivityTodo)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, DungeonModule.OnActivityReset)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, TeamDungeonMgr.OnFeatureChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, TeamDungeonMgr.OnFeatureInit)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.instance.SSingleBossAward", SoloDungeonMgr.onBossAward)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, SoloDungeonMgr.onEndFight)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, SoloDungeonMgr.onSoloDungeonService)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_TARGET_SERVICE, SoloDungeonMgr.onSoloDungeonService)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, TeamDungeonMgr.onTeamDungeonService)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_TARGET_SERVICE, TeamDungeonMgr.onTeamDungeonTargetService)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.instance.SSynAwardItemInfo", TeamDungeonMgr.onDungeonReward)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.instance.SGetOrRefuseItemRes", TeamDungeonMgr.onSGetOrRefuseItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.instance.SSynGetAwardBoxItemRes", TeamDungeonMgr.onRollRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.instance.SSynInstanceLeaveTimer", TeamDungeonMgr.onLeaveTimer)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.instance.STeamInstanceCurProcess", TeamDungeonMgr.UpdateDungeonTip)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.instance.SBrocastTeamInstanceItem", TeamDungeonMgr.onDungeonRewardBroadCast)
  ModuleBase.Init(self)
end
def.override().OnReset = function(self)
  self.soloMgr:Reset()
  self.teamMgr:Reset()
  self.singleFailTimes = 0
  self.singleDungeonInfo = {}
  self.mutilDungeonInfo = {}
  self.State = 0
  self.CurDungeon = 0
end
def.method("=>", "boolean").IsInDungeon = function(self)
  return self.CurDungeon > 0
end
def.static("table", "table").OnActivityReset = function(p1, p2)
  local activityId = p1[1]
  local soloDungeonActivityId = DungeonUtils.GetDungeonConst().SoloDungeonActivityId
  if activityId == soloDungeonActivityId then
    local myLevel = require("Main.Hero.Interface").GetBasicHeroProp().level
    _instance.singleFailTimes = 0
    for k, v in pairs(_instance.singleDungeonInfo) do
      v.curProcess = 1
      v.finishTimes = 0
      local dungeonCfg = DungeonUtils.GetDungeonCfg(k)
      if myLevel >= dungeonCfg.level and myLevel < dungeonCfg.closeLevel then
        v.open = true
      else
        v.open = false
      end
    end
    return
  end
  for k, v in pairs(DungeonUtils.ActivityIdToTeamDungeonId()) do
    if activityId == k then
      local dungenInfo = _instance.mutilDungeonInfo[v[2]]
      if dungenInfo == nil then
        return
      end
      local activityInterface = ActivityInterface.Instance()
      local teamDungeonCfg = DungeonUtils.GetTeamDungeonCfg(dungenInfo.cfgId)
      local activityInfo = activityInterface:GetActivityInfo(teamDungeonCfg.activityid)
      dungenInfo.finishTimes = activityInfo.count
      dungenInfo.toProcess = 0
      local myLevel = require("Main.Hero.Interface").GetBasicHeroProp().level
      local dungeonCfg = DungeonUtils.GetDungeonCfg(dungenInfo.cfgId)
      local min = dungeonCfg.level
      local max = 0 < dungeonCfg.closeLevel and dungeonCfg.closeLevel or math.huge
      if myLevel >= min and myLevel < max then
        dungenInfo.open = true
      else
        dungenInfo.open = false
      end
      return
    end
  end
end
def.static("table").onSSynInstanceInfo = function(p)
  print("onSSynInstanceInfo")
  local activityInterface = ActivityInterface.Instance()
  for k, v in ipairs(p.teamInstances) do
    local teamDungeonCfg = DungeonUtils.GetTeamDungeonCfg(v.instanceCfgid)
    local info = {}
    info.cfgId = v.instanceCfgid
    local activityInfo = activityInterface:GetActivityInfo(teamDungeonCfg.activityid)
    if activityInfo then
      info.finishTimes = activityInfo.count
    else
      info.finishTimes = 0
    end
    info.toProcess = v.toProcess
    info.open = v.sign == DungeonConst.ON
    _instance.mutilDungeonInfo[info.cfgId] = info
  end
end
def.static("table").onSSynSingleInstanceInfo = function(p)
  print("onSSynSingleInstanceInfo")
  for k, v in ipairs(p.singleInstanceInfo) do
    local info = {}
    info.highProcess = v.highProcess
    info.cfgId = v.instanceCfgid
    info.curProcess = v.curProcess
    info.finishTimes = v.finishTimes
    info.open = v.sign == DungeonConst.ON
    _instance.singleDungeonInfo[info.cfgId] = info
  end
  _instance.singleFailTimes = p.singleFailTime
end
def.static("table").onUpdateSingleInfo = function(p)
  print("onUpdateSingleInfo")
  local cfgId = p.singleInfo.instanceCfgid
  local oldInfo = _instance.singleDungeonInfo[cfgId]
  local oldFinishTimes = oldInfo and oldInfo.finishTimes or 0
  local oldProcess = oldInfo and oldInfo.curProcess or 1
  _instance.singleDungeonInfo[cfgId] = {}
  _instance.singleDungeonInfo[cfgId].highProcess = p.singleInfo.highProcess
  _instance.singleDungeonInfo[cfgId].cfgId = cfgId
  _instance.singleDungeonInfo[cfgId].curProcess = p.singleInfo.curProcess
  _instance.singleDungeonInfo[cfgId].finishTimes = p.singleInfo.finishTimes
  _instance.singleDungeonInfo[cfgId].open = p.singleInfo.sign == DungeonConst.ON
  _instance.singleFailTimes = p.failTime
  Event.DispatchEvent(ModuleId.DUNGEON, gmodule.notifyId.Dungeon.SOLO_DUNGEON_SAODANG, nil)
  if oldFinishTimes == 0 and _instance.singleDungeonInfo[cfgId].finishTimes == 1 then
    Toast(textRes.Dungeon[8])
    SafeLuckDog(function()
      return true
    end)
  end
  if _instance.State == DungeonModule.DungeonState.SOLO then
    _instance.soloMgr:OnKillOneMonster(oldProcess < p.singleInfo.curProcess, oldProcess)
  end
end
def.static("table").onUpdateMultiInfo = function(p)
  local info = _instance.mutilDungeonInfo[p.teamInstanceInfo.instanceCfgid] or {}
  info.cfgId = p.teamInstanceInfo.instanceCfgid
  local teamDungeonCfg = DungeonUtils.GetTeamDungeonCfg(info.cfgId)
  local activityInterface = ActivityInterface.Instance()
  local activityInfo = activityInterface:GetActivityInfo(teamDungeonCfg.activityid)
  if activityInfo then
    info.finishTimes = activityInfo.count
  else
    info.finishTimes = 0
  end
  info.toProcess = p.teamInstanceInfo.toProcess
  info.open = p.teamInstanceInfo.sign == DungeonConst.ON
  _instance.mutilDungeonInfo[info.cfgId] = info
  if _instance.State == DungeonModule.DungeonState.TEAM then
    _instance.teamMgr:OnProcessUpdate()
  end
end
def.static("table").onEnterDungeon = function(p)
  print("----------------onEnterDungeon", onEnterDungeon)
  _instance.State = p.instanceType
  _instance.CurDungeon = p.instanceCfgid
  if p.instanceType == DungeonType.SINGLE then
    if gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole then
      gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole:SetState(RoleState.SOLODUNGEON)
    end
    _instance.soloMgr:OnEnterSoloDungeon()
  elseif p.instanceType == DungeonType.TEAM then
    if gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole then
      gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole:SetState(RoleState.TEAMDUNGEON)
    end
    _instance.teamMgr:OnEnterTeamDungeon()
  end
  require("ProxySDK.ECMSDK").GSDKStart(0)
end
def.static("table").onLeaveDungeon = function(p)
  print("onLeaveDungeon", p.instanceType)
  _instance.State = DungeonModule.DungeonState.OUT
  _instance.CurDungeon = 0
  if p.instanceType == DungeonType.SINGLE then
    if gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole then
      gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole:RemoveState(RoleState.SOLODUNGEON)
    end
    _instance.soloMgr:OnLeaveSoloDungeon()
  elseif p.instanceType == DungeonType.TEAM then
    if gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole then
      gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole:RemoveState(RoleState.TEAMDUNGEON)
    end
    _instance.teamMgr:OnLeaveTeamDungeon()
  end
  require("ProxySDK.ECMSDK").GSDKEnd()
end
def.static("table", "table").onActivityTodo = function(p1, p2)
  for k, v in pairs(DungeonUtils.ActivityIdToTeamDungeonId()) do
    if p1[1] == k then
      local TeamNpc = DungeonUtils.GetDungeonConst().TeamServiceNpc
      local ServiceType = require("consts.mzm.gsp.npc.confbean.ServiceType")
      Event.DispatchEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_GOTO_TARGET_SERVICE, {
        TeamNpc,
        ServiceType.Function,
        v
      })
      return
    end
  end
  local soloDungeonActivityId = DungeonUtils.GetDungeonConst().SoloDungeonActivityId
  if p1[1] == soloDungeonActivityId then
    local SoloNpc = DungeonUtils.GetDungeonConst().SoloServiceNpc
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {SoloNpc})
  end
end
def.method().LeaveDungeon = function(self)
  local leave = require("netio.protocol.mzm.gsp.instance.CLeaveInstanceReq").new()
  gmodule.network.sendProtocol(leave)
end
def.method("number", "=>", "table").GetSoloDungeonInfo = function(self, dungeonId)
  return self.singleDungeonInfo[dungeonId]
end
def.method("=>", "boolean").IsSingleDungeonAllFinish = function(self)
  local opend = 0
  local finished = 0
  for k, v in pairs(self.singleDungeonInfo) do
    if v.open then
      opend = opend + 1
    end
    if 0 < v.finishTimes then
      finished = finished + 1
    end
  end
  return opend ~= 0 and opend == finished
end
def.method("=>", "boolean").IsSingleDungeonAnyFinish = function(self)
  for k, v in pairs(self.singleDungeonInfo) do
    if v.open and v.finishTimes > 0 then
      return true
    end
  end
  return false
end
def.method("number", "=>", "table").GetTeamDungeonInfo = function(self, dungeonId)
  return self.mutilDungeonInfo[dungeonId]
end
def.method().BossAwardFinish = function(self)
  local bossFinish = require("netio.protocol.mzm.gsp.instance.CTakeSingleBoss").new()
  gmodule.network.sendProtocol(bossFinish)
end
def.static("table").onCommonResult = function(p)
  local result = p.result
  local args = p.args
  local tip
  if result == p.PERSON_COUNT_NOT_ENOUGH then
    tip = textRes.Dungeon[100 + p.PERSON_COUNT_NOT_ENOUGH]
  elseif result == p.LEVEL_NOT_ENOUGH then
    tip = string.format(textRes.Dungeon[100 + p.LEVEL_NOT_ENOUGH], args[1])
  elseif result == p.MEMBER_STATUS_WRONG then
    tip = string.format(textRes.Dungeon[100 + p.MEMBER_STATUS_WRONG], args[1])
  elseif result == p.MEMBER_REFUSE then
    local dungeonCfg = DungeonUtils.GetDungeonCfg(tonumber(args[1]))
    tip = string.format(textRes.Dungeon[100 + p.MEMBER_REFUSE], args[1], dungeonCfg.name)
  elseif result == p.TEAM_LEADER_NOT_HAVE_ITEM then
    local ItemUtils = require("Main.Item.ItemUtils")
    local itemBase = ItemUtils.GetItemBase(tonumber(args[1]))
    if itemBase then
      tip = string.format(textRes.Dungeon[100 + p.TEAM_LEADER_NOT_HAVE_ITEM], itemBase.name)
    end
  elseif result == p.MEMBER_STATUS_OFFLINE then
    tip = string.format(textRes.Dungeon[100 + p.MEMBER_STATUS_OFFLINE], args[1])
  elseif result == p.WAIT_MEMBER_OPERATION then
    tip = textRes.Dungeon[100 + p.WAIT_MEMBER_OPERATION]
  elseif result == p.TEAM_MEMBER_CHANGED then
    tip = textRes.Dungeon[100 + p.TEAM_MEMBER_CHANGED]
  elseif result == p.ENTER_INSTANCE_FAIL then
    tip = textRes.Dungeon[100 + p.ENTER_INSTANCE_FAIL]
    local DungeonAsk = require("Main.Dungeon.ui.DungeonAsk")
    DungeonAsk.CloseAsk()
  elseif result == p.SAO_DANG_CHENG_GONG then
    tip = textRes.Dungeon[100 + p.SAO_DANG_CHENG_GONG]
  elseif result == p.LEAVE_INSTANCE_NOT_AWARD then
    tip = textRes.Dungeon[100 + p.LEAVE_INSTANCE_NOT_AWARD]
  elseif result == p.SINGLE_INSTANCE_FAIL_TIMES_NOT_ENOUGH then
    tip = textRes.Dungeon[100 + p.SINGLE_INSTANCE_FAIL_TIMES_NOT_ENOUGH]
  end
  if tip then
    Toast(tip)
  end
end
def.method("number", "number").UpdateDungeonNum = function(self, activityid, num)
  if self.mutilDungeonInfo then
    for i, v in pairs(self.mutilDungeonInfo) do
      local teamDungeonCfg = DungeonUtils.GetTeamDungeonCfg(i)
      if teamDungeonCfg and teamDungeonCfg.activityid == activityid then
        v.finishTimes = num
        break
      end
    end
  end
end
DungeonModule.Commit()
return DungeonModule
