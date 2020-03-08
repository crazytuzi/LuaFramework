local Lplus = require("Lplus")
local ActivityInterface = require("Main.activity.ActivityInterface")
local RomanticDanceMgr = Lplus.Class("RomanticDanceMgr")
local def = RomanticDanceMgr.define
local instance
def.static("=>", RomanticDanceMgr).Instance = function()
  if nil == instance then
    instance = RomanticDanceMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Memory_Competition_Enter, RomanticDanceMgr.OnEnterMemoryCompetition)
  Event.RegisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_START, RomanticDanceMgr.OnMemoryGameStart)
  Event.RegisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_QUESTION_START, RomanticDanceMgr.OnMemoryGameQuestionStart)
  Event.RegisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_OVER, RomanticDanceMgr.OnMemoryGameOver)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.memorycompetition.SAttendRomanticDanceFail", RomanticDanceMgr.OnSAttendRomanticDanceFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.memorycompetition.SRomanticDanceEndBigAward", RomanticDanceMgr.OnSRomanticDanceEndBigAward)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.memorycompetition.SRomanticDanceFriendValueAdd", RomanticDanceMgr.OnSRomanticDanceFriendValueAdd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.memorycompetition.SOpenRomanticDanceRulePanel", RomanticDanceMgr.OnSOpenRomanticDanceRulePanel)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.memorycompetition.SOpenRomanticDanceSelectPanel", RomanticDanceMgr.OnSOpenRomanticDanceSelectPanel)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.memorycompetition.SRomanticDanceSelect", RomanticDanceMgr.OnSRomanticDanceSelect)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.memorycompetition.SCloseRomanticDanceRulePanel", RomanticDanceMgr.OnSCloseRomanticDanceRulePanel)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.memorycompetition.SCloseRomanticDanceSelectPanel", RomanticDanceMgr.OnSCloseRomanticDanceSelectPanel)
end
def.static("table", "table").OnEnterMemoryCompetition = function(p1, p2)
  local activityId = p1[1]
  if activityId == constant.CRomanticDanceConsts.activity_cfg_id then
    RomanticDanceMgr.Instance():OpenRomanticDanceRulePanel()
  end
end
def.static("table", "table").OnMemoryGameStart = function(p1, p2)
  local activityId = p1.activityId
  local remainTime = p1.remainTime
  if activityId == constant.CRomanticDanceConsts.activity_cfg_id then
    RomanticDanceMgr.Instance():ShowRomanticDanceMapping(remainTime)
  end
end
def.static("table", "table").OnMemoryGameQuestionStart = function(p1, p2)
  local activityId = p1[1]
  if activityId == constant.CRomanticDanceConsts.activity_cfg_id then
    RomanticDanceMgr.Instance():ShowRomanticDanceQuestion()
  end
end
def.static("table", "table").OnMemoryGameOver = function(p1, p2)
  local activityId = p1[1]
  if activityId == constant.CRomanticDanceConsts.activity_cfg_id then
    RomanticDanceMgr.Instance():CheckToMakeFriend()
  end
end
def.static("table").OnSAttendRomanticDanceFail = function(p)
  if textRes.MemoryCompetition.SAttendRomanticDanceFail[p.result] then
    Toast(textRes.MemoryCompetition.SAttendRomanticDanceFail[p.result])
  end
end
def.static("table").OnSRomanticDanceEndBigAward = function(p)
  instance:ShowDanceAwardPanel(p.award_item_map)
end
def.static("table").OnSRomanticDanceFriendValueAdd = function(p)
  Toast(string.format(textRes.MemoryCompetition[16], p.add_value))
end
def.static("table").OnSOpenRomanticDanceRulePanel = function(p)
  require("Main.activity.MemoryCompetition.RomanticDance.ui.RomanticDanceRulePanel").Instance():ShowPanel()
end
def.static("table").OnSOpenRomanticDanceSelectPanel = function(p)
  require("Main.activity.MemoryCompetition.RomanticDance.ui.RomanticDanceChooseModePanel").Instance():ShowPanel()
end
def.static("table").OnSRomanticDanceSelect = function(p)
  require("Main.activity.MemoryCompetition.RomanticDance.ui.RomanticDanceChooseModePanel").Instance():SelectMode(p.rank_num)
end
def.static("table").OnSCloseRomanticDanceRulePanel = function(p)
  require("Main.activity.MemoryCompetition.RomanticDance.ui.RomanticDanceRulePanel").Instance():DestroyPanel()
end
def.static("table").OnSCloseRomanticDanceSelectPanel = function(p)
  require("Main.activity.MemoryCompetition.RomanticDance.ui.RomanticDanceChooseModePanel").Instance():DestroyPanel()
end
def.method().OpenRomanticDanceRulePanel = function(self)
  if not self:CheckActivityAvailableAndToast() then
    return
  end
  self:OpenRomanticDanceRulePanelReq()
end
def.method().OpenRomanticDanceRulePanelReq = function(self)
  local teamData = require("Main.Team.TeamData").Instance()
  if not teamData:MeIsCaptain() then
    return
  end
  local req = require("netio.protocol.mzm.gsp.memorycompetition.COpenRomanticDanceRulePanel").new()
  gmodule.network.sendProtocol(req)
