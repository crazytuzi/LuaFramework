local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local PKModule = Lplus.Extend(ModuleBase, "PKModule")
require("Main.module.ModuleId")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECPlayer = Lplus.ForwardDeclare("ECPlayer")
local PKData = require("Main.PK.data.PKData")
local CommonActivityPanel = require("GUI.CommonActivityPanel")
local ArenaStage = require("netio.protocol.mzm.gsp.arena.SStageBrd")
local pkMain = require("Main.PK.ui.PKMainDlg")
local pkMatchDlg = require("Main.PK.ui.PKMatchDlg")
local ItemUtils = require("Main.Item.ItemUtils")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local def = PKModule.define
local instance
local isShowPKUI = false
def.static("=>", PKModule).Instance = function()
  if instance == nil then
    instance = PKModule()
    instance.m_moduleId = ModuleId.LEITAI
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.arena.SSyncRoleScore", PKModule.SSyncRoleScore)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.arena.SCampsInfoRes", PKModule.SCampsInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.arena.SSelfRankRes", PKModule.SSelfRankRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.arena.SStageBrd", PKModule.SStageBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.arena.SArenaNormalResult", PKModule.SArenaNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.arena.SSyncGetWinTimesAward", PKModule.SSyncGetWinTimesAward)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.arena.SArenaTitle", PKModule.OnSArenaTitle)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.arena.SGainPreciousItemsBrd", PKModule.OnSGainPreciousItemsBrd)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, PKModule.OnNPCService)
  Event.RegisterEvent(ModuleId.LOTTERY, gmodule.notifyId.Lottery.LOTTERY_PANEL_CLOSE, PKModule.OnActiveEnd)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, PKModule.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, PKModule.OnLeaveFight)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_STATUS_CHANGED, PKModule.OnStatusChanged)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_QueryPhaseFromServerRes, PKModule.OnGetServerActivityPhaseTime)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, PKModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, PKModule.OnLeaveWorld)
end
def.static("table").SSyncRoleScore = function(p)
  PKData.Instance().myInfo.teamType = p.camp
  PKData.Instance().myInfo.points = p.score
  PKData.Instance().myInfo.xingdong = p.action_point
  PKData.Instance().myInfo.winCount = p.win_times
  Event.DispatchEvent(ModuleId.PK, gmodule.notifyId.PK.Update_PK_ManiUI, {0})
  Event.DispatchEvent(ModuleId.PK, gmodule.notifyId.PK.UPDATE_AWARD, nil)
end
def.static("table").SCampsInfoRes = function(p)
  local teamList = PKData.Instance().TeamList
  local infoList = p.camps
  for i = 1, #infoList do
    teamList[i].type = infoList[i].camp
    teamList[i].points = infoList[i].score
  end
  Event.DispatchEvent(ModuleId.PK, gmodule.notifyId.PK.Update_PK_ManiUI, {0})
end
def.static("table").SSelfRankRes = function(p)
  PKData.Instance().rank = p.rank + 1
  PKData.Instance().points = p.score
  Event.DispatchEvent(ModuleId.PK, gmodule.notifyId.PK.Update_PK_ManiUI, {0})
end
def.static("table").SStageBrd = function(p)
  PKData.Instance().state = p.stage
  if (PKData.Instance().state == ArenaStage.STG_MATCH_1 or PKData.Instance().state == ArenaStage.STG_MATCH_2) and not require("Main.Fight.FightMgr").Instance().isInFight then
    pkMatchDlg.Instance():ShowDlg()
  else
    pkMatchDlg.Instance():DestroyPanel()
  end
  if PKData.Instance().state == ArenaStage.STG_PREPARE then
    local ActivityID = DynamicData.GetRecord(CFG_PATH.DATA_PK3V3_CONST_CFG, "Activityid"):GetIntValue("value")
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_QueryPhaseFromServerReq, {
      ActivityID,
      ArenaStage.STG_PREPARE
    })
  else
    require("Main.activity.ui.ActivityCountDown").Instance():StopTimer()
  end
end
def.static("table", "table").OnGetServerActivityPhaseTime = function(p1, p2)
  local activityId = p1[1]
  local stage = p1[2]
  local ArenaID = DynamicData.GetRecord(CFG_PATH.DATA_PK3V3_CONST_CFG, "Activityid"):GetIntValue("value")
  if activityId == ArenaID and stage == ArenaStage.STG_PREPARE then
    local nowSec = GetServerTime()
    local activityTime = p1[3]
    if nowSec < activityTime then
      require("Main.activity.ui.ActivityCountDown").Instance():StartActivityTimer(textRes.PVP3[14], activityTime - nowSec)
    end
  end
end
def.static("table").SArenaNormalResult = function(p)
  local resStr = textRes.PVP3[p.result]
  if p.result == p.ENTER_ARENA_MAP__OTHER_NO_ACTION_POINT then
    resStr = string.format(textRes.PVP3[p.result], p.args[1] or "")
  elseif p.result == p.ENTER_ARENA_MAP__OTHER_PARTICIPATED then
    resStr = string.format(textRes.PVP3[p.result], p.args[1] or "")
  end
  Toast(resStr)
