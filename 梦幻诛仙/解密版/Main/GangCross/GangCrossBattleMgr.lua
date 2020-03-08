local Lplus = require("Lplus")
local GangCrossBattleMgr = Lplus.Class("GangCrossBattleMgr")
local def = GangCrossBattleMgr.define
local NpcService = require("netio.protocol.mzm.gsp.competition.NpcService")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local SStageBrd = require("netio.protocol.mzm.gsp.crosscompete.SStageBrd")
local GangCrossData = require("Main.GangCross.data.GangCrossData")
local GangCrossUtility = require("Main.GangCross.GangCrossUtility")
local Octets = require("netio.Octets")
local RETURN_TO_GANGMAP = "ReturnToGangMap"
local ItemUtils = require("Main.Item.ItemUtils")
local ChatModule = require("Main.Chat.ChatModule")
local TeamData = require("Main.Team.TeamData")
local TeamMember = require("netio.protocol.mzm.gsp.team.TeamMember")
local GangUtility = require("Main.Gang.GangUtility")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local instance
def.field("number").stage = -1
def.field("number").actionPoint = 0
def.field("table").gangBattleInfo = nil
def.field("table").rivalGang = nil
def.field("table").gangIdMap = nil
def.field("table").targetPos = nil
def.field("boolean").showTip = false
def.field("number").preparePlayerNum = 0
def.field("boolean").needGoToBattle = false
def.static("=>", GangCrossBattleMgr).Instance = function()
  if instance == nil then
    instance = GangCrossBattleMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, GangCrossBattleMgr.OnNPCService)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_QueryPhaseFromServerRes, GangCrossBattleMgr.OnGetServerActivityPhaseTime)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, GangCrossBattleMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_STATUS_CHANGED, GangCrossBattleMgr.OnStatusChanged)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, GangCrossBattleMgr.OnChangeMap)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, GangCrossBattleMgr.OnActivityEnd)
end
def.static("=>", "boolean").CheckValid = function()
  local isOpen = gmodule.moduleMgr:GetModule(ModuleId.GANG_CROSS):IsFeatureOpen()
  if not isOpen then
    return false
  end
  local actTime = GangCrossUtility.Instance():getActivityWeekBeginTime()
  local nowTime = GetServerTime()
  if actTime > 0 and actTime < nowTime then
    local minutes = constant.GangCrossConsts.PrepareMinutes + constant.GangCrossConsts.FightMinutes + constant.GangCrossConsts.WaitForceEndMinutes + constant.GangCrossConsts.RestMinutes
    local beginTime = actTime + constant.GangCrossConsts.SignUpDays * 86400 + (constant.GangCrossConsts.MatchHours + constant.GangCrossConsts.MailRemindHours) * 3600 + constant.GangCrossConsts.WaitMinutes * 60
    local endTime = beginTime + (minutes + constant.GangCrossConsts.PrepareMinutes + constant.GangCrossConsts.FightMinutes) * 60
    if nowTime >= beginTime and nowTime < endTime then
      return true
    end
  end
  return false
end
def.static("table").OnSCompetitionStartBrd = function(p)
  local msgStr = string.format(textRes.Gang[201], p.opponent)
  local str = string.format("%1$s <a href='btn_%s' id=btn_%s><font color=#%s><u>[%s]</u></font></a>", msgStr, RETURN_TO_GANGMAP, RETURN_TO_GANGMAP, link_defalut_color, textRes.Gang[202])
  ChatModule.Instance():SendNoteMsg(str, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
end
def.static("table").OnSSyncRoleCompetition = function(p)
  local delta = p.action_point - instance.actionPoint
  instance.actionPoint = p.action_point
  local dlg = require("Main.GangCross.ui.DlgGangCrossBattle").Instance()
  dlg:SetActionPoint()
  local DlgGangBattlePrepare = require("Main.GangCross.ui.DlgGangCrossBattlePrepare")
  DlgGangBattlePrepare.Instance():ResetTime()
end
def.static("table").OnSStageBrd = function(p)
  instance.stage = p.stage
  instance:SetStage()
end
def.static("table").OnSSyncCompeteBrd = function(p)
  local faction1Id = p.faction1.factionid:tostring()
  local faction2Id = p.faction2.factionid:tostring()
  if instance.gangBattleInfo == nil then
    instance.gangBattleInfo = {}
    instance.gangBattleInfo[faction1Id] = {
      data = p.faction1
    }
    instance.gangBattleInfo[faction2Id] = {
      data = p.faction2
    }
  else
    instance.gangBattleInfo[faction1Id].data = p.faction1
    instance.gangBattleInfo[faction2Id].data = p.faction2
  end
  Event.DispatchEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.Gang_Battle_Info_Changed, nil)
