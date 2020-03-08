local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local WatchAndGuessPanel = Lplus.Extend(ECPanelBase, "WatchAndGuessPanel")
local GhostUnit = require("Main.PhantomCave.GhostUnit")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local def = WatchAndGuessPanel.define
local instance
def.static("=>", WatchAndGuessPanel).Instance = function()
  if instance == nil then
    instance = WatchAndGuessPanel()
  end
  return instance
end
def.const("table").Positions = {
  [1] = {x = 0, y = -0.6},
  [2] = {x = 0.9, y = -0.4},
  [3] = {x = 1.1, y = 0.2},
  [4] = {x = 0, y = 0.6},
  [5] = {x = -1.1, y = 0.2},
  [6] = {x = -0.9, y = -0.4}
}
def.const("number").AppearInterval = 1
def.field("table").modelInfo = nil
def.field("table").actionInfo = nil
def.field("userdata").scene = nil
def.field("table").units = nil
def.field("number").showTime = 12
def.field("userdata").curRoleId = nil
def.field("table").roleId2UI = nil
def.field("number").playTimer = 0
def.field("number").questionTimer = 0
def.field("number").prepareTimer = 0
def.field("number").helpTimes = 0
def.field("number").score = 0
def.field("number").allScore = 0
def.field("function").toQuestion = nil
def.field("string").desc = ""
def.field("number").prepareTime = 30
def.field("boolean").prepare = false
def.method("string", "number").ShowPrepare = function(self, desc, prepareTime)
  self.desc = desc
  self.prepareTime = prepareTime
  self.prepare = true
  self:CreatePanel(RESPATH.PREFAB_WATCHANDGUESS, 1)
  self:SetModal(true)
end
def.method("table", "table", "number").ShowWatchAndGuess = function(self, modelInfo, actionInfo, time)
  GameUtil.RemoveGlobalTimer(self.prepareTimer)
  self.prepareTimer = 0
  self.prepare = false
  self.modelInfo = modelInfo
  self.actionInfo = actionInfo
  self.showTime = time
  if self:IsShow() then
    self:HideTime()
    self:HideName()
    self:HideConfirm()
    self:HideQuestion()
    self:LoadModel()
  else
    self:CreatePanel(RESPATH.PREFAB_WATCHANDGUESS, 1)
    self:SetModal(true)
  end
end
def.method().HideWatchAndGuess = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  if self.prepare then
    self:HideName()
    self:HideQuestion()
    self:HideTime()
    self:ShowConfirm()
    self.prepare = false
    return
  end
  if self.toQuestion then
    self.toQuestion()
    self.toQuestion = nil
    return
  end
  self:HideTime()
  self:HideName()
  self:HideConfirm()
  self:HideQuestion()
  self:LoadModel()
end
def.override().OnDestroy = function(self)
  if self.units then
    for k, v in pairs(self.units) do
      v:Destroy()
    end
  end
  self.units = {}
  if self.scene and not self.scene.isnil then
    Object.Destroy(self.scene)
    self.scene = nil
  end
  GameUtil.RemoveGlobalTimer(self.playTimer)
  GameUtil.RemoveGlobalTimer(self.questionTimer)
  GameUtil.RemoveGlobalTimer(self.prepareTimer)
  self.playTimer = 0
  self.questionTimer = 0
  self.prepareTimer = 0
end
def.override("boolean").OnShow = function(self, show)
end
def.method().HideModel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    local uimodel = self.m_panel:FindDirect("Img_Bg/Model")
    uimodel:SetActive(false)
  end
end
def.method().HideTime = function(self)
  if self.m_panel and not self.m_panel.isnil then
    local time = self.m_panel:FindDirect("Img_Bg/Label_Time")
    time:SetActive(false)
  end
end
def.method().HideConfirm = function(self)
  if self.m_panel and not self.m_panel.isnil then
    local confirm = self.m_panel:FindDirect("Img_Bg/Group_Ready")
    confirm:SetActive(false)
  end
