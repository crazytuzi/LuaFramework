local Lplus = require("Lplus")
local TeamDungeonMgr = Lplus.Class("TeamDungeonMgr")
local DungeonUtils = require("Main.Dungeon.DungeonUtils")
local DungeonModule = Lplus.ForwardDeclare("DungeonModule")
local TeamDungeonType = require("consts.mzm.gsp.instance.confbean.InstanceDisType")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local def = TeamDungeonMgr.define
def.field("table").roles = nil
def.field("table").teamRoles = nil
def.method().Init = function(self)
end
def.method().Reset = function(self)
  self.roles = nil
  self.teamRoles = nil
  if DungeonModule.Instance().State == DungeonModule.DungeonState.TEAM then
    Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, TeamDungeonMgr.OnEnterFight)
    Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, TeamDungeonMgr.OnLeaveFight)
  end
end
def.static("table", "boolean").HandleActivitySwitch = function(dungeons, open)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local teamDungeons = DungeonUtils.GetDungeonByType(TeamDungeonType.NORMAL)
  for k, v in ipairs(dungeons) do
    if v.activityid then
      if open then
        ActivityInterface.Instance():removeCustomCloseActivity(v.activityid)
      else
        ActivityInterface.Instance():addCustomCloseActivity(v.activityid)
      end
    end
  end
end
def.static("table", "table").OnFeatureChange = function(p1, p2)
  if p1.feature == ModuleFunSwitchInfo.TYPE_NORMAL_INSTANCE then
    local dlg = require("Main.Dungeon.ui.DungeonAsk").Instance()
    if dlg:IsShow() and dlg.type == TeamDungeonType.NORMAL then
      local open = p1.open
      local desc2 = textRes.Dungeon[43]
      if open then
        desc2 = textRes.Dungeon[44]
      end
      dlg:UpdateDesc2(desc2)
    end
  elseif p1.feature == ModuleFunSwitchInfo.TYPE_JUQINGFUBEN_NORMAL then
    local dungeonOpen = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_JUQINGFUBEN)
    local teamDungeons = DungeonUtils.GetDungeonByType(TeamDungeonType.NORMAL)
    TeamDungeonMgr.HandleActivitySwitch(teamDungeons, dungeonOpen and p1.open)
  elseif p1.feature == ModuleFunSwitchInfo.TYPE_JUQINGFUBEN_ELITE then
    local dungeonOpen = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_JUQINGFUBEN)
    local teamDungeons = DungeonUtils.GetDungeonByType(TeamDungeonType.ELITE)
    TeamDungeonMgr.HandleActivitySwitch(teamDungeons, dungeonOpen and p1.open)
  elseif p1.feature == ModuleFunSwitchInfo.TYPE_JUQINGFUBEN_HERO then
    local dungeonOpen = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_JUQINGFUBEN)
    local teamDungeons = DungeonUtils.GetDungeonByType(TeamDungeonType.HERO)
    TeamDungeonMgr.HandleActivitySwitch(teamDungeons, dungeonOpen and p1.open)
  elseif p1.feature == ModuleFunSwitchInfo.TYPE_JUQINGFUBEN_NIGHTMARE then
    local dungeonOpen = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_JUQINGFUBEN)
    local teamDungeons = DungeonUtils.GetDungeonByType(TeamDungeonType.NIGHTMARE)
    TeamDungeonMgr.HandleActivitySwitch(teamDungeons, dungeonOpen and p1.open)
  elseif p1.feature == ModuleFunSwitchInfo.TYPE_JUQINGFUBEN_ACTIVITY then
    local dungeonOpen = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_JUQINGFUBEN)
    local teamDungeons = DungeonUtils.GetDungeonByType(TeamDungeonType.ACTIVITY)
    TeamDungeonMgr.HandleActivitySwitch(teamDungeons, dungeonOpen and p1.open)
  elseif p1.feature == ModuleFunSwitchInfo.TYPE_JUQINGFUBEN then
    for k, v in pairs(TeamDungeonType) do
      local open = DungeonModule.Instance().teamMgr:CheckOpen(v)
      local teamDungeons = DungeonUtils.GetDungeonByType(v)
      TeamDungeonMgr.HandleActivitySwitch(teamDungeons, p1.open and open)
    end
  end
