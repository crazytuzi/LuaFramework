local isDebug = false
local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local TeamPlatformMgr = Lplus.Class("TeamPlatformMgr")
local TeamModule = require("Main.Team.TeamModule")
local TeamData = require("Main.Team.TeamData")
local TeamPlatformUtils = require("Main.TeamPlatform.TeamPlatformUtils")
local ActivityInterface = require("Main.activity.ActivityInterface")
local ActivityType = require("consts.mzm.gsp.activity.confbean.ActivityType")
local SSynMatchState = require("netio.protocol.mzm.gsp.teamplatform.SSynMatchState")
local HeroInterface = require("Main.Hero.Interface")
local json = require("Utility.json")
local def = TeamPlatformMgr.define
local CResult = {
  SUCCESS = 0,
  ONLY_TEAM_LEADER_APPROVED = 1,
  TEAM_MEMBERS_REACHED_MAX = 2,
  CAN_NOT_REMATCH = 3,
  MATCH_TOO_FREQUENT = 4,
  NOT_IN_MATCH = 5,
  HAVE_NOT_MATCH = 6,
  FAILED_IN_CHAT = 7
}
def.const("table").CResult = CResult
def.const("table").MatchRange = {
  First = 1,
  Second = 2,
  AidNewbie = 3
}
def.const("table").ActivityClass = {
  Daily = "daily",
  TimeLimited = "timeLimited"
}
def.const("number").MAX_MATCH_OPTION_COUNT = 1
def.const("number").REQ_MATCH_INFO_MIN_INTERVAL_SEC = 3
def.field("boolean").isMatching = false
def.field("boolean").isTeamMatching = false
def.field("number").matchStartTime = 0
def.field("number").lastMatchTime = 0
def.field("number").lastShoutTime = 0
def.field("table").teams = nil
def.field("table").teamsInfoListeners = nil
def.field("table").lastMatchDatas = nil
def.field("table").matchMembersInfos = nil
local instance
def.static("=>", TeamPlatformMgr).Instance = function()
  if instance == nil then
    instance = TeamPlatformMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, TeamPlatformMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.Chat_Apply_Team_Ex, TeamPlatformMgr.OnChatApplyTeamEx)
end
def.method("=>", "table").GetLastMatchData = function(self)
  return self.lastMatchDatas
end
def.method("=>", "number").GetLastMatchCfgId = function(self)
  if self.lastMatchDatas == nil then
    return 0
  end
  local matchOptions = unpack(self.lastMatchDatas)
  if #matchOptions == 0 then
    return 0
  end
  local matchOption = matchOptions[1]
  local matchCfgId = matchOption[1]
  return matchCfgId
end
def.method("=>", "table").GetLastMatchViewData = function(self)
  if self.lastMatchDatas == nil then
    return nil
  end
  local MatchCfg = require("netio.protocol.mzm.gsp.teamplatform.MatchCfg")
  local viewData = {}
  viewData.matchOptions = {}
  local matchOptions, matchRange = unpack(self.lastMatchDatas)
  for i, matchOption in ipairs(matchOptions) do
    local option = {}
    option.name = TeamPlatformUtils.GetMatchName(MatchCfg.new(unpack(matchOption)))
    table.insert(viewData.matchOptions, option)
  end
  local levelBound
  local lastLevelRange = self.lastMatchDatas.levelRange
  if lastLevelRange and lastLevelRange.levelLow ~= 0 and lastLevelRange.levelHigh ~= 0 then
    levelBound = {
      ceil = lastLevelRange.levelHigh,
      floor = lastLevelRange.levelLow
    }
    local matchOption = matchOptions[1]
    local minLevel = self:GetMatchOptionMinLevel(matchOption)
    levelBound.floor = math.max(levelBound.floor, minLevel)
  else
    local matchOption = matchOptions[1]
    local matchCfgId, subOptionIndex = unpack(matchOption)
    levelBound = self:GetMatchRangeLevelBound(matchRange)
    if levelBound.floor == levelBound.ceil and levelBound.floor == 0 and TeamData.Instance():HasTeam() then
      local members = TeamData.Instance():GetAllTeamMembers()
      local captain = members[1]
      local cfg = TeamPlatformUtils.GetTeamPlatformMatchOptionCfg(matchCfgId)
      local activeLevelRange = cfg:GetActiveLevelRange()
      local level = captain.level
      levelBound.ceil = level - 10
      levelBound.floor = levelBound.ceil
      levelBound.floor = math.min(activeLevelRange.minLevel, levelBound.floor)
      levelBound.ceil = math.min(activeLevelRange.maxLevel, levelBound.ceil)
    end
  end
  viewData.levelBound = levelBound
  return viewData