end
def.method().HideName = function(self)
  if self.m_panel and not self.m_panel.isnil then
    local nameGroup = self.m_panel:FindDirect("Img_Bg/Group_Name")
    nameGroup:SetActive(false)
    for i = 1, 6 do
      local name = nameGroup:FindDirect("Img_BgName" .. i)
      if name ~= nil then
        name:SetActive(false)
      end
    end
  end
end
def.method().HideQuestion = function(self)
  if self.m_panel and not self.m_panel.isnil then
    local groupAnswer = self.m_panel:FindDirect("Img_Bg/Group_Answer")
    groupAnswer:SetActive(false)
  end
end
def.method().ShowConfirm = function(self)
  local confirm = self.m_panel:FindDirect("Img_Bg/Group_Ready")
  confirm:SetActive(true)
  local explainLabel = confirm:FindDirect("Label_Describe"):GetComponent("UILabel")
  explainLabel:set_text(self.desc)
  local startBtnLabel = confirm:FindDirect("Btn_Start/Label"):GetComponent("UILabel")
  local time = self.prepareTime
  startBtnLabel:set_text(string.format(textRes.Question[38], time))
  self.prepareTimer = GameUtil.AddGlobalTimer(1, false, function()
    if self.m_panel and not self.m_panel.isnil then
      time = time - 1
      startBtnLabel:set_text(string.format(textRes.Question[38], time))
      if time <= 0 then
        GameUtil.RemoveGlobalTimer(self.prepareTimer)
        self.prepareTimer = 0
      end
    end
  end)
end
def.method().LoadModel = function(self)
  local uimodel = self.m_panel:FindDirect("Img_Bg/Model")
  local uimodelComp = uimodel:GetComponent("UIModel")
  local function unitCreated()
    local finishAll = self:CheckFinish()
    if finishAll then
      self:StartWatch()
    end
  end
  GameUtil.AsyncLoad(RESPATH.PREFAB_WATCHANDGUESS_SCENE, function(ass)
    if ass == nil then
      return
    end
    self.scene = Object.Instantiate(ass)
    uimodelComp:set_modelGameObject(self.scene)
    self.units = {}
    for k, v in pairs(self.modelInfo) do
      local unit = GhostUnit()
      self.units[k] = unit
    end
    for k, v in pairs(self.modelInfo) do
      local unit = self.units[k]
      unit:Create(v.modelId, v.colorId, v.hasOranment, self.scene, unitCreated)
    end
  end)
end
def.method("=>", "boolean").CheckFinish = function(self)
  for k, v in pairs(self.units) do
    if not v.loadFinish then
      return false
    end
  end
  return true
end
def.method().StartWatch = function(self)
  local appearSecond = self:ModelAppear()
  local function StartTime()
    self:HideName()
    local curSecond = 0
    self:SetTime(self.showTime - curSecond)
    self.playTimer = GameUtil.AddGlobalTimer(1, false, function()
      curSecond = curSecond + 1
      if curSecond <= self.showTime then
        self:SetTime(self.showTime - curSecond)
        self:DoAction(curSecond)
      else
        self:HideTime()
        self:ModelDisappear()
        GameUtil.RemoveGlobalTimer(self.playTimer)
        self.playTimer = 0
      end
    end)
  end
  GameUtil.AddGlobalTimer(appearSecond, true, StartTime)
end
def.method("number").SetTime = function(self, second)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local timeObj = self.m_panel:FindDirect("Img_Bg/Label_Time")
  timeObj:SetActive(true)
  local timeLabel = timeObj:GetComponent("UILabel")
  timeLabel:set_text(string.format("%d", second))
end
def.method("=>", "number").ModelAppear = function(self)
  local appearTime = 0
  for k, v in pairs(self.units) do
    GameUtil.AddGlobalTimer(appearTime, true, function()
      v:Appear(WatchAndGuessPanel.Positions[k].x, WatchAndGuessPanel.Positions[k].y)
      self:ShowName(k)
    end)
    appearTime = appearTime + WatchAndGuessPanel.AppearInterval
  end
  return appearTime
