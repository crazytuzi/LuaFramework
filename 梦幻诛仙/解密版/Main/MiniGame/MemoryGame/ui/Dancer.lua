local Lplus = require("Lplus")
local Dancer = Lplus.Class("Dancer")
local GUIUtils = require("GUI.GUIUtils")
local ECUIModel = require("Model.ECUIModel")
local def = Dancer.define
def.field("userdata").m_node = nil
def.field("userdata").roleId = nil
def.field("table").uiObjs = nil
def.field(ECUIModel).heroModel = nil
def.static("userdata", "userdata", "=>", Dancer).Create = function(uiGo, roleId)
  local dancer = Dancer()
  dancer.m_node = uiGo
  dancer.roleId = roleId
  dancer:OnCreate()
  return dancer
end
def.method().OnCreate = function(self)
  self:InitUI()
  self:SetRoleModelInfo()
  self:SetDancerRoundInfo()
  self:SetCurrentGameOperations()
  self:SetDancerCurrentSeekHelpInfo()
end
def.method().InitUI = function(self)
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local heroProp = HeroPropMgr.heroProp
  self.uiObjs = {}
  self.uiObjs.Btn_Help = self.m_node:FindDirect("Group_Btn/Btn_Help")
  self.uiObjs.Btn_Help.name = "Btn_Help_" .. self.roleId:tostring()
  GUIUtils.SetActive(self.uiObjs.Btn_Help, heroProp.id == self.roleId)
  self.uiObjs.roleUIModel = self.m_node:FindDirect("Group_Model/Img_BgRole/Model")
  self.uiObjs.roleName = self.m_node:FindDirect("Group_Model/Img_BgName/Label")
  self.uiObjs.questionDesc = self.m_node:FindDirect("Img_BgItem/Label_Item")
  self.uiObjs.rightAnswerNum = self.m_node:FindDirect("Img_BgItem/Label_Count")
  GUIUtils.SetText(self.uiObjs.questionDesc, "")
  GUIUtils.SetText(self.uiObjs.rightAnswerNum, "")
  self.uiObjs.operationList = self.m_node:FindDirect("Group_Btn/List")
  local uiList = self.uiObjs.operationList:GetComponent("UIList")
  uiList.itemCount = 0
  uiList:Resize()
end
def.method().SetRoleModelInfo = function(self)
  local teamData = require("Main.Team.TeamData").Instance()
  local memberInfo = teamData:getMember(self.roleId)
  GUIUtils.SetText(self.uiObjs.roleName, memberInfo.name)
  if self.heroModel ~= nil then
    self.heroModel:Destroy()
  end
  local dancerModelInfo = self:GetDancerModelInfo()
  self.heroModel = ECUIModel.new(dancerModelInfo.modelid)
  self.heroModel:AddOnLoadCallback("Dancer_SetRoleModelInfo_" .. self.roleId:tostring(), function()
    local m = self.heroModel.m_model
    if m == nil then
      return
    end
    if self.uiObjs.roleUIModel ~= nil and not self.uiObjs.roleUIModel.isnil then
      local uimodel = self.uiObjs.roleUIModel:GetComponent("UIModel")
      uimodel.modelGameObject = m
      self.heroModel:SetWeapon(0, 0)
    end
  end)
  _G.LoadModelWithoutTransform(self.heroModel, dancerModelInfo, 0, 0, 180, false)
end
def.method("=>", "table").GetDancerModelInfo = function(self)
  local teamData = require("Main.Team.TeamData").Instance()
  local memberInfo = teamData:getMember(self.roleId)
  local modelInfo = memberInfo.model
  return modelInfo
