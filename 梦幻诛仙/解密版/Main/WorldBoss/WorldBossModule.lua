local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local WorldBossMgr = require("Main.WorldBoss.WorldBossMgr")
local WorldBossUtility = require("Main.WorldBoss.WorldBossUtility")
local WorldBossPanel = require("Main.WorldBoss.ui.WorldBossPanel")
local WorldBossBuyPanel = require("Main.WorldBoss.ui.WorldBossBuyPanel")
local WorldBossModule = Lplus.Extend(ModuleBase, "WorldBossModule")
local def = WorldBossModule.define
local instance
def.const("string").WORLDBOSS_INVITE_DAY = "WorldBossInviteDay"
def.static("=>", WorldBossModule).Instance = function()
  if not instance then
    instance = WorldBossModule()
    instance.m_moduleId = ModuleId.WORLDBOSS
  end
  return instance
end
def.override().Init = function(self)
  WorldBossMgr.Instance():Init()
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, WorldBossModule.OnActivityTodo)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MAINUI_SHOW, WorldBossModule.OnMainUIReady)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, WorldBossModule.OnRoleLvUp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bigboss.SSynBigbossData", WorldBossModule.OnSSynBigbossData)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bigboss.SBuyChallengeCountRes", WorldBossModule.OnSBuyChallengeCountRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bigboss.SSynBigbossDataChanged", WorldBossModule.OnSSynBigbossDataChanged)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bigboss.SErrorInfo", WorldBossModule.OnSErrorInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bigboss.SSynBigbossChart", WorldBossModule.OnSSynBigbossChart)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SynActivityStart", WorldBossModule.OnActivityStart)
  ModuleBase.Init(self)
end
def.method().JoinWorldBossActivity = function(self)
  local p = require("netio.protocol.mzm.gsp.bigboss.CJoinBigbossReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  local activityID = WorldBossMgr.ACTIVITYID
  if p1[1] == activityID then
    instance:JoinWorldBossActivity()
  end
end
def.static("table").OnSSynBigbossData = function(p)
  WorldBossMgr.Instance():SyncAllData(p)
  WorldBossPanel.Instance():ShowPanel()
end
def.static("table").OnSSynBigbossChart = function(p)
  WorldBossMgr.Instance():SyncRankList(p.rankList)
  Event.DispatchEvent(ModuleId.WORLDBOSS, gmodule.notifyId.WorldBoss.RANK_LIST_RCVD, nil)
end
def.static("table").OnSBuyChallengeCountRes = function(p)
  WorldBossMgr.Instance():SetChallengeCounts(p.totalbuycount, p.challengeCount)
  Toast(textRes.WorldBoss[1])
  Event.DispatchEvent(ModuleId.WORLDBOSS, gmodule.notifyId.WorldBoss.CHALLENGE_COUNT_BOUGHT, nil)
end
def.static("table").OnSSynBigbossDataChanged = function(p)
  WorldBossMgr.Instance():SetScoreRank(p.ocp, p.damagePoint, p.rank)
  WorldBossMgr.Instance():SetChallengeCountLeft(p.challengeCount)
  WorldBossPanel.Instance():ShowPanel()
end
def.method().ShowPrompt = function(self)
  local activityID = WorldBossMgr.ACTIVITYID
  local actCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(activityID)
  local myLevel = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
  if myLevel >= actCfg.levelMin and myLevel <= actCfg.levelMax and not WorldBossModule.HasInvited() then
    WorldBossModule.SaveInvited()
    local CommonConfirm = require("GUI.CommonConfirmDlg")
    CommonConfirm.ShowConfirm(textRes.WorldBoss[8], textRes.WorldBoss[9], function(selection, tag)
      if selection == 1 and WorldBossUtility.CanEnterWorldboss() then
        instance:JoinWorldBossActivity()
      end
    end, nil)
  end
end
def.static("table").OnActivityStart = function(p)
  local activityID = WorldBossMgr.ACTIVITYID
  if p.activityid == activityID then
  end
end
def.static("table", "table").OnMainUIReady = function(p1, p2)
  local activityID = WorldBossMgr.ACTIVITYID
  local worldBossOpen = require("Main.activity.ActivityInterface").GetActivityState(activityID)
  if worldBossOpen == 0 then
  end
end
def.static("table", "table").OnRoleLvUp = function(p1, p2)
  local activityID = WorldBossMgr.ACTIVITYID
  local worldBossOpen = require("Main.activity.ActivityInterface").GetActivityState(activityID)
  local lastLevel = p1.lastLevel
  local curLevel = p1.level
  local actCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(activityID)
  if worldBossOpen ~= 0 or not (lastLevel < actCfg.levelMin) or curLevel >= actCfg.levelMin then
  end
end
def.static("=>", "boolean").HasInvited = function()
  local date = GetServerTime()
  local dateTbl = os.date("*t", date)
  local PlayerPref = require("Main.Common.LuaPlayerPrefs")
  local invitedDay = PlayerPref.GetRoleInt(WorldBossModule.WORLDBOSS_INVITE_DAY)
  if invitedDay and invitedDay == dateTbl.yday then
    return true
  else
    return false
  end
end
def.static().SaveInvited = function()
  local date = GetServerTime()
  local dateTbl = os.date("*t", date)
  local PlayerPref = require("Main.Common.LuaPlayerPrefs")
  PlayerPref.SetRoleInt(WorldBossModule.WORLDBOSS_INVITE_DAY, dateTbl.yday)
  PlayerPref.Save()
end
def.static("table").OnSErrorInfo = function(p)
  Toast(textRes.WorldBoss.ErrorCode[p.errorCode])
end
def.override().OnReset = function(self)
  WorldBossMgr.Instance():ClearUp()
end
WorldBossModule.Commit()
return WorldBossModule