end
def.method("table", "=>", "number").GetMatchOptionMinLevel = function(self, matchOption)
  if matchOption == nil then
    warn("GetMatchOptionMinLevel matchOption is nil\n", debug.traceback())
    return 0
  end
  local matchCfgId, subOptionIndex = unpack(matchOption)
  local cfg = TeamPlatformUtils.GetTeamPlatformMatchOptionCfg(matchCfgId)
  local activeLevelRange = cfg:GetActiveLevelRange()
  local minLevel = require("Main.Hero.HeroUtility").Instance():GetRoleCommonConsts("MAX_LEVEL")
  if not cfg:IsHaveSubOptions() then
    minLevel = activeLevelRange.minLevel
  else
    local subCfgList = TeamPlatformUtils.GetTeamPlatformMatchOptionSubCfg(cfg.cfgId)
    for i, option in ipairs(subCfgList.optionList) do
      if option.index == subOptionIndex then
        minLevel = option.minLevel
        break
      end
    end
  end
  return minLevel
end
def.method("number").SyncMatchState = function(self, state)
  if state == SSynMatchState.ST__MATCH_ING then
    self.isMatching = true
    self.matchStartTime = _G.GetServerTime()
    self.lastMatchTime = self.matchStartTime
  elseif state == SSynMatchState.ST__MATCH_CANCEL then
    self.isMatching = false
    self.matchStartTime = 0
  end
  Event.DispatchEvent(ModuleId.TEAM_PLATFORM, gmodule.notifyId.TeamPlatform.SYNC_MATCH_STATE, {
    isMatching = self.isMatching
  })
end
def.method("table").SyncTeamsInfo = function(self, teams)
  self.teams = teams
  Event.DispatchEvent(ModuleId.TEAM_PLATFORM, gmodule.notifyId.TeamPlatform.TEAMS_INFO_UPDATE, {
    self.teams
  })
end
def.method("table").SyncNewTeam = function(self, teamInfo)
  if self:IsTeamInfoCanSee(teamInfo) then
    self:AddTeam(teamInfo)
  end
end
def.method("table", "=>", "boolean").IsTeamInfoCanSee = function(self, teamInfo)
  if TeamData.Instance():HasTeam() then
    return false
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return false
  end
  local heroLevel = heroProp.level
  if heroLevel < teamInfo.level.levelLow or heroLevel > teamInfo.level.levelHigh then
    return false
  end
  return true
end
def.method("table").AddTeam = function(self, teamInfo)
  self.teams = self.teams or {}
  self.teams[teamInfo.teamId] = teamInfo
  Event.DispatchEvent(ModuleId.TEAM_PLATFORM, gmodule.notifyId.TeamPlatform.NEW_TEAM_ENTER_QUEUE, {teamInfo})
end
def.method().ReqTeamsInfo = function(self)
  local teamIdList = {}
  for teamId, v in pairs(self.teams) do
    table.insert(teamIdList, teamId)
  end
  self:C2S_GetTeamsInfo(teamIdList)
end
def.method().GetTeamsInfo = function(self)
  return self.teams
end
def.method("=>", "table").GetTeamPlatformMatchOptions = function(self)
  local optionList = TeamPlatformUtils.GetTeamPlatformMatchOptions()
  local options = {}
  for i, data in ipairs(optionList) do
    if data:IsOpen() then
      table.insert(options, data)
    end
  end
  return options
end
def.method("number", "=>", "table").GetMatchRangeLevelBound = function(self, range)
  local heroLevel = HeroInterface.GetHeroProp().level
  local bound = self:GetMatchRangeBound(range)
  if range == TeamPlatformMgr.MatchRange.AidNewbie then
    return bound
  end
  local levelBound = {}
  levelBound.floor = heroLevel + bound.floor
  levelBound.floor = levelBound.floor >= 0 and levelBound.floor or 0
  levelBound.ceil = heroLevel + bound.ceil
  return levelBound
end
def.method("number", "=>", "table").GetMatchRangeBound = function(self, range)
  local tag
  if range == TeamPlatformMgr.MatchRange.First then
    tag = "LITTLE"
  elseif range == TeamPlatformMgr.MatchRange.Second then
    tag = "BIG"
  else
    return {floor = 0, ceil = 0}
  end
  return self:GetMatchRangeBoundByTag(tag)
