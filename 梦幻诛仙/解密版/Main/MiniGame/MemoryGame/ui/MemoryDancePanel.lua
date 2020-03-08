local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MemoryDancePanel = Lplus.Extend(ECPanelBase, "MemoryDancePanel")
local GUIUtils = require("GUI.GUIUtils")
local Dancer = require("Main.MiniGame.MemoryGame.ui.Dancer")
local def = MemoryDancePanel.define
local instance
def.field("table").uiObjs = nil
def.field("number").activityId = 0
def.field("number").detectiveTimerId = 0
def.field("number").gameTimerId = 0
def.static("=>", MemoryDancePanel).Instance = function()
  if instance == nil then
    instance = MemoryDancePanel()
  end
  return instance
end
def.method("number").ShowPanel = function(self, activityId)
  if not self:IsDoublePlayerInTeam() then
    return
  end
  self.activityId = activityId
  if self.m_panel ~= nil then
    self:UpdateGameStatus()
  else
    require("GUI.ECGUIMan").Instance():DestroyUIAtLevel(1)
    self:CreatePanel(RESPATH.PREFAB_DANCE_PANEL, 0)
    self:SetModal(true)
  end
end
def.override().OnCreate = function(self)
  if not self:IsDoublePlayerInTeam() then
    self:DestroyPanel()
    return
  end
  self:InitUI()
  self:UpdateGameStatus()
  Event.RegisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_QUESTION_ANSWER, MemoryDancePanel.OnGameQuestionAnser)
  Event.RegisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_ROUND_CAL, MemoryDancePanel.OnGameQuestionRoundCal)
  Event.RegisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_END, MemoryDancePanel.OnGameEnd)
  Event.RegisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_SEEK_HELP, MemoryDancePanel.OnGameSeekHelpSuccess)
  Event.RegisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_SEEK_HELP_NOTIFY, MemoryDancePanel.OnGameSeekHelpNotify)
  Event.RegisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_HELP_NOTIFY, MemoryDancePanel.OnHelpNotify)
end
def.override().OnDestroy = function(self)
  if self.uiObjs.LeftDancer then
    self.uiObjs.LeftDancer:Destroy()
  end
  if self.uiObjs.RightDancer then
    self.uiObjs.RightDancer:Destroy()
  end
  self:StopDetectiveTimer()
  self:StopRoundTimer()
  self.uiObjs = nil
  self.activityId = 0
  Event.UnregisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_QUESTION_ANSWER, MemoryDancePanel.OnGameQuestionAnser)
  Event.UnregisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_ROUND_CAL, MemoryDancePanel.OnGameQuestionRoundCal)
  Event.UnregisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_END, MemoryDancePanel.OnGameEnd)
  Event.UnregisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_SEEK_HELP, MemoryDancePanel.OnGameSeekHelpSuccess)
  Event.UnregisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_SEEK_HELP_NOTIFY, MemoryDancePanel.OnGameSeekHelpNotify)
  Event.UnregisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_HELP_NOTIFY, MemoryDancePanel.OnHelpNotify)
end
def.method().InitUI = function(self)
  local teamData = require("Main.Team.TeamData").Instance()
  local members = teamData:GetAllTeamMembers()
  self.uiObjs = {}
  self.uiObjs.Label_Time = self.m_panel:FindDirect("Img_Bg0/Img_Bg/Label_Time/Label_Num")
  self.uiObjs.Label_State = self.m_panel:FindDirect("Img_Bg0/Img_Bg/Label_Time/Label_State")
  self.uiObjs.LeftDancer = Dancer.Create(self.m_panel:FindDirect("Img_Bg0/Img_Bg/Container1"), members[1].roleid)
  self.uiObjs.RightDancer = Dancer.Create(self.m_panel:FindDirect("Img_Bg0/Img_Bg/Container2"), members[2].roleid)
  self.uiObjs.dancers = {}
  self.uiObjs.dancers[members[1].roleid:tostring()] = self.uiObjs.LeftDancer
  self.uiObjs.dancers[members[2].roleid:tostring()] = self.uiObjs.RightDancer
end
def.method().UpdateGameStatus = function(self)
  self.uiObjs.LeftDancer:SetDancerRoundInfo()
  self.uiObjs.LeftDancer:SetCurrentGameOperations()
  self.uiObjs.RightDancer:SetDancerRoundInfo()
  self.uiObjs.RightDancer:SetCurrentGameOperations()
  local gameStatus = require("Main.MiniGame.MemoryGame.MemoryGameDataMgr").Instance():GetCurGameStatus()
  local score = gameStatus:GetMemoryCompetitionScore()
  self:SetGameScore(score)
  self:StartRoundTimer()
end
def.method().StartRoundTimer = function(self)
  self:StopRoundTimer()
  local gameStatus = require("Main.MiniGame.MemoryGame.MemoryGameDataMgr").Instance():GetCurGameStatus()
  local remainTime = gameStatus:GetLeftTime()
  self:UpdateRoundTime(remainTime)
  self.gameTimerId = GameUtil.AddGlobalTimer(1, false, function()
    remainTime = remainTime - 1
    if remainTime < 0 then
      self:StopRoundTimer()
    else
      self:UpdateRoundTime(remainTime)
    end
  end)
end
def.method("number").UpdateRoundTime = function(self, remainTime)
  GUIUtils.SetActive(self.uiObjs.Label_Time, true)
  GUIUtils.SetActive(self.uiObjs.Label_State, false)
  GUIUtils.SetText(self.uiObjs.Label_Time, remainTime)
end
def.method().ShowRoundWaitTips = function(self)
  GUIUtils.SetActive(self.uiObjs.Label_Time, false)
  GUIUtils.SetActive(self.uiObjs.Label_State, true)
  GUIUtils.SetText(self.uiObjs.Label_State, textRes.MemoryCompetition[17])