end
def.method().OpenRomanticChooseModePanel = function(self)
  if not self:CheckActivityAvailableAndToast() then
    return
  end
  self:OpenRomanticChooseModePanelReq()
end
def.method().OpenRomanticChooseModePanelReq = function(self)
  local teamData = require("Main.Team.TeamData").Instance()
  if not teamData:MeIsCaptain() then
    return
  end
  local req = require("netio.protocol.mzm.gsp.memorycompetition.COpenRomanticDanceSelectPanel").new()
  gmodule.network.sendProtocol(req)
end
def.method("number").ClickRomanceDanceMode = function(self, hardType)
  local teamData = require("Main.Team.TeamData").Instance()
  if not teamData:MeIsCaptain() then
    return
  end
  local req = require("netio.protocol.mzm.gsp.memorycompetition.CRomanticDanceSelect").new(hardType)
  gmodule.network.sendProtocol(req)
end
def.method().CloseTeamMemerRulePanel = function(self)
  local teamData = require("Main.Team.TeamData").Instance()
  if not teamData:MeIsCaptain() then
    return
  end
  local req = require("netio.protocol.mzm.gsp.memorycompetition.CCloseRomanticDanceRulePanel").new()
  gmodule.network.sendProtocol(req)
end
def.method().CloseTeamMemerChooseModePanel = function(self)
  local teamData = require("Main.Team.TeamData").Instance()
  if not teamData:MeIsCaptain() then
    return
  end
  local req = require("netio.protocol.mzm.gsp.memorycompetition.CCloseRomanticDanceSelectPanel").new()
  gmodule.network.sendProtocol(req)
end
def.method("number").AttendRomanticDance = function(self, hardType)
  if not self:CheckActivityAvailableAndToast() then
    return
  end
  local req = require("netio.protocol.mzm.gsp.memorycompetition.CAttendRomanticDance").new(hardType)
  gmodule.network.sendProtocol(req)
end
def.method().GetRomanticDanceEndBigAward = function(self)
  local req = require("netio.protocol.mzm.gsp.memorycompetition.CGetRomanticDanceEndBigAward").new()
  gmodule.network.sendProtocol(req)
end
def.method("=>", "boolean").CheckActivityAvailableAndToast = function(self)
  if not self:CanJoinDanceActivity() then
    Toast(textRes.MemoryCompetition[1])
    return false
  end
  if not self:IsFunctionOpen() then
    Toast(textRes.MemoryCompetition[18])
    return false
  end
  return true
end
def.method("=>", "boolean").CanJoinDanceActivity = function(self)
  local teamData = require("Main.Team.TeamData").Instance()
  if teamData:HasTeam() ~= true or teamData:GetMemberCount() ~= 2 then
    return false
  end
  return true
end
def.method("=>", "boolean").IsFunctionOpen = function(self)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  return _G.IsFeatureOpen(Feature.TYPE_MEMORY_COMPETITION) and _G.IsFeatureOpen(Feature.TYPE_ROMANTIC_DANCE)
end
def.method("=>", "table").GetRomanticDanceActionMap = function(self)
  local actionMgr = require("Main.Chat.ui.DlgAction").Instance()
  local actions = actionMgr.actionMap or actionMgr:GetAllActionCfg()
  local actionMap = {}
  for i = 1, actions.size do
    actionMap[actions[i].id] = actions[i].name
  end
  return actionMap
end
def.method("number").ShowRomanticDanceMapping = function(self, remainTime)
  local actionMap = self:GetRomanticDanceActionMap()
  require("Main.MiniGame.MemoryGame.ui.MemoryMappingPanel").Instance():ShowPanel(textRes.MemoryCompetition[2], actionMap, remainTime)
end
def.method().ShowRomanticDanceQuestion = function(self)
  local actionMap = self:GetRomanticDanceActionMap()
  require("Main.MiniGame.MemoryGame.ui.MemoryDancePanel").Instance():ShowPanel(constant.CRomanticDanceConsts.activity_cfg_id)
end
def.method("table").ShowDanceAwardPanel = function(self, items)
  require("Main.activity.MemoryCompetition.RomanticDance.ui.RomanticDanceAwardPanel").Instance():ShowPanel(items)
end
def.method().CheckToMakeFriend = function(self)
  local teamData = require("Main.Team.TeamData").Instance()
  local members = teamData:GetAllTeamMembers()
  if #members ~= 2 then
    return
  end
  local otherPlayer
  if teamData:MeIsCaptain() then
    otherPlayer = members[2]
  else
    otherPlayer = members[1]
  end
  local FriendModule = require("Main.friend.FriendModule")
  local friendId = otherPlayer.roleid
  if not FriendModule.Instance():IsFriend(friendId) and not FriendModule.Instance():IsInApplyList(friendId) then
    Toast(textRes.MemoryCompetition[15])
    FriendModule.AddFriendOrDeleteFriend(otherPlayer.roleid, otherPlayer.name)
  end
end
RomanticDanceMgr.Commit()
return RomanticDanceMgr
