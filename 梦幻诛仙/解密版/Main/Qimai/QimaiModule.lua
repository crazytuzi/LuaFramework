local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local QimaiModule = Lplus.Extend(ModuleBase, "QimaiModule")
require("Main.module.ModuleId")
local ActivityInterface = require("Main.activity.ActivityInterface")
local def = QimaiModule.define
local instance
local AnnouncementTip = require("GUI.AnnouncementTip")
local CommonDescDlg = require("GUI.CommonUITipsDlg")
local MatchEffect = require("Main.PVP.ui.DlgPvpMatch")
local FightMgr = require("Main.Fight.FightMgr")
local CommonActivityPanel = require("GUI.CommonActivityPanel")
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local QiMai_Stage = require("netio.protocol.mzm.gsp.qmhw.SSynStageChange")
local ItemUtils = require("Main.Item.ItemUtils")
local HtmlHelper = require("Main.Chat.HtmlHelper")
def.field("number").score = 0
def.field("table").rankData = nil
def.field("number").stage = 0
def.field("number").endTime = 0
def.field("number").win = 0
def.field("number").lose = 0
def.field("number").winningStreak = 0
def.field("boolean").oneVictoryClaimed = false
def.field("boolean").fiveBattleClaimed = false
def.field("number").myrank = -1
def.static("=>", QimaiModule).Instance = function()
  if instance == nil then
    instance = QimaiModule()
    instance.m_moduleId = ModuleId.QIMAI_HUIWU
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qmhw.SSynRoleQMHWToTalInfo", QimaiModule.OnSSynRoleQMHWToTalInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qmhw.SSynQMHWInfoChange", QimaiModule.OnSSynQMHWInfoChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qmhw.SSynQMHWAwardInfoChange", QimaiModule.OnSSynQMHWAwardInfoChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qmhw.SSynQMHWFightAward", QimaiModule.OnSSynQMHWFightAward)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qmhw.SSynStageChange", QimaiModule.OnSSynStageChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qmhw.SQMHWRankRes", QimaiModule.OnSQMHWRankRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qmhw.SQMHWSelfRankRes", QimaiModule.OnSQMHWSelfRankRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qmhw.SQMHWNormalResult", QimaiModule.OnSQMHWNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qmhw.SBrocastContinueWin", QimaiModule.OnSBrocastContinueWin)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qmhw.SBrocastQMHWItem", QimaiModule.OnSBrocastQMHWItem)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qmhw.SBrocastGetTitleRoles", QimaiModule.OnSBrocastGetTitleRoles)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, QimaiModule.OnNPCService)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_QueryEndingTimeFromServerRes, QimaiModule.OnGetServerActivityTime)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_QueryPhaseFromServerRes, QimaiModule.OnGetServerActivityPhaseTime)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, QimaiModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, QimaiModule.OnActivityEnd)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_STATUS_CHANGED, QimaiModule.OnStatusChanged)
end
def.method("number", "number").RequireRankList = function(self, start, amount)
  if self.rankData and #self.rankData > start + amount then
    return
  end
  local from = start - 1
  local to = from + amount - 1
  if self.rankData then
    for i = from, to do
      if self.rankData[i + 1] == nil then
        from = i
        break
      end
    end
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.qmhw.CQMHWRankReq").new(from, to))
end
def.method().ClearRank = function(self)
  instance.rankData = nil
end
def.static("table").OnSSynRoleQMHWToTalInfo = function(p)
  instance.score = p.qmhwInfo.score
  instance.win = p.qmhwInfo.winCount
  instance.lose = p.qmhwInfo.loseCount
  instance.winningStreak = p.qmhwInfo.continueWinCount
  instance.oneVictoryClaimed = p.awardInfo.winAwards[1] ~= nil
  instance.fiveBattleClaimed = p.awardInfo.joinAwards[5] ~= nil
  Event.DispatchEvent(ModuleId.QIMAI_HUIWU, gmodule.notifyId.Qimai.UPDATE_INFO, nil)
end
def.static("table").OnSSynQMHWInfoChange = function(p)
  instance.score = p.qmhwInfo.score
  instance.win = p.qmhwInfo.winCount
  instance.lose = p.qmhwInfo.loseCount
  instance.winningStreak = p.qmhwInfo.continueWinCount
  Event.DispatchEvent(ModuleId.QIMAI_HUIWU, gmodule.notifyId.Qimai.UPDATE_INFO, nil)
end
def.static("table").OnSSynQMHWAwardInfoChange = function(p)
  instance.oneVictoryClaimed = p.qmhwAwardInfo.winAwards[1] ~= nil
  instance.fiveBattleClaimed = p.qmhwAwardInfo.joinAwards[5] ~= nil
  Event.DispatchEvent(ModuleId.QIMAI_HUIWU, gmodule.notifyId.Qimai.UPDATE_INFO, nil)
