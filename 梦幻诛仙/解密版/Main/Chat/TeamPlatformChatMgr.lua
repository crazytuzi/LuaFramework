local Lplus = require("Lplus")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local MainUIChat = require("Main.MainUI.ui.MainUIChat")
local TeamPlatformChatMgr = Lplus.Class("TeamPlatformChatMgr")
local def = TeamPlatformChatMgr.define
def.const("number").QUICKTIMERRATE = 2
def.const("number").SLOWTIMERRATE = 9
def.const("number").QUICKGETLIMIT = 1
def.field("number").quickTimer = 0
def.field("number").slowTimer = 0
def.const("number").DEFAULTMAX = 5
def.field("table").teamInfos = nil
def.method().Init = function(self)
  self.teamInfos = {}
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.teamplatform.SSynTeamNumInfo", TeamPlatformChatMgr.onTeamChange)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.Chat_Apply_Team, TeamPlatformChatMgr.OnChatApplyTeam)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, TeamPlatformChatMgr.OnRoleLvUp)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, TeamPlatformChatMgr.OnRoleLvUp)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_JOIN_TEAM, TeamPlatformChatMgr.OnJoinTeam)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_CREATE_TEAM, TeamPlatformChatMgr.OnJoinTeam)
end
def.method().Reset = function(self)
  self.teamInfos = {}
end
def.static("table").onTeamChange = function(p)
  local self = ChatModule.Instance().teamPlatformChatMgr
  local teamInfo = p.newTemInfo
  local leaderId = teamInfo.leaderId:tostring()
  local teamId = teamInfo.teamId:tostring()
  local data = self.teamInfos[leaderId]
  if not data then
    data = {}
    data.time = GetServerTime()
    self.teamInfos[leaderId] = data
  end
  data.id = leaderId
  data.teamId = teamId
  data.minLv = teamInfo.level.levelLow
  data.maxLv = teamInfo.level.levelHigh
  data.num = teamInfo.num
  data.maxNum = TeamPlatformChatMgr.DEFAULTMAX
  data.name = require("Main.TeamPlatform.TeamPlatformUtils").GetMatchName(teamInfo.activityCfg)
  data.leaderName = teamInfo.teamLeaderName or ""
  data.leaderLevel = teamInfo.teamLeaderLevel or teamInfo.level.levelHigh
  data.leaderOccupation = teamInfo.teamLeaderOccupation or 1
  data.leaderGender = teamInfo.teamLeaderSex or 1
  data.leaderAvatarId = teamInfo.avatarId
  data.leaderAvatarFrameId = teamInfo.avatarFrameId
  data.bubbleId = teamInfo.chatBubbleCfgId
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.TeamPlatform_Change, {data})
  if data.num == 0 or data.num == data.maxNum then
    self.teamInfos[leaderId] = nil
  end
end
def.static("table", "table").OnJoinTeam = function(p1, p2)
  local self = ChatModule.Instance().teamPlatformChatMgr
  local badTeams = {}
  for k, v in pairs(self.teamInfos) do
    v.num = 0
    table.insert(badTeams, v)
  end
  if #badTeams > 0 then
    for k, v in ipairs(badTeams) do
      self.teamInfos[v.id] = nil
    end
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.TeamPlatform_Change, badTeams)
  end
end
def.static("table", "table").OnRoleLvUp = function(p1, p2)
  local self = ChatModule.Instance().teamPlatformChatMgr
  local badTeams = {}
  local curLevel = p1.level
  for k, v in pairs(self.teamInfos) do
    if curLevel > v.maxLv then
      v.num = 0
      table.insert(badTeams, v)
    end
  end
  if #badTeams > 0 then
    for k, v in ipairs(badTeams) do
      self.teamInfos[v.id] = nil
    end
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.TeamPlatform_Change, badTeams)
  end
end
def.static("table", "table").OnChatApplyTeam = function(p1, p2)
  local DungeonModule = require("Main.Dungeon.DungeonModule")
  if DungeonModule.Instance().State == DungeonModule.DungeonState.SOLO then
    Toast(textRes.Dungeon[45])
    return
  end
  local teamIdStr = p1[1]
  local teamId = Int64.new(teamIdStr)
  local TeamModule = require("Main.Team.TeamModule")
  TeamModule.Instance():TeamPlatformApplyTeam(teamId)
end
TeamPlatformChatMgr.Commit()
return TeamPlatformChatMgr