end
def.method("number").ShowName = function(self, id)
  if self.m_panel and not self.m_panel.isnil then
    local nameGroup = self.m_panel:FindDirect("Img_Bg/Group_Name")
    nameGroup:SetActive(true)
    local name = nameGroup:FindDirect("Img_BgName" .. id)
    if name ~= nil then
      local model = self.modelInfo[id]
      if model then
        name:SetActive(true)
        local label = name:FindDirect("Label")
        label:GetComponent("UILabel"):set_text(model.name)
      else
        name:SetActive(false)
      end
    end
  end
end
def.method().ModelDisappear = function(self)
  for k, v in pairs(self.units) do
    v:Disappear()
  end
end
def.method("number").DoAction = function(self, second)
  local action = self.actionInfo[second]
  if action then
    for k, v in ipairs(action) do
      local unit = self.units[v.who]
      local pos = WatchAndGuessPanel.Positions[v.pos]
      if unit and pos then
        unit:RunTo(pos.x, pos.y, 1)
      end
    end
  end
end
def.method("string", "table", "table", "userdata", "number").ShowQuestion = function(self, questionStr, answers, teams, answerRoleId, second)
  local function onQuestion()
    self:HideTime()
    self:HideConfirm()
    self:HideName()
    self:HideModel()
    local groupAnswer = self.m_panel:FindDirect("Img_Bg/Group_Answer")
    groupAnswer:SetActive(true)
    local question = groupAnswer:FindDirect("Label_Question")
    local questionLabel = question:GetComponent("UILabel")
    questionLabel:set_text(questionStr)
    local yourTurn = groupAnswer:FindDirect("Img_Turn")
    if GetMyRoleID() == answerRoleId then
      yourTurn:SetActive(true)
    else
      yourTurn:SetActive(false)
    end
    local answerBtns = groupAnswer:FindDirect("Group_Btn/Grid")
    while answerBtns:get_childCount() > 1 do
      Object.DestroyImmediate(answerBtns:GetChild(answerBtns:get_childCount() - 1))
    end
    local template = answerBtns:FindDirect("Btn_Answer")
    template:SetActive(false)
    for k, v in ipairs(answers) do
      local newBtn = Object.Instantiate(template)
      newBtn:SetActive(true)
      newBtn.parent = answerBtns
      newBtn:set_name("answer_" .. k)
      newBtn:set_localScale(Vector.Vector3.one)
      newBtn:FindDirect("Img_Right"):SetActive(false)
      newBtn:FindDirect("Img_Wrong"):SetActive(false)
      newBtn:FindDirect("Label"):GetComponent("UILabel"):set_text(textRes.Question[k] .. v)
      newBtn:FindDirect("Img_Select"):SetActive(false)
      newBtn:FindDirect("Img_Choose"):SetActive(false)
      self.m_msgHandler:Touch(newBtn)
    end
    answerBtns:GetComponent("UIGrid"):Reposition()
    local count = #teams
    local memberList = groupAnswer:FindDirect("Group_Member/Container/List_TeamList")
    local uilist = memberList:GetComponent("UIList")
    uilist.itemCount = count
    uilist:Resize()
    local listItems = uilist.children
    self.curRoleId = answerRoleId
    self.roleId2UI = {}
    for i = 1, count do
      local listItem = listItems[i]
      local member = teams[i]
      local name = listItem:FindDirect("Label_Name_" .. i)
      name:GetComponent("UILabel"):set_text(member.roleName)
      local head = listItem:FindDirect("Img_Head_" .. i)
      local headSpriteName = GUIUtils.GetHeadSpriteName(member.occupationId, member.gender)
      head:GetComponent("UISprite"):set_spriteName(headSpriteName)
      local ans = listItem:FindDirect("Label_Num_" .. i)
      if answerRoleId == member.roleId then
        ans:SetActive(true)
        ans:GetComponent("UILabel"):set_text("")
      else
        ans:SetActive(false)
      end
      self.roleId2UI[member.roleId:tostring()] = ans
      local highLight = listItem:FindDirect("Img_Select_" .. i)
      highLight:SetActive(answerRoleId == member.roleId)
    end
    local timeLabel = groupAnswer:FindDirect("Label_Time"):GetComponent("UILabel")
    local curTime = second
    GameUtil.RemoveGlobalTimer(self.questionTimer)
    self.questionTimer = 0
    timeLabel:set_text(string.format("%02d'", curTime))
    self.questionTimer = GameUtil.AddGlobalTimer(1, false, function()
      if timeLabel and not timeLabel.isnil then
        curTime = curTime - 1
        timeLabel:set_text(string.format("%02d'", curTime))
        if curTime <= 0 then
          GameUtil.RemoveGlobalTimer(self.questionTimer)
          self.questionTimer = 0
          self:Answer(-1)
        end
      end
    end)
    self:SetHelpTimes(self.helpTimes)
    self:SetScore(self.score, self.allScore)
  end
  if not self:IsShow() then
    self.toQuestion = onQuestion
    self:CreatePanel(RESPATH.PREFAB_WATCHANDGUESS, 1)
    self:SetModal(true)
  else
    onQuestion()
  end