end
def.method().ShowGameOverTips = function(self)
  GUIUtils.SetActive(self.uiObjs.Label_Time, false)
  GUIUtils.SetActive(self.uiObjs.Label_State, true)
  GUIUtils.SetText(self.uiObjs.Label_State, textRes.MemoryCompetition[19])
end
def.method().StopRoundTimer = function(self)
  if self.gameTimerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.gameTimerId)
    self.gameTimerId = 0
  end
end
def.method("userdata", "number").SetPlayerAnswer = function(self, roleId, option)
  local dancer = self:GetDancerByRoleId(roleId)
  dancer:ChooseOption(option)
end
def.method("userdata", "=>", Dancer).GetDancerByRoleId = function(self, roleId)
  return self.uiObjs.dancers[roleId:tostring()]
end
def.method("table").SetDanceRoundResult = function(self, resultMap)
  for roleId, result in pairs(resultMap) do
    local isRight = result == 1
    local dancer = self:GetDancerByRoleId(roleId)
    dancer:ShowPlayResult(isRight)
    dancer:SetDancerRoundInfo()
  end
end
def.method().SetCurrentPlayerSeekHelp = function(self)
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local heroProp = HeroPropMgr.heroProp
  local dancer = self:GetDancerByRoleId(heroProp.id)
  dancer:SetDancerCurrentSeekHelpInfo()
end
def.method("userdata").SetPlayerSeekHelp = function(self, roleId)
  local teamData = require("Main.Team.TeamData").Instance()
  local role = teamData:getMember(roleId)
  if role ~= nil then
    Toast(string.format(textRes.MemoryCompetition[9], role.name))
  end
  local dancer = self:GetDancerByRoleId(roleId)
  dancer:SetSeekingHelp()
end
def.method("userdata", "number").SetPlayerHelpNotify = function(self, helpRoleId, answer)
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local heroProp = HeroPropMgr.heroProp
  local dancer = self:GetDancerByRoleId(heroProp.id)
  dancer:NotifyReceiveHelp(helpRoleId, answer)
end
def.method("table").ShowGameOverResult = function(self, roleAnswerMap)
  Toast(textRes.MemoryCompetition[13])
  local maxAnimationTime = 0
  for roleId, answers in pairs(roleAnswerMap) do
    local dancer = self:GetDancerByRoleId(roleId)
    local animTime = dancer:ShowPalyerAnserSequence(answers.quesition_id_list)
    maxAnimationTime = math.max(maxAnimationTime, animTime)
  end
  self:DetectiveDanceSequenceGameOver(maxAnimationTime)
end
def.method("number").DetectiveDanceSequenceGameOver = function(self, delayTime)
  self.detectiveTimerId = GameUtil.AddGlobalTimer(delayTime, true, function()
    self:StopDetectiveTimer()
    self:ShowCloseTips()
  end)
end
def.method().StopDetectiveTimer = function(self)
  if self.detectiveTimerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.detectiveTimerId)
    self.detectiveTimerId = 0
  end
end
def.method().ShowCloseTips = function(self)
  Toast(textRes.MemoryCompetition[14])
  self:CloseGame()
end
def.method().CloseGame = function(self)
  Event.DispatchEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_OVER, {
    self.activityId
  })
  self:DestroyPanel()
end
def.method("number").SetGameScore = function(self, score)
end
def.method("=>", "boolean").IsDoublePlayerInTeam = function(self)
  local teamData = require("Main.Team.TeamData").Instance()
  if teamData:HasTeam() ~= true or teamData:GetMemberCount() ~= 2 then
    return false
  end
  return true
end
def.method("string").onClick = function(self, id)
  if self.uiObjs.LeftDancer:onClick(id) then
    return
  else
    if self.uiObjs.RightDancer:onClick(id) then
      return
    else
    end
  end
end
def.static("table", "table").OnGameQuestionAnser = function(p1, p2)
  local activityId = p1.activityId
  local roleId = p1.roleId
  local answer = p1.answer
  if activityId == instance.activityId then
    instance:SetPlayerAnswer(roleId, answer)
  end
end
def.static("table", "table").OnGameQuestionRoundCal = function(p1, p2)
  local activityId = p1.activityId
  local result = p1.result
  local score = p1.score
  if activityId == instance.activityId then
    instance:StopRoundTimer()
    instance:ShowRoundWaitTips()
    instance:SetDanceRoundResult(result)
    instance:SetGameScore(score)
  end
end
def.static("table", "table").OnGameEnd = function(p1, p2)
  local activityId = p1.activityId
  local roleAnswerMap = p1.roleAnswerMap
  if activityId == instance.activityId then
    instance:StopRoundTimer()
    instance:ShowGameOverTips()
    instance:ShowGameOverResult(roleAnswerMap)
  end
end
def.static("table", "table").OnGameSeekHelpSuccess = function(p1, p2)
  local activityId = p1[1]
  if activityId == instance.activityId then
    instance:SetCurrentPlayerSeekHelp()
  end
end
def.static("table", "table").OnGameSeekHelpNotify = function(p1, p2)
  local activityId = p1.activityId
  local roleId = p1.roleId
  if activityId == instance.activityId then
    instance:SetPlayerSeekHelp(roleId)
  end
end
def.static("table", "table").OnHelpNotify = function(p1, p2)
  local activityId = p1.activityId
  local roleId = p1.roleId
  local answer = p1.answer
  if activityId == instance.activityId then
    instance:SetPlayerHelpNotify(roleId, answer)
  end
end
MemoryDancePanel.Commit()
return MemoryDancePanel