end
def.static("table").OnSQMHWNormalResult = function(p)
  instance.endTime = 0
  if p.args and 0 < #p.args then
    Toast(string.format(textRes.PVP[100 + p.result], unpack(p.args)))
  else
    Toast(textRes.PVP[100 + p.result])
  end
end
def.static("table").OnSSynQMHWFightAward = function(p)
  if p.score > 0 then
    Toast(string.format(textRes.PVP[34], p.score))
  else
    Toast(string.format(textRes.PVP[35], 0))
  end
  local awardInfo = require("Main.Award.AwardUtils").GetHtmlTextsFromAwardBean(p.awardBean, textRes.AnnounceMent[8])
  for _, v in ipairs(awardInfo) do
    require("Main.Chat.PersonalHelper").SendOut(v)
  end
end
def.static("table").OnSQMHWRankRes = function(p)
  if instance.rankData == nil then
    instance.rankData = {}
  end
  for _, v in pairs(p.rankDatas) do
    instance.rankData[v.rank + 1] = v
  end
  Event.DispatchEvent(ModuleId.QIMAI_HUIWU, gmodule.notifyId.Qimai.UPDATE_RANK, nil)
end
def.static("table").OnSQMHWSelfRankRes = function(p)
  if p.rank >= 0 then
    instance.myrank = p.rank + 1
  else
    instance.myrank = -1
  end
  instance.score = p.score or 0
  Event.DispatchEvent(ModuleId.QIMAI_HUIWU, gmodule.notifyId.Qimai.UPDATE_RANK, nil)
end
def.static("table").OnSBrocastContinueWin = function(p)
  AnnouncementTip.Announce(string.format(textRes.PVP[33], p.rolename, p.count))
end
def.static("table").OnSBrocastQMHWItem = function(p)
  local itemStr = ""
  for k, v in pairs(p.item2count) do
    local itemBase = ItemUtils.GetItemBase(k)
    if itemBase then
      itemStr = "[" .. HtmlHelper.NameColor[itemBase.namecolor] .. "]" .. itemBase.name .. "\195\151" .. v .. "[-]"
    end
  end
  local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
  local msgContent = string.format(textRes.PVP[36], p.rolename, itemStr)
  if ItemUtils.GetAwardBulletinType(p.item2count) == BulletinType.UNUSUAL then
    require("GUI.RareItemAnnouncementTip").AnnounceRareItem(msgContent)
  else
    AnnouncementTip.Announce(msgContent)
  end
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = msgContent})
end
def.static("table", "table").OnNPCService = function(p1, p2)
  local serviceID = p1[1]
  local npcId = p1[2]
  if serviceID and serviceID == NPCServiceConst.QiMai_Enter then
    local activityCfg = ActivityInterface.GetActivityCfgById(constant.QimaiConsts.ACTIVITY_ID)
    if activityCfg and require("Main.Hero.Interface").GetHeroProp().level < activityCfg.levelMin then
      Toast(string.format(textRes.PVP[38], activityCfg.levelMin))
      return
    end
    if require("Main.Team.TeamData").Instance():HasLeavingMember() then
      Toast(textRes.PVP[39])
      return
    end
    local members = require("Main.Team.TeamData").Instance():GetAllTeamMembers()
    if members and #members > 0 then
      for _, v in pairs(members) do
        if v.level < activityCfg.levelMin or v.level > activityCfg.levelMax then
          Toast(string.format(textRes.PVP[41], v.name, tostring(activityCfg.levelMin)))
          return
        end
      end
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.qmhw.CJoinQMHWReq").new())
  elseif serviceID and serviceID == NPCServiceConst.QiMai_Rules then
  elseif serviceID and serviceID == NPCServiceConst.QiMai_Check then
    require("Main.Qimai.ui.QimaiMainDlg").Instance():ShowDlg()
  elseif serviceID and serviceID == NPCServiceConst.QiMai_Leave then
    instance:Quit()
  end
end
def.static("table").OnSSynStageChange = function(p)
  instance.stage = p.stage
  instance:ShowMatchEffect()
  if instance.stage == QiMai_Stage.STATUS_PREPARE_0 then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_QueryPhaseFromServerReq, {
      constant.QimaiConsts.ACTIVITY_ID,
      QiMai_Stage.STATUS_PREPARE_0
    })
  else
    require("Main.activity.ui.ActivityCountDown").Instance():StopTimer()
  end
end
def.method().ShowMatchEffect = function(self)
  if gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole == nil then
    return
  end
  if self.stage == QiMai_Stage.STATUS_MATCH_1 and not FightMgr.Instance().isInFight and gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole:IsInState(RoleState.QMHW) then
    MatchEffect.Instance():ShowDlg()
  else
    MatchEffect.Instance():Hide()
  end
end
def.static("table", "table").OnGetServerActivityTime = function(p1, p2)
  local activityId = p1[1]
  if activityId == constant.QimaiConsts.ACTIVITY_ID then
    instance.endTime = p1[2]
  end