end
def.method("string", "=>", "table").GetMatchRangeBoundByTag = function(self, tag)
  local ceil = TeamPlatformUtils.GetTeamPlatformConsts("LEVEL_" .. tag .. "_TOP")
  local floor = TeamPlatformUtils.GetTeamPlatformConsts("LEVEL_" .. tag .. "_FLOOR")
  if ceil < floor then
    floor, ceil = ceil, floor
  end
  return {floor = floor, ceil = ceil}
end
def.method("=>", "number").GetMaxMatchOptionCount = function(self)
  return TeamPlatformMgr.MAX_MATCH_OPTION_COUNT
end
def.method("=>", "number").GetSignleMaxMatchOptionCount = function(self)
  return TeamPlatformUtils.GetTeamPlatformConsts("ACTIV_COUNT")
end
def.method("table", "=>", "boolean").IsAidNewbieAvilable = function(self, teamplatformData)
  local roleId = _G.GetMyRoleID()
  local teamData = TeamData.Instance()
  if teamplatformData:IsAidNewbieAvilable() and teamData:HasTeam() and teamData:IsCaptain(roleId) then
    return true
  end
  return false
end
def.method("table", "number", "=>", "number").StartMatch = function(self, matchOptions, matchRange)
  local roleId = _G.GetMyRoleID()
  local teamData = TeamData.Instance()
  if teamData:HasTeam() then
    if not teamData:IsCaptain(roleId) then
      return CResult.ONLY_TEAM_LEADER_APPROVED
    elseif teamData:IsTeamMembersFully() then
      return CResult.TEAM_MEMBERS_REACHED_MAX
    end
  end
  if not self:CheckMatchInterval() then
    return CResult.MATCH_TOO_FREQUENT
  end
  local levelBound = self:GetMatchRangeLevelBound(matchRange)
  self:C2S_StartMatch(matchOptions, levelBound)
  self.lastMatchDatas = {matchOptions, matchRange}
  return CResult.SUCCESS
end
def.method("=>", "number").CancelMatch = function(self)
  local roleId = _G.GetMyRoleID()
  local teamData = TeamData.Instance()
  if teamData:HasTeam() and not teamData:IsCaptain(roleId) then
    return CResult.ONLY_TEAM_LEADER_APPROVED
  end
  self:C2S_CancelMatch()
  return CResult.SUCCESS
end
def.method("=>", "number").ReMatch = function(self)
  if self.lastMatchDatas then
    return self:StartMatch(unpack(self.lastMatchDatas))
  else
    return CResult.CAN_NOT_REMATCH
  end
end
def.method("=>", "boolean").IsMatching = function(self)
  return self.isMatching
end
def.method("=>", "number").ShoutToWorld = function(self)
  local teamData = TeamData.Instance()
  if not teamData:MeIsCaptain() then
    Toast(textRes.TeamPlatform[30])
    return CResult.ONLY_TEAM_LEADER_APPROVED
  end
  local vd = self:GetLastMatchViewData()
  if not self.isMatching then
    Toast(textRes.TeamPlatform[28])
    if vd then
      return CResult.NOT_IN_MATCH
    else
      return CResult.HAVE_NOT_MATCH
    end
  end
  if self:CheckShoutCost() == false then
    return CResult.FAILED_IN_CHAT
  end
  if self:CheckShoutInterval() == false then
    return CResult.FAILED_IN_CHAT
  end
  self:C2S_BroTeamMatchReq()
  return CResult.SUCCESS
end
def.method("=>", "boolean").CheckShoutCost = function(self)
  local heroProp = _G.GetHeroProp()
  local costVigor = TeamPlatformUtils.GetTeamPlatformConsts("EASY_BRO_VIGOUR_COST")
  if costVigor > heroProp.energy then
    Toast(textRes.TeamPlatform[39])
    return false
  end
  return true
end
def.method("=>", "boolean").CheckShoutInterval = function(self)
  local curTime = _G.GetServerTime()
  local minInterval = TeamPlatformUtils.GetTeamPlatformConsts("EASY_BRO_TIME_INTERVAL")
  local sec = math.abs(curTime - self.lastShoutTime)
  if minInterval > sec then
    local trysec = math.ceil(minInterval - sec)
    local text = string.format(textRes.Chat[18], trysec)
    Toast(text)
    return false
  end
  return true