end
def.static("table", "table").OnFeatureInit = function()
  local dungeonOpen = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_JUQINGFUBEN)
  for k, v in pairs(TeamDungeonType) do
    local open = DungeonModule.Instance().teamMgr:CheckOpen(v)
    local teamDungeons = DungeonUtils.GetDungeonByType(v)
    TeamDungeonMgr.HandleActivitySwitch(teamDungeons, dungeonOpen and open)
  end
end
def.static("table").onLeaveTimer = function(p)
  local dungeonId = p.instanceCfgid
  local DungeonTip = require("Main.Dungeon.ui.DungeonTip")
  if dungeonId == DungeonModule.Instance().CurDungeon then
    DungeonTip.Instance():DungeonEnd()
  end
end
def.static("table").onDungeonReward = function(p)
  local rewardPanel = require("Main.Dungeon.ui.TeamDungeonReward")
  if rewardPanel.Instance().finish then
    rewardPanel.ShowReward(p.awardUuid, p.itemid, p.roles)
    DungeonModule.Instance().teamMgr.roles = {}
    for k, v in ipairs(p.roles) do
      DungeonModule.Instance().teamMgr.roles[v.roleid:tostring()] = v.roleName
    end
  else
    GameUtil.AddGlobalTimer(1, true, function()
      TeamDungeonMgr.onDungeonReward(p)
    end)
  end
end
def.static("table").onDungeonRewardBroadCast = function(p)
  local AnnouncementTip = require("GUI.AnnouncementTip")
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local ChatMsgBuilder = require("Main.Chat.ChatMsgBuilder")
  local ItemUtils = require("Main.Item.ItemUtils")
  local roleName = ChatMsgBuilder.Unmarshal(p.role_name)
  local itemId = p.item_cfg_id
  local itemBase = ItemUtils.GetItemBase(itemId)
  if roleName and itemBase then
    local dungeonId = p.instance_cfg_id
    local dungeonCfg = DungeonUtils.GetDungeonCfg(dungeonId)
    local dungeonName = dungeonCfg and dungeonCfg.name or ""
    local itemName = itemBase.name
    local str = string.format(textRes.AnnounceMent[91], roleName, dungeonName, HtmlHelper.NameColor[itemBase.namecolor], itemName)
    AnnouncementTip.Announce(str)
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
  end
end
def.static("table").onSGetOrRefuseItemRes = function(p)
  local rewardPanel = require("Main.Dungeon.ui.TeamDungeonReward")
  if rewardPanel.Instance().m_panel then
    rewardPanel.Instance():SetRoleRes(p)
  end
end
def.static("table").onRollRes = function(p)
  local rewardPanel = require("Main.Dungeon.ui.TeamDungeonReward")
  if rewardPanel.Instance().m_panel then
    rewardPanel.Instance():SetFinalRes(p)
  end
  local myRoleId = require("Main.Hero.HeroModule").Instance().roleId
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(p.itemid)
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local tip
  if p.roleid == myRoleId then
    tip = string.format(textRes.Dungeon[17], HtmlHelper.NameColor[itemBase.namecolor], itemBase.name)
  elseif DungeonModule.Instance().teamMgr.roles ~= nil then
    local name = DungeonModule.Instance().teamMgr.roles[p.roleid:tostring()]
    if name ~= nil then
      tip = string.format(textRes.Dungeon[18], name, HtmlHelper.NameColor[itemBase.namecolor], itemBase.name)
    end
  end
  if tip then
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    require("Main.Chat.ChatModule").Instance():SendNoteMsg(tip, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.TEAM)
  end