end
def.static("table", "table").OnGetServerActivityPhaseTime = function(p1, p2)
  local activityId = p1[1]
  local stage = p1[2]
  if activityId == constant.QimaiConsts.ACTIVITY_ID and stage == QiMai_Stage.STATUS_PREPARE_0 then
    local nowSec = GetServerTime()
    local activityTime = p1[3]
    if nowSec < activityTime then
      require("Main.activity.ui.ActivityCountDown").Instance():StartActivityTimer(textRes.PVP[51], activityTime - nowSec)
    end
  end
end
def.static("table", "table").OnLeaveWorld = function()
  MatchEffect.Instance():Hide()
  require("Main.Qimai.ui.QimaiMainDlg").Instance():Hide()
  require("Main.Qimai.ui.QimaiBtn").Instance():Hide()
  instance.endTime = 0
  instance.stage = 0
  instance.win = 0
  instance.lose = 0
  instance.winningStreak = 0
  instance.oneVictoryClaimed = false
  instance.fiveBattleClaimed = false
  instance.rankData = nil
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, QimaiModule.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, QimaiModule.OnLeaveFight)
end
def.static("table", "table").OnActivityEnd = function(p1, p2)
  local activityId = p1[1]
  if activityId == constant.QimaiConsts.ACTIVITY_ID then
    QimaiModule.OnLeaveWorld(nil, nil)
  end
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  MatchEffect.Instance():Hide()
  require("Main.Qimai.ui.QimaiMainDlg").Instance():Hide()
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
  if statusChanged.Check(RoleState.QMHW) then
    if role:IsInState(RoleState.QMHW) then
      instance.rankData = nil
      CommonActivityPanel.Instance():ShowActivityPanel(true, true, function()
        instance:OpenActivityTeam()
      end, nil, function()
        instance:Quit()
      end, nil, false, CommonActivityPanel.ActivityType.QMHW)
      Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, QimaiModule.OnEnterFight)
      Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, QimaiModule.OnLeaveFight)
      Event.DispatchEvent(ModuleId.QIMAI_HUIWU, gmodule.notifyId.Qimai.ENTER_QMHW, nil)
      instance:ShowMatchEffect()
      if not FightMgr.Instance().isInFight then
        require("Main.Qimai.ui.QimaiBtn").Instance():ShowDlg()
      end
      Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_QueryEndingTimeFromServerReq, {
        constant.QimaiConsts.ACTIVITY_ID
      })
    else
      CommonActivityPanel.Instance():HidePanel(CommonActivityPanel.ActivityType.QMHW)
      Event.DispatchEvent(ModuleId.QIMAI_HUIWU, gmodule.notifyId.Qimai.LEAVE_QMHW, nil)
      MatchEffect.Instance():Hide()
      require("Main.Qimai.ui.QimaiMainDlg").Instance():Hide()
      require("Main.Qimai.ui.QimaiBtn").Instance():Hide()
      require("Main.activity.ui.ActivityCountDown").Instance():StopTimer()
    end
  end
end
def.method().OpenActivityTeam = function()
  local teamData = require("Main.Team.TeamData").Instance()
  if teamData:IsTeamMembersFully() then
    Toast(textRes.Team[7])
  else
    local CFlushInActivityReq = require("netio.protocol.mzm.gsp.Team.CFlushInActivityReq")
    if teamData:MeIsCaptain() then
      gmodule.network.sendProtocol(CFlushInActivityReq.new(CFlushInActivityReq.FIND_MEMBER))
    else
      gmodule.network.sendProtocol(CFlushInActivityReq.new(CFlushInActivityReq.FIND_TEAM))
    end
  end
end
def.method().Quit = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.qmhw.CLeaveQMHWReq").new())
end
def.static("table").OnSBrocastGetTitleRoles = function(p)
  local roleNamesStr = ""
  for i = 1, #p.rolename do
    if i > 1 then
      roleNamesStr = roleNamesStr .. ","
    end
    roleNamesStr = roleNamesStr .. "[00ff00]" .. p.rolename[i] .. "[-]"
  end
  local titleid = instance:GetRankTitle(1)
  local titleStr
  if titleid > 0 then
    local titleCfg = require("Main.title.TitleInterface").GetAppellationCfg(titleid)
    if titleCfg then
      local colorCfg = GetNameColorCfg(titleCfg.appellationColor)
      if colorCfg then
        local color = string.format("%02x%02x%02x", colorCfg.r, colorCfg.g, colorCfg.b)
        titleStr = string.format("[%1$s]%2$s[-]", color, titleCfg.appellationName)
      end
    end
  end
  if titleStr then
    local tipContent = string.format(textRes.PVP[40], roleNamesStr, titleStr)
    AnnouncementTip.Announce(tipContent)
    local ChatModule = require("Main.Chat.ChatModule")
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = tipContent})
  end
end
def.method("number", "=>", "number").GetRankTitle = function(self, rank)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_QMHW_NPC_CFG, rank)
  if record == nil then
    warn("GetQMHW_Rank_title return nil for id: ", rank)
    return 0
  end
  return record:GetIntValue("titleid")
end
QimaiModule.Commit()
return QimaiModule