end
def.static("table").OnSSyncAgainst = function(p)
  if instance.gangBattleInfo == nil then
    instance.gangBattleInfo = {}
    instance.gangBattleInfo[p.self_faction.factionid:tostring()] = {
      name = p.self_name,
      data = p.self_faction
    }
    instance.gangBattleInfo[p.opponent_faction.factionid:tostring()] = {
      name = p.opponent_name,
      data = p.opponent_faction
    }
  else
    local selfgang = instance.gangBattleInfo[p.self_faction.factionid:tostring()]
    selfgang.name = p.self_name
    if selfgang.data == nil then
      selfgang.data = p.self_faction
    end
    local oppogang = instance.gangBattleInfo[p.opponent_faction.factionid:tostring()]
    oppogang.name = p.opponent_name
    if oppogang.data == nil then
      oppogang.data = p.opponent_faction
    end
  end
  GangCrossData.Instance():SetGangCrossState(GangCrossData.BattleState.FIGHT)
  require("Main.GangCross.ui.DlgGangCrossBattlePrepare").Instance():Hide()
  require("Main.GangCross.ui.DlgGangCrossBattle").Instance():ShowDlg()
  Event.DispatchEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.Gang_Battle_Info_Changed, nil)
end
def.static("table", "table").OnNPCService = function(p1, p2)
end
def.method().SetStage = function(self)
end
def.static("table", "table").OnGetServerActivityPhaseTime = function(p1, p2)
  local activityId = p1[1]
  local stage = p1[2]
  if activityId == constant.CCompetitionConsts.GANG_BATTLE_ACTIVITYID and stage == SStageBrd.STG_PREPARE then
    local DlgGangBattlePrepare = require("Main.GangCross.ui.DlgGangCrossBattlePrepare")
    local nowSec = GetServerTime()
    local activityTime = p1[3]
    if nowSec < activityTime then
      local left = activityTime - nowSec
      DlgGangBattlePrepare.Instance():ShowDlg(left)
    else
      DlgGangBattlePrepare.Instance():Hide()
    end
  end
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  instance.targetPos = nil
  instance:ResetData()
end
def.method().ResetData = function(self)
  self.stage = -1
  self.actionPoint = 0
  self.gangBattleInfo = nil
  self.rivalGang = nil
  self.needGoToBattle = false
  self.gangIdMap = nil
  self.showTip = false
  self.preparePlayerNum = 0
end
def.static("table", "table").OnStatusChanged = function(p1, p2)
  local statusChanged = p1 and p1[1]
  if statusChanged == nil then
    return
  end
  local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if statusChanged.Check(RoleState.GANGCROSS_BATTLE) then
    local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
    if role:IsInState(RoleState.GANGCROSS_BATTLE) then
      pubMgr.enableSingleMode = false
      pubMgr:SetForceVisibleNum(75)
      Event.DispatchEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.ENTER_GANG_BATTLE_MAP, nil)
      GangCrossData.Instance():SetGangCrossState(GangCrossData.BattleState.PREPAIR)
      local DlgGangBattlePrepare = require("Main.GangCross.ui.DlgGangCrossBattlePrepare")
      DlgGangBattlePrepare.Instance():ShowDlg()
    else
      pubMgr.enableSingleMode = true
      pubMgr:SetForceVisibleNum(-1)
      instance:ResetData()
      GangCrossData.Instance():SetGangCrossState(GangCrossData.BattleState.NORMAL)
      GangCrossData.Instance():OnReset()
      Event.DispatchEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.LEAVE_GANG_BATTLE_MAP, nil)
      require("GUI.CommonCountDown").End()
      local dlgGangBattle = require("Main.GangCross.ui.DlgGangCrossBattle").Instance()
      dlgGangBattle:Hide()
      local DlgGangBattlePrepare = require("Main.GangCross.ui.DlgGangCrossBattlePrepare")
      DlgGangBattlePrepare.Instance():Hide()
    end
  end
  if statusChanged.Check(RoleState.PROTECTED) then
    if role:IsInState(RoleState.PROTECTED) then
      local protectBuff = require("Main.Buff.BuffMgr").Instance():GetBuff(constant.CCompetitionConsts.ProtectedBuff)
      if protectBuff then
        local now = _G.GetServerTime()
        local lefttime = Int64.ToNumber(protectBuff.remainValue - now)
        require("Main.GangCross.ui.DlgGangCrossBattle").Instance():SetProtectTime(lefttime)
      end
    else
      require("Main.GangCross.ui.DlgGangCrossBattle").Instance():SetProtectTime(0)
    end
  end