end
def.method("table").AddToTeamChannel = function(self, msg)
  if _G.GetMyRoleID() == msg.roleId then
    local costVigor = TeamPlatformUtils.GetTeamPlatformConsts("EASY_BRO_VIGOUR_COST")
    if costVigor <= 0 then
      Toast(textRes.TeamPlatform[32])
    else
      Toast(textRes.TeamPlatform[40]:format(costVigor))
    end
  end
  if TeamData.Instance():HasTeam() then
    return
  end
  local ChatModule = require("Main.Chat.ChatModule")
  local BeanClazz = require("netio.protocol.mzm.gsp.teamplatform.TeamInfo")
  local teamInfo = _G.UnmarshalBean(BeanClazz, msg.content)
  local teamId = teamInfo.teamId
  local levelLow = teamInfo.level.levelLow
  local levelHigh = teamInfo.level.levelHigh
  local matchCfgId = teamInfo.activityCfg.matchCfgId
  local subOptionIndex = teamInfo.activityCfg.index
  local matchName = TeamPlatformUtils.GetMatchName(teamInfo.activityCfg)
  local content = string.format("{tp:%s,%d,%d,%s,%d,%d}", matchName, levelLow, levelHigh, tostring(teamId), matchCfgId, subOptionIndex)
  msg.content = content
  ChatModule.Instance():SendTeamPlatformMsg(msg)
end
def.method("=>", "boolean").CheckMatchInterval = function(self)
  local curTime = _G.GetServerTime()
  local minInterval = TeamPlatformUtils.GetTeamPlatformConsts("MATCH_INTERVAL") or 0
  local sec = math.abs(curTime - self.lastMatchTime)
  if minInterval > sec then
    local trysec = math.ceil(minInterval - sec)
    local text = string.format(textRes.TeamPlatform[27], trysec)
    Toast(text)
    return false
  end
  return true
end
def.method("table").SynLeaderMatchInfo = function(self, p)
  self.lastMatchDatas = {}
  local matchOptions = {}
  local matchOption = {
    p.activityInfo.matchCfgId,
    p.activityInfo.index
  }
  matchOptions[1] = matchOption
  self.lastMatchDatas[1] = matchOptions
  local bigbound = self:GetMatchRangeBoundByTag("BIG")
  local littlebound = self:GetMatchRangeBoundByTag("LITTLE")
  local matchRange
  if p.levelRange.levelLow == 0 and p.levelRange.levelHigh == 0 then
    matchRange = TeamPlatformMgr.MatchRange.AidNewbie
  elseif p.levelRange.levelHigh - p.levelRange.levelLow == bigbound.ceil - bigbound.floor then
    matchRange = TeamPlatformMgr.MatchRange.Second
  else
    matchRange = TeamPlatformMgr.MatchRange.First
  end
  self.lastMatchDatas[2] = matchRange
  self.lastMatchDatas.levelRange = p.levelRange
  if TeamData.Instance():IsTeamMembersFully() then
    self:UpdateTeamMatchingState(false)
  else
    self:UpdateTeamMatchingState(true)
  end
end
local lastreqtime = 0
local lastReqMatchCfg
def.method("number", "number", "=>", "boolean").ReqMatchMemberInfo = function(self, matchCfgId, index)
  local reqtime = GameUtil.GetTickCount()
  local msInterval = TeamPlatformMgr.REQ_MATCH_INFO_MIN_INTERVAL_SEC * 1000
  if msInterval <= reqtime - lastreqtime then
    lastreqtime = reqtime
    lastReqMatchCfg = {matchCfgId = matchCfgId, index = index}
    self:C2S_CheckMatchMembers(matchCfgId, index)
    return true
  else
    return false
  end
end
def.method("table", "=>", "number").GenMatchOptionKey = function(self, activityCfg)
  local key = bit.lshift(activityCfg.matchCfgId, 8) + activityCfg.index
  return key
end
def.method("table").SynMatchMemberInfo = function(self, p)
  self.matchMembersInfos = self.matchMembersInfos or {}
  local activityCfg = lastReqMatchCfg
  if #p.leadersInfo > 0 then
    activityCfg = p.leadersInfo[1].activityCfg
  end
  local key = self:GenMatchOptionKey(activityCfg)
  self.matchMembersInfos[key] = p
end
def.method("table", "=>", "table").GetMatchMemberInfo = function(self, activityCfg)
  if self.matchMembersInfos == nil then
    return nil
  end
  local key = self:GenMatchOptionKey(activityCfg)
  return self.matchMembersInfos[key]
end
def.method().Clear = function(self)
  self.isMatching = false
  self.lastMatchDatas = nil
  self.teams = {}
  self.lastMatchTime = 0
  self.matchMembersInfos = nil
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  local reason = params and params.reason or 0
  if reason ~= _G.LeaveWorldReason.RECONNECT then
    instance:Clear()
  elseif instance.isMatching then
    instance:SyncMatchState(SSynMatchState.ST__MATCH_CANCEL)
  end
  instance.isTeamMatching = false