end
def.method().SetCurrentGameOperations = function(self)
  local gameStatus = require("Main.MiniGame.MemoryGame.MemoryGameDataMgr").Instance():GetCurGameStatus()
  local actionMgr = require("Main.Chat.ui.DlgAction").Instance()
  local actions = actionMgr.actionMap or actionMgr:GetAllActionCfg()
  local curQuestion = gameStatus:GetQuestionInfoByRoleId(self.roleId)
  GUIUtils.SetText(self.uiObjs.questionDesc, string.format(textRes.MemoryCompetition[6], actions[curQuestion:GetQuestionId()].name))
  self:ResetOperteBtn()
  local options = curQuestion:GetQuestionOptions()
  local uiList = self.uiObjs.operationList:GetComponent("UIList")
  uiList.itemCount = #options
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, #options do
    local uiItem = uiItems[i]
    local btnName = uiItem:FindDirect(string.format("Label_%d", i))
    GUIUtils.SetActive(btnName, true)
    GUIUtils.SetText(btnName, actions[options[i]].name)
    uiItem.name = string.format("Option_%d_%s", options[i], self.roleId:tostring())
  end
  if self.heroModel ~= nil then
    self.heroModel:CrossFade(ActionName.Stand, 0.2)
  end
end
def.method().SetDancerRoundInfo = function(self)
  local gameStatus = require("Main.MiniGame.MemoryGame.MemoryGameDataMgr").Instance():GetCurGameStatus()
  local selfRightNum = gameStatus:GetRightAnswerNumByRoleId(self.roleId)
  local curRound = gameStatus:GetCurRound()
  GUIUtils.SetText(self.uiObjs.rightAnswerNum, string.format(textRes.MemoryCompetition[5], selfRightNum, curRound))
end
def.method().SetDancerCurrentSeekHelpInfo = function(self)
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local heroProp = HeroPropMgr.heroProp
  if heroProp.id == self.roleId then
    local Label = self.uiObjs.Btn_Help:FindDirect("Label")
    GUIUtils.SetActive(Label, true)
    local curGameCfgId = require("Main.MiniGame.MemoryGame.MemoryGameDataMgr").Instance():GetCurGameCfgId()
    local gameCfg = require("Main.MiniGame.MemoryGame.MemoryGameMgr").Instance():GetMemoryGameCfgById(curGameCfgId)
    local gameStatus = require("Main.MiniGame.MemoryGame.MemoryGameDataMgr").Instance():GetCurGameStatus()
    GUIUtils.SetText(Label, string.format(textRes.MemoryCompetition[11], gameStatus:GetLeftSeekHelpTimes(), gameCfg.seekHelpTimes))
  end
end
def.method("=>", "boolean").IsShow = function(self)
  if self.m_node and not self.m_node.isnil then
    return self.m_node:get_activeInHierarchy()
  else
    return false
  end
end
def.method("number").ChooseOption = function(self, option)
  self:SetOperateAvailable(false)
  self:PlayOptionAction(option)
end
def.method("boolean").SetOperateAvailable = function(self, canUse)
  local Group_Btn = self.m_node:FindDirect("Group_Btn")
  GUIUtils.SetActive(Group_Btn, canUse)
end
def.method("number").PlayOptionAction = function(self, option)
  if self.heroModel == nil then
    return
  end
  local actionMgr = require("Main.Chat.ui.DlgAction").Instance()
  local actions = actionMgr.actionMap or actionMgr:GetAllActionCfg()
  local action = actions[option]
  local PlayType = require("consts.mzm.gsp.expression.confbean.PlayType")
  self.heroModel:StopCurrentAnim()
  self.heroModel:CrossFade(action.actionName, 0.2)
  if (action.playType == PlayType.NORMAL_AFTER_PLAY or action.playType == PlayType.CIRCLE) and action.actionName ~= ActionName.Defend then
    self.heroModel:CrossFadeQueued(ActionName.Stand, 0.2)
  end
end
def.method("boolean").ShowPlayResult = function(self, isRight)
  self:SetOperateAvailable(false)
  local effres
  if isRight then
    effres = _G.GetEffectRes(constant.CRomanticDanceConsts.right_effect_source_cfg_id)
  else
    effres = _G.GetEffectRes(constant.CRomanticDanceConsts.wrong_effect_source_cfg_id)
  end
  if effres then
    require("Fx.GUIFxMan").Instance():PlayAsChildLayerWithCallback(self.m_node:FindDirect("Img_BgItem"), effres.path, "DanceResult", 0, 0, 1, 1, -1, false, nil)
  end
