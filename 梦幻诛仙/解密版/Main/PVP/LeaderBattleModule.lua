local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local LeaderBattleModule = Lplus.Extend(ModuleBase, "LeaderBattleModule")
require("Main.module.ModuleId")
local ActivityInterface = require("Main.activity.ActivityInterface")
local def = LeaderBattleModule.define
local instance
local DlgLeaderBattleBtn = require("Main.PVP.ui.DlgLeaderBattleBtn")
local DlgLeaderBattleRank = require("Main.PVP.ui.DlgLeaderBattleRank")
local AnnouncementTip = require("GUI.AnnouncementTip")
local Leader_Battle_Stage = require("netio.protocol.mzm.gsp.menpaipvp.SStageBrd")
local CommonDescDlg = require("GUI.CommonUITipsDlg")
local HeroInterface = require("Main.Hero.Interface")
local MatchEffect = require("Main.PVP.ui.DlgPvpMatch")
local FightMgr = require("Main.Fight.FightMgr")
local CommonActivityPanel = require("GUI.CommonActivityPanel")
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local ItemUtils = require("Main.Item.ItemUtils")
local HtmlHelper = require("Main.Chat.HtmlHelper")
def.field("table").rankInfo = nil
def.field("table").myRankInfo = nil
def.field("number").stage = 0
def.field("number").endTime = 0
def.field("number").nextMatchTime = 0
def.static("=>", LeaderBattleModule).Instance = function()
  if instance == nil then
    instance = LeaderBattleModule()
    instance.m_moduleId = ModuleId.LEADER_BATTLE
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaipvp.SSyncScore", LeaderBattleModule.OnSSyncScoreInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaipvp.SChartRes", LeaderBattleModule.OnSSyncRankInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaipvp.SSelfRankRes", LeaderBattleModule.OnSSyncMyRank)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaipvp.SChampionsBrd", LeaderBattleModule.OnSSyncLeaderInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaipvp.SStageBrd", LeaderBattleModule.OnSStageBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaipvp.SMenpaiPVPNormalResult", LeaderBattleModule.OnSMenpaiPVPNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaipvp.SReachMaxLoseTimesNotify", LeaderBattleModule.OnSReachMaxLoseTimesNotify)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaipvp.SFightTimesAwardNotify", LeaderBattleModule.OnSFightTimesAwardNotify)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaipvp.SGainPreciousItemsBrd", LeaderBattleModule.OnSGainPreciousItemsBrd)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, LeaderBattleModule.OnNPCService)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_QueryEndingTimeFromServerRes, LeaderBattleModule.OnGetServerActivityTime)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_QueryPhaseFromServerRes, LeaderBattleModule.OnGetServerActivityPhaseTime)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, LeaderBattleModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, LeaderBattleModule.OnActivityEnd)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_STATUS_CHANGED, LeaderBattleModule.OnStatusChanged)
end
def.static("table").OnSSyncScoreInfo = function(p)
  if instance.myRankInfo == nil then
    instance.myRankInfo = {}
  end
  instance.myRankInfo.score = p.score
  instance.myRankInfo.win = p.win_times
  instance.myRankInfo.lose = p.lose_times
end
def.static("table").OnSSyncRankInfo = function(p)
  instance.rankInfo = p
  if DlgLeaderBattleRank.Instance():IsShow() then
    DlgLeaderBattleRank.Instance():SetRankData()
  end
end
def.static("table").OnSSyncMyRank = function(p)
  if instance.myRankInfo == nil then
    instance.myRankInfo = {}
    instance.myRankInfo.score = 0
    instance.myRankInfo.win = 0
    instance.myRankInfo.lose = 0
  end
  if 0 <= p.rank then
    instance.myRankInfo.rank = p.rank + 1
  else
    instance.myRankInfo.rank = -1
  end
  Event.DispatchEvent(ModuleId.LEADER_BATTLE, gmodule.notifyId.PVP.UPDATE_LEADER_BATTLE_MYRANK, nil)