end
def.static("table").onWaitEnterDungeon = function(p)
  local teamData = require("Main.Team.TeamData")
  local members = teamData.Instance():GetAllTeamMembers()
  local roles = {}
  local leaderId
  for k, v in ipairs(members) do
    if k == 1 then
      leaderId = v.roleid
    end
    local role = {}
    role.roleName = v.name
    role.occupation = v.menpai
    role.gender = v.gender
    role.roleid = v.roleid
    role.avatarId = v.avatarId
    role.avatarFrameId = v.avatarFrameid
    table.insert(roles, role)
  end
  local dungeonId = p.teamInfo.instanceCfgid
  local processId = p.teamInfo.toProcess
  local dungeonCfg = DungeonUtils.GetDungeonCfg(dungeonId)
  local teamDungeonCfg = DungeonUtils.GetTeamDungeonCfg(dungeonId)
  local title = string.format(textRes.Dungeon[41], dungeonCfg.name, dungeonCfg.level, textRes.Dungeon.TeamDungeonTypeName[teamDungeonCfg.type])
  local des = ""
  if leaderId == require("Main.Hero.HeroModule").Instance().roleId then
    des = textRes.Dungeon[19]
  else
    local dungeonInfo = DungeonModule.Instance():GetTeamDungeonInfo(dungeonId)
    local mProcess = dungeonInfo and dungeonInfo.toProcess or 0
    if processId == mProcess then
      des = textRes.Dungeon[20]
    else
      des = string.format(textRes.Dungeon[21], processId, mProcess)
    end
  end
  local desc2 = textRes.Dungeon[43]
  if IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_NORMAL_INSTANCE) and teamDungeonCfg.type == TeamDungeonType.NORMAL then
    desc2 = textRes.Dungeon[44]
  end
  local DungeonAsk = require("Main.Dungeon.ui.DungeonAsk")
  DungeonAsk.ShowAsk(title, des, desc2, roles, leaderId, teamDungeonCfg.type)
  DungeonModule.Instance().teamMgr.teamRoles = roles
end
def.method("number", "=>", "boolean").CheckOpen = function(self, dungeonType)
  local openId
  if dungeonType == TeamDungeonType.NORMAL then
    openId = ModuleFunSwitchInfo.TYPE_JUQINGFUBEN_NORMAL
  elseif dungeonType == TeamDungeonType.ELITE then
    openId = ModuleFunSwitchInfo.TYPE_JUQINGFUBEN_ELITE
  elseif dungeonType == TeamDungeonType.HERO then
    openId = ModuleFunSwitchInfo.TYPE_JUQINGFUBEN_HERO
  elseif dungeonType == TeamDungeonType.NIGHTMARE then
    openId = ModuleFunSwitchInfo.TYPE_JUQINGFUBEN_NIGHTMARE
  elseif dungeonType == TeamDungeonType.ACTIVITY then
    openId = ModuleFunSwitchInfo.TYPE_JUQINGFUBEN_ACTIVITY
  end
  if openId then
    local open = IsFeatureOpen(openId)
    return open
  else
    return false
  end
end
def.method("boolean").ConfirmDungeon = function(self, confirm)
  local CRefuseOrAgreeTeamInstanceReq = require("netio.protocol.mzm.gsp.instance.CRefuseOrAgreeTeamInstanceReq")
  if confirm then
    local agree = CRefuseOrAgreeTeamInstanceReq.new(CRefuseOrAgreeTeamInstanceReq.Agree)
    gmodule.network.sendProtocol(agree)
  else
    local deny = CRefuseOrAgreeTeamInstanceReq.new(CRefuseOrAgreeTeamInstanceReq.Deny)
    gmodule.network.sendProtocol(deny)
  end
end
def.static("table").onMemberEnterDungeon = function(p)
  local CRefuseOrAgreeTeamInstanceReq = require("netio.protocol.mzm.gsp.instance.CRefuseOrAgreeTeamInstanceReq")
  local DungeonAsk = require("Main.Dungeon.ui.DungeonAsk")
  if CRefuseOrAgreeTeamInstanceReq.Agree == p.operation then
    DungeonAsk.Instance():SetRoleReady(p.roleid)
  elseif CRefuseOrAgreeTeamInstanceReq.Deny == p.operation then
    local name = p.roleName
    local tip = string.format(textRes.Dungeon[23], name)
    Toast(tip)
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    require("Main.Chat.ChatModule").Instance():SendNoteMsg(tip, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.TEAM)
    DungeonAsk.CloseAsk()
  end