end
def.method("table", "=>", "number").ShowPalyerAnserSequence = function(self, answers)
  GUIUtils.SetText(self.uiObjs.questionDesc, textRes.MemoryCompetition[7])
  if self.heroModel == nil then
    return
  end
  local sequenceTime = 0
  local actionMgr = require("Main.Chat.ui.DlgAction").Instance()
  local actions = actionMgr.actionMap or actionMgr:GetAllActionCfg()
  local PlayType = require("consts.mzm.gsp.expression.confbean.PlayType")
  self.heroModel:StopCurrentAnim()
  for i = 1, #answers do
    local action = actions[answers[i]]
    local aniTime = self.heroModel:GetAniDuration(action.actionName)
    sequenceTime = sequenceTime + aniTime
    self.heroModel:CrossFadeQueued(action.actionName, 0.2)
  end
  self.heroModel:CrossFadeQueued(ActionName.Stand, 0.2)
  return sequenceTime
end
def.method().SetSeekingHelp = function(self)
  local uiList = self.uiObjs.operationList:GetComponent("UIList")
  local uiItems = uiList.children
  for i = 1, #uiItems do
    local uiItem = uiItems[i]
    GUIUtils.SetLightEffect(uiItem, GUIUtils.Light.Round)
  end
end
def.method().ResetOperteBtn = function(self)
  local uiList = self.uiObjs.operationList:GetComponent("UIList")
  local uiItems = uiList.children
  for i = 1, #uiItems do
    local uiItem = uiItems[i]
    GUIUtils.SetLightEffect(uiItem, GUIUtils.Light.None)
  end
  self:SetOperateAvailable(true)
end
def.method("userdata", "number").NotifyReceiveHelp = function(self, helpRoleId, answer)
  local teamData = require("Main.Team.TeamData").Instance()
  local role = teamData:getMember(helpRoleId)
  if role ~= nil then
    local actionMgr = require("Main.Chat.ui.DlgAction").Instance()
    local actions = actionMgr.actionMap or actionMgr:GetAllActionCfg()
    Toast(string.format(textRes.MemoryCompetition[10], role.name, actions[answer].name))
  end
end
def.method().Destroy = function(self)
  self.m_node = nil
  self.roleId = nil
  self.uiObjs = nil
  if self.heroModel then
    self.heroModel:Destroy()
    self.heroModel = nil
  end
end
def.method("string", "=>", "boolean").onClick = function(self, id)
  if self:IsShow() then
    if string.find(id, self.roleId:tostring()) then
      local btnName = string.sub(id, 1, #id - #self.roleId:tostring() - 1)
      if btnName == "Btn_Help" then
        self:OnBtnHelpClick()
      elseif string.find(id, "Option_") then
        local option = string.sub(btnName, #"Option_" + 1)
        self:OnBtnOptionClick(tonumber(option))
      else
        return false
      end
      return true
    end
    return false
  else
    return false
  end
end
def.method().OnBtnHelpClick = function(self)
  require("Main.MiniGame.MemoryGame.MemoryGameMgr").Instance():MemoryCompetitionSeekHelp()
end
def.method("number").OnBtnOptionClick = function(self, option)
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local heroProp = HeroPropMgr.heroProp
  if heroProp.id == self.roleId then
    self:AnswerQuestion(option)
  else
    self:HelpAnswerQuestion(option)
  end
end
def.method("number").AnswerQuestion = function(self, option)
  require("Main.MiniGame.MemoryGame.MemoryGameMgr").Instance():MemoryCompetitionAnswer(option)
end
def.method("number").HelpAnswerQuestion = function(self, option)
  local dataMgr = require("Main.MiniGame.MemoryGame.MemoryGameDataMgr").Instance()
  if dataMgr:IsPlayerSeekingHelp(self.roleId) then
    require("Main.MiniGame.MemoryGame.MemoryGameMgr").Instance():MemoryCompetitionHelpAnswer(self.roleId, option)
  else
    Toast(textRes.MemoryCompetition[8])
  end
end
Dancer.Commit()
return Dancer