end
def.static("table").OnSSyncLeaderInfo = function(p)
  instance.endTime = 0
  for i = 1, #p.champions do
    AnnouncementTip.Announce(string.format(textRes.PVP[4], p.champions[i].name, GetOccupationName(p.champions[i].menpai)))
  end
end
def.static("table", "table").OnNPCService = function(p1, p2)
  local serviceID = p1[1]
  local npcId = p1[2]
  if serviceID and serviceID == NPCServiceConst.Leader_Battle then
    local activityCfg = ActivityInterface.GetActivityCfgById(constant.MenpaiPVPConsts.LEADER_BATTLE)
    if activityCfg and HeroInterface.GetHeroProp().level < activityCfg.levelMin then
      Toast(string.format(textRes.PVP[17], activityCfg.levelMin))
      return
    end
    local OccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
    local myProp = require("Main.Hero.Interface").GetBasicHeroProp()
    local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
    local isOpen = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_NEW_OCCUPATION__CANG_YU)
    if myProp.occupation == OccupationEnum.CANG_YU_GE and not isOpen then
      Toast(textRes.PVP[102])
      return
    end
    isOpen = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_NEW_OCCUPATION_LING_YIN_DIAN)
    if myProp.occupation == OccupationEnum.LING_YIN_DIAN and not isOpen then
      Toast(textRes.PVP[102])
      return
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.menpaipvp.CEnterMenpaiMapReq").new(npcId))
  elseif serviceID and serviceID == NPCServiceConst.Leader_Battle_Check_Scores then
    if instance.stage == Leader_Battle_Stage.STG_PREPARE then
      Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_QueryPhaseFromServerReq, {
        constant.MenpaiPVPConsts.LEADER_BATTLE,
        Leader_Battle_Stage.STG_PREPARE
      })
    else
      require("Main.PVP.ui.DlgLeaderBattleRank").Instance():ShowDlg()
    end
  elseif serviceID and serviceID == NPCServiceConst.Leader_Battle_Return then
    instance:Quit()
  end
end
def.static("table").OnSStageBrd = function(p)
  instance.stage = p.stage
  instance:ShowMatchEffect()
  if instance.stage == Leader_Battle_Stage.STG_PREPARE then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_QueryPhaseFromServerReq, {
      constant.MenpaiPVPConsts.LEADER_BATTLE,
      Leader_Battle_Stage.STG_PREPARE
    })
  else
    require("Main.activity.ui.ActivityCountDown").Instance():StopTimer()
  end
end
def.static("table").OnSFightTimesAwardNotify = function(p)
  local awardInfo = require("Main.Award.AwardUtils").GetHtmlTextsFromAwardBean(p.award, textRes.AnnounceMent[8])
  if awardInfo then
    Toast(textRes.PVP[43])
    for _, v in ipairs(awardInfo) do
      require("Main.Chat.PersonalHelper").SendOut(v)
    end
  end
end
def.static("table").OnSGainPreciousItemsBrd = function(p)
  local itemStr = ""
  for k, v in pairs(p.items) do
    local itemBase = ItemUtils.GetItemBase(k)
    if itemBase then
      itemStr = "[" .. HtmlHelper.NameColor[itemBase.namecolor] .. "]" .. itemBase.name .. "\195\151" .. v .. "[-]"
    end
  end
  local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
  local tipContent = string.format(textRes.PVP[37], p.name, itemStr)
  if ItemUtils.GetAwardBulletinType(p.items) == BulletinType.UNUSUAL then
    require("GUI.RareItemAnnouncementTip").AnnounceRareItem(tipContent)
  else
    require("GUI.AnnouncementTip").Announce(tipContent)
  end
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = tipContent})
end
def.method().ShowMatchEffect = function(self)
  local me = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if me == nil then
    return
  end
  if self.stage == Leader_Battle_Stage.STG_MATCH and not FightMgr.Instance().isInFight and me:IsInState(RoleState.SXZB) then
    MatchEffect.Instance():ShowDlg()
  else
    MatchEffect.Instance():Hide()
  end