end
def.static("table", "table").OnSCrossCompeteTitle = function(role, p)
  if role == nil then
    warn("OnSCrossCompeteTitle role is nil")
    return
  end
  local roleIdStr = role.roleId:tostring()
  if p then
    if instance.gangIdMap == nil then
      instance.gangIdMap = {}
    end
    instance.gangIdMap[roleIdStr] = p.faction_id
    local colorId
    local gangId = GangCrossData.Instance().gangId
    if gangId == nil then
      gangId = p.faction_id
      GangCrossData.Instance():SetGangId(gangId)
    end
    if gangId == nil or p.faction_id:eq(gangId) then
      colorId = constant.CCompetitionConsts.FriendColour
    elseif role:IsInState(RoleState.PROTECTED) then
      colorId = constant.CCompetitionConsts.ProtectColour
    else
      colorId = constant.CCompetitionConsts.AttackColour
    end
    local dutyLv = GangUtility.GetDutyLv(p.faction_duty)
    local gangTitle = GangUtility.GetDutyNameByDutyLvAndCfgId(p.designed_titleid, dutyLv)
    role:SetShowTitle(gangTitle and p.faction_name .. gangTitle or p.faction_name, nil)
    local nameColor = GetColorData(colorId)
    role:SetName("", nameColor)
  else
    role:SetShowTitle("", nil)
    instance:RecoverRoleName(role)
  end
end
def.method("userdata").PKRole = function(self, roleId)
  local role = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRole(roleId)
  local myrole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if role and role:IsInState(RoleState.BATTLE) then
    Toast(textRes.Gang[217])
    return
  elseif role and role:IsInState(RoleState.PROTECTED) then
    Toast(textRes.Gang[218])
    return
  elseif myrole:IsInState(RoleState.PROTECTED) then
    Toast(textRes.Gang[220])
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.crosscompete.CAttackReq").new(roleId))
end
def.static("table").OnSSyncFactionPkScoreBrd = function(p)
  if instance.gangBattleInfo == nil then
    return
  end
  local gangInfo = instance.gangBattleInfo[p.factionid:tostring()]
  if gangInfo then
    gangInfo.data.pk_score = p.pk_score
    Event.DispatchEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.Gang_Battle_Info_Changed, nil)
  end
end
def.static("table").OnSSyncFactionPlayerScoreBrd = function(p)
  if instance.gangBattleInfo == nil then
    return
  end
  local gangInfo = instance.gangBattleInfo[p.factionid1:tostring()]
  local myGangId = GangCrossData.Instance().gangId
  if gangInfo then
    if myGangId and p.factionid1:eq(myGangId) then
      local delta = p.player_score1
      if gangInfo.data.player_score and gangInfo.data.player_score > 0 then
        delta = p.player_score1 - gangInfo.data.player_score
      end
      local tipStr = string.format(textRes.Gang[255], delta)
      Toast(tipStr)
      ChatModule.Instance():SendNoteMsg(tipStr, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
    end
    gangInfo.data.player_score = p.player_score1
  end
  gangInfo = instance.gangBattleInfo[p.factionid2:tostring()]
  if gangInfo then
    if myGangId and p.factionid2:eq(myGangId) then
      local delta = p.player_score2
      if gangInfo.data.player_score and gangInfo.data.player_score > 0 then
        delta = p.player_score2 - gangInfo.data.player_score
      end
      local tipStr = string.format(textRes.Gang[255], delta)
      Toast(tipStr)
      ChatModule.Instance():SendNoteMsg(tipStr, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
    end
    gangInfo.data.player_score = p.player_score2
  end
  Event.DispatchEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.Gang_Battle_Info_Changed, nil)
end
def.static("table").OnSSyncMercenaryScoreBrd = function(p)
  if instance.gangBattleInfo == nil then
    return
  end
  local gangInfo = instance.gangBattleInfo[p.mercenary_factionid:tostring()]
  local myGangId = GangCrossData.Instance().gangId
  if gangInfo then
    if myGangId and p.mercenary_factionid:eq(myGangId) then
      local delta = p.mercenary_score
      if gangInfo.data.mercenary_score and gangInfo.data.mercenary_score > 0 then
        delta = p.mercenary_score - gangInfo.data.mercenary_score
      end
      local tipStr = string.format(textRes.Gang[270], delta)
      Toast(tipStr)
      ChatModule.Instance():SendNoteMsg(tipStr, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
    end
    gangInfo.data.mercenary_score = p.mercenary_score
    Event.DispatchEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.Gang_Battle_Info_Changed, nil)
  end
end
def.static("table").OnSSyncFactionPlayerNumberBrd = function(p)
  local factionId = p.factionid:tostring()
  if instance.gangBattleInfo == nil then
    instance.preparePlayerNum = p.player_num
    Event.DispatchEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.Gang_Battle_Prepare_Player_Changed, nil)
    return
  end
  local gangInfo = instance.gangBattleInfo[factionId]
  if gangInfo then
    gangInfo.data.player_number = p.player_num
    Event.DispatchEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.Gang_Battle_Info_Changed, nil)
  else
    warn("[OnSSyncFactionPlayerNumberBrd]gangInfo is nil : ", factionId)
  end