end
def.method("number").Answer = function(self, select)
  require("Main.PhantomCave.WatchAndGuessMgr").Answer(select)
end
def.method("number", "=>", "boolean").Help = function(self, select)
  return require("Main.PhantomCave.WatchAndGuessMgr").Help(select)
end
def.method("string", "userdata").ShowHelp = function(self, ansStr, roleId)
  local ui = self.roleId2UI[roleId:tostring()]
  if ui then
    ui:GetComponent("UILabel"):set_text(ansStr)
    ui:GetComponent("TweenPosition"):ResetToBeginning()
    ui:SetActive(true)
    ui:GetComponent("TweenPosition"):PlayForward()
  end
end
def.method("number").SetHelpTimes = function(self, leftTimes)
  self.helpTimes = leftTimes
  if self:IsShow() then
    local times = self.m_panel:FindDirect("Img_Bg/Group_Answer/Group_Member/Container/Label_Num")
    local title = self.m_panel:FindDirect("Img_Bg/Group_Answer/Group_Member/Container/Label_Title")
    if leftTimes >= 0 then
      times:SetActive(true)
      title:SetActive(true)
      local str = leftTimes >= 0 and string.format("%d", leftTimes) or textRes.Question[28]
      times:GetComponent("UILabel"):set_text(str)
    else
      times:SetActive(false)
      title:SetActive(false)
    end
  end
end
def.method("number", "boolean").ShowResult = function(self, select, isRight)
  if GetMyRoleID() == self.curRoleId then
    local answerGroup = self.m_panel:FindDirect("Img_Bg/Group_Answer/Group_Btn/Grid")
    local btn = answerGroup:FindDirect("answer_" .. select)
    if btn then
      btn:FindDirect("Img_Select"):SetActive(true)
    end
    if isRight then
      btn:FindDirect("Img_Right"):SetActive(true)
    else
      btn:FindDirect("Img_Wrong"):SetActive(true)
    end
  else
  end
end
def.method("number", "number").SetScore = function(self, curScore, winScore)
  self.score = curScore
  self.allScore = winScore
  if self:IsShow() then
    local score = self.m_panel:FindDirect("Img_Bg/Group_Answer/Label_Score")
    local scoreLabel = score:GetComponent("UILabel")
    scoreLabel:set_text(string.format("%d/%d", curScore, winScore))
  end
end
def.method("string").onClick = function(self, id)
  if id == "Modal" then
  elseif string.find(id, "answer_") then
    local index = tonumber(string.sub(id, 8))
    local myRoleId = _G.GetMyRoleID()
    if self.curRoleId == myRoleId then
      self:Answer(index)
    else
      local done = self:Help(index)
      if done then
        local btn = self.m_panel:FindDirect("Img_Bg/Group_Answer/Group_Btn/Grid/" .. id)
        if btn then
          btn:FindDirect("Img_Choose"):SetActive(true)
        end
      end
    end
  elseif id == "Btn_Start" then
    require("Main.PhantomCave.WatchAndGuessMgr").Start()
  end
end
WatchAndGuessPanel.Commit()
return WatchAndGuessPanel
