local Lplus = require("Lplus")
local GangDungeonProtocol = Lplus.Class("GangDungeonProtocol")
local GangDungeonModule = Lplus.ForwardDeclare("GangDungeonModule")
local ItemUtils = require("Main.Item.ItemUtils")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local ActivityInterface = require("Main.activity.ActivityInterface")
local GangDungeonUtils = require("Main.GangDungeon.GangDungeonUtils")
local AwardUtils = require("Main.Award.AwardUtils")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local GangDungeonPlayerData = require("Main.GangDungeon.GangDungeonPlayerData")
local def = GangDungeonProtocol.define
local debuglog = function(...)
  local n = select("#", ...)
  local t = {}
  for i = 1, n do
    local v = select(i, ...)
    table.insert(t, tostring(v))
  end
  local message = table.concat(t)
  warn(string.format("<color=#66ccff>%s</color>", message))
end
local setTimeReqHanging
def.static().Init = function()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, GangDungeonProtocol.OnLeaveWorld)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.factionpve.SFactionPVENormalResult", GangDungeonProtocol.OnSFactionPVENormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.factionpve.SStartTimeBrd", GangDungeonProtocol.OnSStartTimeBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.factionpve.SSyncStartTime", GangDungeonProtocol.OnSSyncStartTime)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.factionpve.SFactionPVETimesBrd", GangDungeonProtocol.OnSFactionPVETimesBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.factionpve.SStageBrd", GangDungeonProtocol.OnSStageBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.factionpve.SFactionPVEStageBrd", GangDungeonProtocol.OnSFactionPVEStageBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.factionpve.SSyncSelfKillMonster", GangDungeonProtocol.OnSSyncSelfKillMonster)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.factionpve.SSyncFactionKillMonster", GangDungeonProtocol.OnSSyncFactionKillMonster)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.factionpve.SSyncPlayerCount", GangDungeonProtocol.OnSSyncPlayerCount)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.factionpve.SKillBossAwardNotify", GangDungeonProtocol.OnSKillBossAwardNotify)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.factionpve.SSyncKillBossCountBrd", GangDungeonProtocol.OnSSyncKillBossCountBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.factionpve.SKillBossTimeoutBrd", GangDungeonProtocol.OnSKillBossTimeoutBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.factionpve.SKillBossSucceedBrd", GangDungeonProtocol.OnSKillBossSucceedBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.factionpve.SSelfGoalAwardNotify", GangDungeonProtocol.OnSSelfGoalAwardNotify)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.factionpve.SKillRelatedMonsterBrd", GangDungeonProtocol.OnSKillRelatedMonsterBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.factionpve.SKillBossBrd", GangDungeonProtocol.OnSKillBossBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.factionpve.SFactionGoalAwardNotify", GangDungeonProtocol.OnSFactionGoalAwardNotify)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.factionpve.SSyncParticipateTimes", GangDungeonProtocol.OnSSyncParticipateTimes)
end
def.static("table", "table").OnLeaveWorld = function()
  setTimeReqHanging = nil
end
def.static("table").CSetStartTimeReq = function(datetime)
  local p = require("netio.protocol.mzm.gsp.factionpve.CSetStartTimeReq").new(datetime.wday, datetime.hour, datetime.min)
  gmodule.network.sendProtocol(p)
  setTimeReqHanging = true
end
def.static().CEnterFactionPVEMapReq = function()
  local p = require("netio.protocol.mzm.gsp.factionpve.CEnterFactionPVEMapReq").new()
  gmodule.network.sendProtocol(p)
end
def.static().CLeaveFactionPVEMapReq = function()
  local p = require("netio.protocol.mzm.gsp.factionpve.CLeaveFactionPVEMapReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSStartTimeBrd = function(p)
  if setTimeReqHanging then
    setTimeReqHanging = nil
    Toast(textRes.GangDungeon[27])
  end
  GangDungeonModule.Instance():SetOpenTimestamp(p.start_time / 1000)
  Event.DispatchEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.OpenTimeChanged, nil)
  local GangModule = require("Main.Gang.GangModule")
  local link = string.format("<a href='btn_viewGangDungeon' id=btn_viewGangDungeon><font color=#%s><u>[%s]</u></font></a>", link_defalut_color, textRes.GangDungeon[33])
  local manager_name = p.manager_name or "$manager_name"
  local manager_duty = p.manager_duty or "$manager_duty"
  local content = textRes.GangDungeon[32]:format(manager_duty, manager_name)
  content = string.format("%s%s", content, link)
  GangModule.ShowInGangChannel(content)