end
def.static("table").OnSAgainstFactionRes = function(p)
  instance.rivalGang = p
  Event.DispatchEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.Gang_Battle_Rival_Changed, nil)
  if instance.needGoToBattle then
    instance.needGoToBattle = false
    instance:DoGotoGangBattle()
  end
end
def.static("table").OnSGainPreciousItemsBrd = function(p)
  local tipStr = string.format(textRes.Gang[215], p.faction, p.name)
  local itemStr = {}
  for k, v in pairs(p.items) do
    local itemBase = ItemUtils.GetItemBase(k)
    if itemBase then
      local tip = "[" .. HtmlHelper.NameColor[itemBase.namecolor] .. "]" .. itemBase.name .. "\195\151" .. v .. "[-]"
      table.insert(itemStr, tip)
    end
  end
  local content = tipStr .. table.concat(itemStr, "\239\188\140")
  local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
  if ItemUtils.GetAwardBulletinType(p.items) == BulletinType.UNUSUAL then
    require("GUI.RareItemAnnouncementTip").AnnounceRareItem(content)
  else
    require("GUI.AnnouncementTip").Announce(content)
  end
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = content})
end
def.method("userdata", "=>", "number").IsRival = function(self, roleId)
  if roleId == nil then
    return -1
  end
  local state = GangCrossData.Instance():GetGangCrossState()
  if state == GangCrossData.BattleState.PREPAIR then
    return 0
  end
  local roleIdStr = roleId:tostring()
  local gangId = self.gangIdMap and self.gangIdMap[roleIdStr]
  if gangId == nil then
    return -1
  end
  local myGangId = GangCrossData.Instance().gangId
  if myGangId == nil then
    return 1
  end
  if gangId:eq(myGangId) then
    return 0
  else
    return 1
  end