end
def.static("table", "table").onTeamDungeonService = function(p1, p2)
  local npcId = p1[2]
  local serviceId = p1[1]
  if serviceId == require("Main.npc.NPCServiceConst").TeamDungeon then
    local dungeonOpen = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_JUQINGFUBEN)
    if not dungeonOpen then
      Toast(textRes.Dungeon[48])
      return
    end
    local TeamDungeonDlg = require("Main.Dungeon.ui.TeamDungeonDlg")
    TeamDungeonDlg.ShowTeamDungeon(TeamDungeonType.NORMAL, 0)
  end
end
def.static("table", "table").onTeamDungeonTargetService = function(p1, p2)
  local serviceId = p1[1]
  local npcId = p1[2]
  local params = p1[3]
  if serviceId == require("Main.npc.NPCServiceConst").TeamDungeon then
    local TeamDungeonDlg = require("Main.Dungeon.ui.TeamDungeonDlg")
    TeamDungeonDlg.ShowTeamDungeon(params[1], params[2])
  end
end
def.method("number").FightTeamDungeon = function(self, id)
  local dungeonCfg = DungeonUtils.GetDungeonCfg(id)
  local teamDungeonCfg = DungeonUtils.GetTeamDungeonCfg(id)
  if teamDungeonCfg == nil then
    return
  end
  local open = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_JUQINGFUBEN)
  if not open then
    Toast(textRes.Dungeon[48])
    return
  end
  if not self:CheckOpen(teamDungeonCfg.type) then
    Toast(textRes.Dungeon[46])
    return
  end
  local teamData = require("Main.Team.TeamData")
  local teamLimit = DungeonUtils.GetDungeonCfg(id).memberCount
  if not teamData.Instance():HasTeam() then
    if dungeonCfg.closeLevel > 0 then
      Toast(string.format(textRes.Dungeon[51], dungeonCfg.level, dungeonCfg.closeLevel, teamLimit))
    else
      Toast(string.format(textRes.Dungeon[14], dungeonCfg.level, teamLimit))
    end
    return
  end
  if not teamData.Instance():MeIsCaptain() then
    Toast(textRes.Dungeon[15])
    return
  end
  if teamLimit > teamData.Instance():GetMemberCount() then
    if dungeonCfg.closeLevel > 0 then
      Toast(string.format(textRes.Dungeon[51], dungeonCfg.level, dungeonCfg.closeLevel, teamLimit))
    else
      Toast(string.format(textRes.Dungeon[14], dungeonCfg.level, teamLimit))
    end
    return
  end
  local allMember = teamData.Instance():GetAllTeamMembers()
  local nameList = {}
  for k, v in ipairs(allMember) do
    if v.level < dungeonCfg.level then
      table.insert(nameList, v.name)
    end
  end
  if #nameList > 0 then
    local nameListStr = table.concat(nameList, ",")
    Toast(string.format(textRes.Dungeon[42], nameListStr, dungeonCfg.level))
    return
  end
  if dungeonCfg.closeLevel > 0 then
    local leader = allMember[1]
    if leader and leader.level > dungeonCfg.closeLevel then
      Toast(string.format(textRes.Dungeon[49], dungeonCfg.closeLevel))
      return
    end
  end
  local dungeonInfo = DungeonModule.Instance():GetTeamDungeonInfo(id)
  local finishTimes = dungeonInfo and dungeonInfo.finishTimes or 0
  if finishTimes >= dungeonCfg.finishLimit then
    if teamDungeonCfg.type == TeamDungeonType.NORMAL then
      Toast(textRes.Dungeon[26])
    elseif teamDungeonCfg.type == TeamDungeonType.ELITE then
      Toast(textRes.Dungeon[39])
    else
      Toast(textRes.Dungeon[47])
    end
    return
  end
  if DungeonModule.Instance().State == DungeonModule.DungeonState.OUT then
    local challengeDungeon = require("netio.protocol.mzm.gsp.instance.CChallengeTeamInstanceReq").new(id)
    gmodule.network.sendProtocol(challengeDungeon)
  else
    Toast(textRes.Dungeon[7])
  end