end
def.static("table").SSyncGetWinTimesAward = function(p)
  PKData.Instance().myInfo.awardList = p.awards
  Event.DispatchEvent(ModuleId.PK, gmodule.notifyId.PK.Update_PK_ManiUI, {0})
  Event.DispatchEvent(ModuleId.PK, gmodule.notifyId.PK.UPDATE_AWARD, nil)
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
  local tipContent = string.format(textRes.PVP3[13], p.name, itemStr)
  if ItemUtils.GetAwardBulletinType(p.items) == BulletinType.UNUSUAL then
    require("GUI.RareItemAnnouncementTip").AnnounceRareItem(tipContent)
  else
    require("GUI.AnnouncementTip").Announce(tipContent)
  end
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = tipContent})
end
def.static("table", "table").OnActiveEnd = function(p1, p2)
  local heroModule = require("Main.Hero.HeroModule")
  local myRole = heroModule.Instance().myRole
  if myRole:IsInState(RoleState.TXHW) then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.arena.CLeaveAfterWinnerAwardReq").new())
  end
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  local heroModule = require("Main.Hero.HeroModule")
  local myRole = heroModule.Instance().myRole
  if not myRole:IsInState(RoleState.TXHW) then
    return
  end
  if pkMain.Instance():IsShow() then
    isShowPKUI = true
  else
    isShowPKUI = false
  end
  pkMain.Instance():Show(false)
  pkMatchDlg.Instance():DestroyPanel()
end
def.static("table", "table").OnLeaveFight = function(p1, p2)
  local heroModule = require("Main.Hero.HeroModule")
  local myRole = heroModule.Instance().myRole
  if not myRole:IsInState(RoleState.TXHW) then
    return
  end
  if isShowPKUI then
    pkMain.Instance():Show(true)
  end
  if PKData.Instance().state == 1 or PKData.Instance().state == 2 then
    pkMatchDlg.Instance():ShowDlg()
  end
end
def.static("table", "table").OnSArenaTitle = function(role, p)
  if role == nil then
    warn("OnSArenaTitle role is nil")
    return
  end
  if p then
    local title, colorId = instance:GetGroupTitle(p.camp)
    local titleColor = GetColorData(colorId)
    role:SetShowTitle(title, titleColor)
  else
    role:SetShowTitle("", nil)
  end
end
def.static("table", "table").OnNPCService = function(p1, p2)
  local serviceID = p1[1]
  local npcID = p1[2]
  local ActivityID = DynamicData.GetRecord(CFG_PATH.DATA_PK3V3_CONST_CFG, "Activityid"):GetIntValue("value")
  if serviceID == require("Main.npc.NPCServiceConst").PK3v3 then
    local ActivityInterface = require("Main.activity.ActivityInterface")
    local msg = ""
    if ActivityInterface.CheckActivityConditionTeamMemberCount(ActivityID, true) == false then
      return
    end
    if ActivityInterface.CheckActivityConditionLevel(ActivityID, true) == false then
      return
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.arena.CEnterArenaMapReq").new(npcID))
  elseif serviceID == require("Main.npc.NPCServiceConst").LeavePVP3V3 then
    instance:Quit()
  elseif serviceID == require("Main.npc.NPCServiceConst").PVP3Tips then
  elseif serviceID == require("Main.npc.NPCServiceConst").PVP3v3Begin then
    pkMain.Instance():ShowDlg()
  elseif serviceID == require("Main.npc.NPCServiceConst").PVP3v3Team then
    local teamData = require("Main.Team.TeamData").Instance()
    local members = teamData:GetAllTeamMembers()
    local memberCount = #members
    if teamData:MeIsCaptain() == false or memberCount <= 0 then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.Team.CFlushInActivityReq").new(require("netio.protocol.mzm.gsp.Team.CFlushInActivityReq").FIND_TEAM))
    elseif teamData:MeIsCaptain() == true and memberCount > 0 then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.Team.CFlushInActivityReq").new(require("netio.protocol.mzm.gsp.Team.CFlushInActivityReq").FIND_MEMBER))
    end
  end
end
def.static("table", "table").OnStatusChanged = function(p1, p2)
  local statusChanged = p1 and p1[1]
  if statusChanged == nil then
    return
  end
  local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if statusChanged.Check(RoleState.TXHW) then
    if role:IsInState(RoleState.TXHW) then
      Team_Max_Size = 3
      if role.teamId then
        gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ResetTeamNum(role.teamId)
      end
      Event.DispatchEvent(ModuleId.PK, gmodule.notifyId.PK.ENTER_TXHW, nil)
      CommonActivityPanel.Instance():ShowActivityPanel(true, true, function(tag)
        require("Main.Team.TeamUtils").JoinTeam()
      end, nil, function()
        instance:Quit()
      end, nil, false, CommonActivityPanel.ActivityType.TXHW)
      if PKData.Instance().state == ArenaStage.STG_MATCH_1 or PKData.Instance().state == ArenaStage.STG_MATCH_2 then
        pkMatchDlg.Instance():ShowDlg()
      end
    else
      Team_Max_Size = 5
      if role.teamId then
        gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ResetTeamNum(role.teamId)
      end
      CommonActivityPanel.Instance():HidePanel(CommonActivityPanel.ActivityType.TXHW)
      require("Main.PK.ui.PKMatchDlg").Instance():DestroyPanel()
      Event.DispatchEvent(ModuleId.PK, gmodule.notifyId.PK.LEAVE_TXHW, nil)
      require("Main.activity.ui.ActivityCountDown").Instance():StopTimer()
    end
  end
end
def.method().Quit = function(self)
  require("GUI.CommonConfirmDlg").ShowConfirm("", textRes.PVP[14], function(i, tag)
    if i == 1 then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.arena.CLeaveArenaMapReq").new())
    end
  end, nil)
end
def.method("number", "=>", "string").GetGroupName = function(self, teamType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PK3V3_CAMP_CFG, teamType)
  if record then
    return record:GetStringValue("name")
  end
  return ""
end
def.method("number", "=>", "string", "number").GetGroupTitle = function(self, teamType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PK3V3_CAMP_CFG, teamType)
  if record then
    return record:GetStringValue("title"), record:GetIntValue("color")
  end
  return "", 0
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  Team_Max_Size = 5
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  Team_Max_Size = 5
end
PKModule.Commit()
return PKModule