end
def.static("table", "table").OnGetServerActivityTime = function(p1, p2)
  local activityId = p1[1]
  if activityId == constant.MenpaiPVPConsts.LEADER_BATTLE then
    instance.endTime = p1[2]
  end
end
def.static("table", "table").OnGetServerActivityPhaseTime = function(p1, p2)
  local activityId = p1[1]
  local stage = p1[2]
  if activityId == constant.MenpaiPVPConsts.LEADER_BATTLE and stage == Leader_Battle_Stage.STG_PREPARE then
    local nowSec = GetServerTime()
    local activityTime = p1[3]
    if nowSec < activityTime then
      require("Main.activity.ui.ActivityCountDown").Instance():StartActivityTimer(textRes.PVP[32], activityTime - nowSec)
    end
  end
end
def.static("table", "table").OnLeaveWorld = function()
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, LeaderBattleModule.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, LeaderBattleModule.OnLeaveFight)
  Timer:RemoveListener(instance.UpdateCountDown)
  DlgLeaderBattleBtn.Instance():Hide()
  MatchEffect.Instance():Hide()
  instance.myRankInfo = nil
  instance.rankInfo = nil
  instance.endTime = 0
  instance.stage = 0
end
def.static("table").OnSMenpaiPVPNormalResult = function(p)
  if p.result == p.ENTER_MENPAI_MAP__MAX_LOSE_TIMES or p.result == p.ENTER_MENPAI_MAP__PARTICPATED then
    Toast(textRes.PVP[13])
  end
end
def.static("table").OnSReachMaxLoseTimesNotify = function(p)
  Toast(textRes.PVP[16])
end
def.static("table", "table").OnActivityEnd = function(p1, p2)
  local activityId = p1[1]
  if activityId == constant.MenpaiPVPConsts.LEADER_BATTLE then
    LeaderBattleModule.OnLeaveWorld(nil, nil)
  end
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  MatchEffect.Instance():Hide()
end
def.static("table", "table").OnLeaveFight = function(p1, p2)
  instance:ShowMatchEffect()
end
def.static("table", "table").OnStatusChanged = function(p1, p2)
  local statusChanged = p1 and p1[1]
  if statusChanged == nil then
    return
  end
  local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if statusChanged.Check(RoleState.SXZB) then
    if role:IsInState(RoleState.SXZB) then
      DlgLeaderBattleBtn.Instance():ShowDlg()
      Event.DispatchEvent(ModuleId.LEADER_BATTLE, gmodule.notifyId.PVP.ENTER_LEADER_BATTLE, nil)
      CommonActivityPanel.Instance():ShowActivityPanel(false, true, nil, nil, function()
        instance:Quit()
      end, nil, false, CommonActivityPanel.ActivityType.SXZB)
      instance:ShowMatchEffect()
      Timer:RegisterListener(instance.UpdateCountDown, instance)
      Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, LeaderBattleModule.OnEnterFight)
      Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, LeaderBattleModule.OnLeaveFight)
      Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_QueryEndingTimeFromServerReq, {
        constant.MenpaiPVPConsts.LEADER_BATTLE
      })
    else
      CommonActivityPanel.Instance():HidePanel(CommonActivityPanel.ActivityType.SXZB)
      Event.DispatchEvent(ModuleId.LEADER_BATTLE, gmodule.notifyId.PVP.LEAVE_LEADER_BATTLE, nil)
      MatchEffect.Instance():Hide()
      DlgLeaderBattleBtn.Instance():Hide()
      Timer:RemoveListener(instance.UpdateCountDown)
      require("Main.activity.ui.ActivityCountDown").Instance():StopTimer()
    end
  end
end
def.method("number").UpdateCountDown = function(self, tk)
  if self.nextMatchTime > 0 then
    self.nextMatchTime = self.nextMatchTime - 1
  end
end
def.method().Quit = function(self)
  require("GUI.CommonConfirmDlg").ShowConfirm("", textRes.PVP[14], function(i, tag)
    if i == 1 then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.menpaipvp.CLeaveMenpaiMapReq").new())
    end
  end, nil)
end
LeaderBattleModule.Commit()
return LeaderBattleModule