end
def.method("userdata", "number", "number").RollItem = function(self, uuid, itemId, operation)
  local roll = require("netio.protocol.mzm.gsp.instance.CGetOrRefuseItemReq").new(uuid, itemId, operation)
  gmodule.network.sendProtocol(roll)
end
def.method().OnEnterTeamDungeon = function(self)
  local DungeonTip = require("Main.Dungeon.ui.DungeonTip")
  local dungeonId = DungeonModule.Instance().CurDungeon
  local teamInfo = DungeonModule.Instance():GetTeamDungeonInfo(dungeonId)
  local curProcess = teamInfo and teamInfo.curProcess or 1
  local teamProcessCfg = DungeonUtils.GetTeamDungeonProcessCfg(dungeonId, curProcess)
  local DungeonAsk = require("Main.Dungeon.ui.DungeonAsk")
  DungeonAsk.CloseAsk()
  local TeamDungeonDlg = require("Main.Dungeon.ui.TeamDungeonDlg")
  TeamDungeonDlg.CloseTeamDungeon()
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, TeamDungeonMgr.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, TeamDungeonMgr.OnLeaveFight)
  Event.DispatchEvent(ModuleId.DUNGEON, gmodule.notifyId.Dungeon.ENTER_TEAM_DUNGEON, nil)
  local CommonActivityPanel = require("GUI.CommonActivityPanel")
  CommonActivityPanel.Instance():ShowActivityPanel(false, true, nil, nil, function()
    local TeamData = require("Main.Team.TeamData")
    local teamData = TeamData.Instance()
    if teamData:HasTeam() and not teamData:MeIsCaptain() then
      Toast(textRes.Dungeon[40])
      return
    end
    DungeonModule.Instance():LeaveDungeon()
  end, nil, true, CommonActivityPanel.ActivityType.TeamDungeon)
end
def.static("table").UpdateDungeonTip = function(p)
  if DungeonModule.Instance().State == DungeonModule.DungeonState.TEAM then
    local curProcess = p.curProcess
    local DungeonTip = require("Main.Dungeon.ui.DungeonTip")
    local dungeonId = DungeonModule.Instance().CurDungeon
    local teamProcessCfg = DungeonUtils.GetTeamDungeonProcessCfg(dungeonId, curProcess)
    DungeonTip.Instance():SetTitle(teamProcessCfg.title)
    DungeonTip.Instance():SetDesc(teamProcessCfg.desc)
    DungeonTip.Instance():SetTime(-1)
    DungeonTip.ShowDungeoTip()
  end
end
def.method().OnLeaveTeamDungeon = function(self)
  local DungeonTip = require("Main.Dungeon.ui.DungeonTip")
  DungeonTip.CloseDungeonTip()
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, TeamDungeonMgr.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, TeamDungeonMgr.OnLeaveFight)
  Event.DispatchEvent(ModuleId.DUNGEON, gmodule.notifyId.Dungeon.LEAVE_TEAM_DUNGEON, nil)
  local CommonActivityPanel = require("GUI.CommonActivityPanel")
  CommonActivityPanel.Instance():HidePanel(CommonActivityPanel.ActivityType.TeamDungeon)
end
def.method().OnProcessUpdate = function(self)
end
def.static("table", "table").OnEnterFight = function()
  local DungeonTip = require("Main.Dungeon.ui.DungeonTip")
  DungeonTip.CloseDungeonTip()
end
def.static("table", "table").OnLeaveFight = function()
  if DungeonModule.Instance().State == DungeonModule.DungeonState.TEAM then
    local DungeonTip = require("Main.Dungeon.ui.DungeonTip")
    DungeonTip.ShowDungeoTip()
  end
end
TeamDungeonMgr.Commit()
return TeamDungeonMgr