end
def.static("table").OnSSyncStartTime = function(p)
  GangDungeonModule.Instance():SetOpenTimestamp(p.start_time / 1000)
  Event.DispatchEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.OpenTimeChanged, nil)
end
def.static("table").OnSFactionPVETimesBrd = function(p)
  local gangDungeonModule = GangDungeonModule.Instance()
  gangDungeonModule:SetActivateTimes(p.activate_times)
  gangDungeonModule:EvalSetTimes(p.set_times)
end
def.static("table").OnSStageBrd = function(p)
end
def.static("table").OnSFactionPVEStageBrd = function(p)
  local gangDungeonModule = GangDungeonModule.Instance()
  gangDungeonModule:SetDungeonStage(p.stage)
  gangDungeonModule:SetStageEndTime(p.end_time / 1000)
  Event.DispatchEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.DungeonStageChanged, {
    stage = p.stage
  })
end
def.static("table").OnSSyncSelfKillMonster = function(p)
  local gangDungeonModule = GangDungeonModule.Instance()
  gangDungeonModule:SetPersonalGoals(p.monsters, p.goal_times + 1)
  Event.DispatchEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.ScheduleOfPersonalsGoalChanged, nil)
end
def.static("table").OnSSyncFactionKillMonster = function(p)
  local gangDungeonModule = GangDungeonModule.Instance()
  gangDungeonModule:SetGangGoals(p.monsters)
  Event.DispatchEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.ScheduleOfGangsGoalChanged, nil)
end
def.static("table").OnSSyncPlayerCount = function(p)
  local gangDungeonModule = GangDungeonModule.Instance()
  gangDungeonModule:SetPrepareRoleNum(p.count)
  Event.DispatchEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.PrepareRoleNumChanged, nil)
end
def.static("table").OnSSyncKillBossCountBrd = function(p)
  local gangDungeonModule = GangDungeonModule.Instance()
  gangDungeonModule:SetBossGoals(p.boss2count)
  Event.DispatchEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.ScheduleOfGangsGoalChanged, nil)
end
def.static("table").OnSKillBossAwardNotify = function(p)
  local bossName = GangDungeonUtils.GetBossName(p.bossid)
  local htmlTexts = AwardUtils.GetHtmlTextsFromAwardBean(p.award, "")
  local awardText = table.concat(htmlTexts, textRes.Common[19])
  local text = textRes.GangDungeon[43]:format(bossName, awardText)
  PersonalHelper.SendOut(text)
end
def.static("table").OnSKillBossTimeoutBrd = function(p)
  local content = textRes.GangDungeon[44]
  Toast(content)
  local GangModule = require("Main.Gang.GangModule")
  GangModule.ShowInGangChannel(content)
end
def.static("table").OnSKillBossSucceedBrd = function(p)
  local content = textRes.GangDungeon[45]
  Toast(content)
  local GangModule = require("Main.Gang.GangModule")
  GangModule.ShowInGangChannel(content)
end
def.static("table").OnSSelfGoalAwardNotify = function(p)
  local htmlTexts = AwardUtils.GetHtmlTextsFromAwardBean(p.award, "")
  local awardText = table.concat(htmlTexts, textRes.Common[19])
  local text = textRes.GangDungeon[46]:format(p.goal_times, awardText)
  PersonalHelper.SendOut(text)
  local effectId = GangDungeonUtils.GetConstant("SelfGoalEffect")
  if effectId then
    local effectCfg = GetEffectRes(effectId)
    if effectCfg then
      local GUIFxMan = require("Fx.GUIFxMan")
      GUIFxMan.Instance():Play(effectCfg.path, "SelfGoalEffect", 0, 0, -1, false)
    end
  end
end
def.static("table").OnSKillRelatedMonsterBrd = function(p)
  local bossName = GangDungeonUtils.GetBossName(p.bossid)
  local monsterName = GangDungeonUtils.GetBossName(p.related_monster)
  local content = textRes.GangDungeon[47]:format(p.leader_name, monsterName, bossName)
  local GangModule = require("Main.Gang.GangModule")
  GangModule.ShowInGangChannel(content)
end
def.static("table").OnSKillBossBrd = function(p)
  if #p.roles < 1 then
    error("invalid roles: #p.roles < 1")
  end
  local GangModule = require("Main.Gang.GangModule")
  local bossName = GangDungeonUtils.GetBossName(p.bossid)
  local captainName = p.roles[1]
  if #p.roles == 1 then
    local content = textRes.GangDungeon[48]:format(captainName, bossName)
    GangModule.ShowInGangChannel(content)
  else
    local memberNames = {}
    for i = 2, #p.roles do
      table.insert(memberNames, p.roles[i])
    end
    local memberNameStr = table.concat(memberNames, textRes.Common.comma)
    local content = textRes.GangDungeon[49]:format(captainName, memberNameStr, bossName)
    GangModule.ShowInGangChannel(content)
  end