end
def.static("table").OnSWinFightBrd = function(p)
  local tipStr = string.format(textRes.GangCross[24], p.winner_leader, tostring(p.winner_number), p.loser_leader, tostring(p.loser_number), tostring(p.score))
  ChatModule.Instance():SendNoteMsg(tipStr, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
end
def.static("table").OnSDeductActionPointNotify = function(p)
  instance.actionPoint = instance.actionPoint - p.deduct_value
  if p.deduct_value == 0 then
    return
  end
  local str
  if p.reason == p.REASON__ENTER_LATER then
    str = textRes.Gang[224]
  elseif p.reason == p.REASON__ATTACK then
    str = textRes.Gang[225]
  elseif p.reason == p.REASON__LOSE_FIGHT then
    str = textRes.Gang[226]
  elseif p.reason == p.REASON__ESCAPE_FIGHT then
    str = textRes.Gang[227]
  end
  if str then
    Toast(string.format(str, p.deduct_value))
  end
  local dlg = require("Main.GangCross.ui.DlgGangCrossBattle").Instance()
  dlg:SetActionPoint()
end
def.static("table").OnSWinLoseBrd = function(p)
  local tipStr
  local myGangId = GangCrossData.Instance().gangId
  local isWinner = myGangId:eq(p.winner_id)
  if p.result == p.RESULT__GIVE_UP then
    if isWinner then
      local giftCount = constant.GangCrossConsts.WinnerFactionGift
      local gangMoney = constant.GangCrossConsts.WinnerFactionMoney
      tipStr = string.format(textRes.GangCross[25], p.loser_name, giftCount, gangMoney)
    else
      tipStr = textRes.GangCross[26]
    end
  elseif p.result == p.RESULT__EARLY or p.result == p.RESULT__TIMEOUT then
    if isWinner then
      local giftCount = constant.GangCrossConsts.WinnerFactionGift
      local gangMoney = constant.GangCrossConsts.WinnerFactionMoney
      tipStr = string.format(textRes.GangCross[22], p.loser_name, giftCount, gangMoney)
    else
      local giftCount = constant.GangCrossConsts.LoserFactionGift
      local gangMoney = constant.GangCrossConsts.LoserFactionMoney
      tipStr = string.format(textRes.GangCross[23], p.winner_name, giftCount, gangMoney)
    end
  end
  if tipStr then
    Toast(tipStr)
    ChatModule.Instance():SendNoteMsg(tipStr, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
  end
  if isWinner then
    local delay_seconds = constant.GangCrossConsts.TriggerMapItemSeconds
    local left = Seconds2HMSTime(delay_seconds)
    local tipStr = string.format(textRes.Gang[216], left.m, left.s)
    Toast(tipStr)
    require("GUI.CommonCountDown").Start(delay_seconds)
  end
end
def.static("table").OnSBothGiveUpBrd = function(p)
  local myGangId = GangCrossData.Instance().gangId
  if myGangId and (myGangId:eq(p.id1) or myGangId:eq(p.id2)) then
    ChatModule.Instance():SendNoteMsg(textRes.GangCross[26], ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
  end
end
def.static("table").OnSWinStreakBrd = function(p)
  local str = string.format(textRes.Gang[230], p.name, tostring(p.win_streak))
  ChatModule.Instance():SendNoteMsg(str, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
end
def.static("table").OnSRecallMercenaryBrd = function(p)
  local myGangId = GangCrossData.Instance().gangId
  local str = ""
  if myGangId and myGangId:eq(p.mercenary_factionid) then
    str = string.format(textRes.Gang[271], p.mercenary_count)
  else
    str = string.format(textRes.Gang[276], p.mercenary_count)
  end
  ChatModule.Instance():SendNoteMsg(str, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
end
def.static("table").OnSCompeteResultBrd = function(p)
  local gangInfo1 = p.win_faction
  local gangInfo2 = p.lose_faction
  local myGangId = require("Main.Gang.data.GangData").Instance().gangId
  if gangInfo1.self_server > 0 then
    local svrname = GangCrossUtility.Instance():GetSvrNameForGangId(gangInfo2.factionid)
    local msgInfo = string.format(textRes.GangCross[29], gangInfo1.name, svrname or "", gangInfo2.name)
    require("GUI.AnnouncementTip").Announce(msgInfo)
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = msgInfo})
    if myGangId and myGangId:eq(gangInfo1.factionid) then
      local giftCount = constant.GangCrossConsts.WinnerFactionGift
      local gangMoney = constant.GangCrossConsts.WinnerFactionMoney
      local str = string.format(textRes.GangCross[32], svrname, gangInfo2.name, giftCount, gangMoney)
      ChatModule.Instance():SendNoteMsg(str, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
    end
  end
  if gangInfo2.self_server > 0 then
    local svrname = GangCrossUtility.Instance():GetSvrNameForGangId(gangInfo1.factionid)
    local msgInfo = string.format(textRes.GangCross[30], gangInfo2.name, svrname or "", gangInfo1.name)
    require("GUI.AnnouncementTip").Announce(msgInfo)
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = msgInfo})
    if myGangId and myGangId:eq(gangInfo2.factionid) then
      local giftCount = constant.GangCrossConsts.LoserFactionGift
      local gangMoney = constant.GangCrossConsts.LoserFactionMoney
      local str = string.format(textRes.GangCross[33], svrname, gangInfo1.name, giftCount, gangMoney)
      ChatModule.Instance():SendNoteMsg(str, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
    end
  end
end
def.method("table").RecoverRoleName = function(self, role)
  local nameColor = GetColorData(701300001)
  role:SetName("", nameColor)
  role:SetShowTitle("", nil)
end
def.method("table").SetNormalRoleName = function(self, role)
  if role == nil then
    return
  end
  local color
  if role:IsInState(RoleState.GANGCROSS_BATTLE) and self:IsRival(role.roleId) > 0 then
    color = GetColorData(constant.CCompetitionConsts.AttackColour)
  else
    color = GetColorData(constant.CCompetitionConsts.FriendColour)
  end
  if color then
    role:SetName("", color)
  end
end
def.method("table").SetProtectRoleName = function(self, role)
  if role and role:IsInState(RoleState.GANGCROSS_BATTLE) then
    local nameColor = GetColorData(constant.CCompetitionConsts.ProtectColour)
    role:SetName("", nameColor)
  end
end
def.static("table").OnSGetRoleInfoRes = function(data)
  if instance.gangIdMap == nil then
    instance.gangIdMap = {}
  end
  instance.gangIdMap[data.roleId:tostring()] = data.gangId
  local isRival = true
  local myGangId = GangCrossData.Instance().gangId
  if myGangId then
    isRival = not myGangId:eq(data.gangId)
  end
  if isRival then
    instance:PKRole(data.roleId)
  end
end
def.static().GoToNpc = function()
  if instance.targetPos == nil then
    return
  end
  local mapModule = gmodule.moduleMgr:GetModule(ModuleId.MAP)
  local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local myRole = heroMgr.myRole
  if myRole == nil then
    return
  end
  local pos = myRole:GetPos()
  if instance.targetPos and (pos.x ~= instance.targetPos.x or pos.y ~= instance.targetPos.y) then
    heroMgr.needShowAutoEffect = true
    heroMgr:MoveTo(0, instance.targetPos.x, instance.targetPos.y, 0, instance.targetPos.distance, MoveType.AUTO, nil)
  end
  instance.targetPos = nil
end
def.method().DoGotoGangBattle = function(self)
  if self.rivalGang and (self.rivalGang.faction_id == nil or self.rivalGang.faction_id:ToNumber() <= 0) then
    require("GUI.CommonUITipsDlg").ShowCommonTip(textRes.Gang[267], {x = 0, y = 0})
    return
  end
  local myRole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if myRole:IsInState(RoleState.UNTRANPORTABLE) then
    Toast(textRes.Gang[242])
    return
  end
  local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  if pubMgr:IsInFollowState(myRole.roleId) == true then
    Toast(textRes.Hero[46])
    return
  end
  if pubMgr:IsInWedding() then
    Toast(textRes.Hero[55])
    return
  end
  if pubMgr:IsInWeddingParade() then
    Toast(textRes.Hero[61])
    return
  end
  warn("------------------GotoGangMapNPC")
end
def.method().GotoGangBattle = function(self)
  if GangCrossData.Instance():GetGangId() == nil then
    Toast(textRes.Gang[45])
    return
  end
  local state = require("Main.activity.ActivityInterface").GetActivityState(constant.CCompetitionConsts.GANG_BATTLE_ACTIVITYID)
  if state < 0 then
    Toast(textRes.activity[51])
    return
  end
  if self.rivalGang == nil then
    self.needGoToBattle = true
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.competition.CAgainstFactionReq").new())
  else
    self:DoGotoGangBattle()
  end
end
def.method("number").GotoGangMapNPC = function(self, NPCID)
  local NPCInterface = require("Main.npc.NPCInterface")
  local npcInterface = NPCInterface.Instance()
  local npcCfg = NPCInterface.GetNPCCfg(NPCID)
  if npcCfg == nil then
    return
  end
  npcInterface:SetTargetNPCID(NPCID)
  self:GotoGangMapPos(npcCfg.x, npcCfg.y)
end
def.method("number", "number").GotoGangMapPos = function(self, targetX, targetY)
  warn("-----------------GotoGangMapPos")
end
def.static().CloseLoadingPanel = function()
  require("Main.GangCross.ui.GangCrossLoadingPanel").Instance():HidePanel()
end
def.static("table", "table").OnChangeMap = function(p1, p2)
  local mapid = p1[1]
  local oldMapId = p1[2]
  if mapid and (mapid == constant.GangCrossConsts.PrepareMap or mapid == constant.GangCrossConsts.FightMap) then
    require("Main.GangCross.ui.GangCrossLoadingPanel").Instance():HidePanel()
  end
end
def.static("table", "table").OnActivityEnd = function(p1, p2)
  local activityId = p1[1]
  if activityId == constant.GangCrossConsts.Activityid then
    instance:ResetData()
  end
end
GangCrossBattleMgr.Commit()
return GangCrossBattleMgr