end
def.static("table", "table").OnChatApplyTeamEx = function(params, context)
  local DungeonModule = require("Main.Dungeon.DungeonModule")
  if DungeonModule.Instance().State == DungeonModule.DungeonState.SOLO then
    Toast(textRes.Dungeon[45])
    return
  end
  local teamId = Int64.new(params[1])
  local matchCfgId = tonumber(params[2])
  local subOptionIndex = tonumber(params[3])
  local cfg = TeamPlatformUtils.GetTeamPlatformMatchOptionCfg(matchCfgId)
  local activeLevelRange = cfg:GetActiveLevelRange()
  local heroLevel = _G.GetHeroProp().level
  if heroLevel < activeLevelRange.minLevel then
    local MatchCfg = require("netio.protocol.mzm.gsp.teamplatform.MatchCfg")
    local matchName = TeamPlatformUtils.GetMatchName(MatchCfg.new(matchCfgId, subOptionIndex))
    local text = string.format(textRes.TeamPlatform[31], activeLevelRange.minLevel, matchName)
    Toast(text)
    return
  end
  TeamModule.Instance():ApplyTeam(teamId)
end
def.method().CheckMatchOption = function(self)
  if TeamData.Instance():HasTeam() then
    return
  end
  self:UpdateTeamMatchingState(false)
  if self.lastMatchDatas == nil then
    return
  end
  local matchOptions, matchRange = unpack(self.lastMatchDatas)
  for i, matchOption in ipairs(matchOptions) do
    if i > 1 then
      matchOptions[i] = nil
    end
  end
  local matchOption = matchOptions[1]
  local matchCfgId, subOptionIndex = unpack(matchOption)
  local cfg = TeamPlatformUtils.GetTeamPlatformMatchOptionCfg(matchCfgId)
  local activeLevelRange = cfg:GetActiveLevelRange()
  if activeLevelRange.minLevel > _G.GetHeroProp().level then
    self.lastMatchDatas = nil
    return
  end
  if matchRange == TeamPlatformMgr.MatchRange.AidNewbie then
    self.lastMatchDatas[2] = TeamPlatformMgr.MatchRange.First
  end
end
def.method("boolean").UpdateTeamMatchingState = function(self, isMatching)
  self.isTeamMatching = isMatching
  Event.DispatchEvent(ModuleId.TEAM_PLATFORM, gmodule.notifyId.TeamPlatform.SYNC_TEAM_MATCH_STATE, {isMatching = isMatching})
end
def.method("table", "table").C2S_StartMatch = function(self, matchOptions, range)
  local LevelCfg = require("netio.protocol.mzm.gsp.teamplatform.LevelCfg")
  local MatchCfg = require("netio.protocol.mzm.gsp.teamplatform.MatchCfg")
  local matchCfgs = {}
  for i, matchOption in ipairs(matchOptions) do
    table.insert(matchCfgs, MatchCfg.new(unpack(matchOption)))
    if i == 1 and TeamData.Instance():HasTeam() then
      break
    end
  end
  local p = require("netio.protocol.mzm.gsp.teamplatform.CStartMatch").new(matchCfgs, LevelCfg.new(range.floor, range.ceil))
  gmodule.network.sendProtocol(p)
end
def.method().C2S_CancelMatch = function(self)
  local p = require("netio.protocol.mzm.gsp.teamplatform.CCancelMatch").new()
  gmodule.network.sendProtocol(p)
end
def.method("table").C2S_GetTeamsInfo = function(self, teamIdList)
  local p = require("netio.protocol.mzm.gsp.teamplatform.CGetTeamsInfo").new(teamIdList)
  gmodule.network.sendProtocol(p)
end
def.method("number", "number").C2S_CheckMatchMembers = function(self, matchCfgId, index)
  if isDebug then
    warn("C2S_CheckMatchMembers", matchCfgId, index)
    return
  end
  local MatchCfg = require("netio.protocol.mzm.gsp.teamplatform.MatchCfg")
  local matchCfg = MatchCfg.new(matchCfgId, index)
  local p = require("netio.protocol.mzm.gsp.teamplatform.CCheckMatchMembers").new(matchCfg)
  gmodule.network.sendProtocol(p)
end
def.method().C2S_BroTeamMatchReq = function(self)
  local p = require("netio.protocol.mzm.gsp.teamplatform.CBroTeamMatchReq").new()
  gmodule.network.sendProtocol(p)
  self.lastShoutTime = _G.GetServerTime()
end
return TeamPlatformMgr.Commit()