end
def.static("table").OnSFactionGoalAwardNotify = function(p)
  local htmlTexts = AwardUtils.GetHtmlTextsFromAwardBean(p.award, "")
  local awardText = table.concat(htmlTexts, textRes.Common[19])
  local text = textRes.GangDungeon[53]:format(awardText)
  PersonalHelper.SendOut(text)
end
def.static("table").OnSSyncParticipateTimes = function(p)
  local playerData = GangDungeonPlayerData.Instance()
  playerData:SetParticipateTimes(p.participate_times)
  playerData:SetLastParticipateTimestamp((p.participate_millis / 1000):ToNumber())
  playerData:SetLastParticipateGangId(p.participate_faction)
  Event.DispatchEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.ParticipateTimesChanged, nil)
end
def.static("table").OnSFactionPVENormalResult = function(p)
  if p.result == p.class.ENTER_FACTIONPVE_MAP__SELF_LOW_LEVEL then
    GangDungeonProtocol.OnSelfLevelTooLowError(p)
  elseif p.result == p.class.ENTER_FACTIONPVE_MAP__TEAM_LOW_LEVEL then
    GangDungeonProtocol.OnTeamMemberLevelTooLowError(p)
  elseif p.result == p.class.ENTER_FACTIONPVE_MAP__SELF_JUST_JOIN then
    GangDungeonProtocol.OnSelfJustJoinError(p)
  elseif p.result == p.class.ENTER_FACTIONPVE_MAP__TEAM_JUST_JOIN then
    GangDungeonProtocol.OnTeamMemberJustJoinError(p)
  elseif p.result == p.class.ENTER_FACTIONPVE_MAP__SELF_PARTICIPATED then
    GangDungeonProtocol.OnSelfHasParticipatedError(p)
  elseif p.result == p.class.ENTER_FACTIONPVE_MAP__TEAM_PARTICIPATED then
    GangDungeonProtocol.OnTeamMemberHasParticipatedError(p)
  else
    local text = textRes.GangDungeon.SFactionPVENormalResult[p.result]
    if text then
      Toast(text:format(unpack(p.args)))
    else
      Toast(string.format("OnSFactionPVENormalResult(%d)", p.result))
    end
  end
end
def.static("table").OnSelfLevelTooLowError = function(p)
  local gangDungeonModule = GangDungeonModule.Instance()
  local activityId = gangDungeonModule:GetActivityId()
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  local minLevel = activityCfg.levelMin
  local text = textRes.GangDungeon.SFactionPVENormalResult[p.result]
  text = text:format(tostring(minLevel))
  Toast(text)
end
def.static("table").OnTeamMemberLevelTooLowError = function(p)
  local gangDungeonModule = GangDungeonModule.Instance()
  local activityId = gangDungeonModule:GetActivityId()
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  local minLevel = activityCfg.levelMin
  local text = textRes.GangDungeon.SFactionPVENormalResult[p.result]
  text = text:format(p.args[1], tostring(minLevel))
  Toast(text)
end
def.static("table").OnSelfJustJoinError = function(p)
  local NeedJoinHours = GangDungeonUtils.GetConstant("NeedJoinHours")
  local text = textRes.GangDungeon.SFactionPVENormalResult[p.result]
  text = text:format(tostring(NeedJoinHours))
  Toast(text)
end
def.static("table").OnTeamMemberJustJoinError = function(p)
  local NeedJoinHours = GangDungeonUtils.GetConstant("NeedJoinHours")
  local text = textRes.GangDungeon.SFactionPVENormalResult[p.result]
  text = text:format(p.args[1], tostring(NeedJoinHours))
  Toast(text)
end
def.static("table").OnSelfHasParticipatedError = function(p)
  local gangDungeonModule = GangDungeonModule.Instance()
  local activityName = gangDungeonModule:GetActivityName()
  local text = textRes.GangDungeon.SFactionPVENormalResult[p.result]
  text = text:format(activityName)
  Toast(text)
end
def.static("table").OnTeamMemberHasParticipatedError = function(p)
  local gangDungeonModule = GangDungeonModule.Instance()
  local activityName = gangDungeonModule:GetActivityName()
  local text = textRes.GangDungeon.SFactionPVENormalResult[p.result]
  text = text:format(p.args[1], activityName)
  Toast(text)
end
return GangDungeonProtocol.Commit()
