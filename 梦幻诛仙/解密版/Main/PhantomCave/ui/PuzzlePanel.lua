local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PuzzlePanel = Lplus.Extend(ECPanelBase, "PuzzlePanel")
local MathHelper = require("Common.MathHelper")
local instance
local def = PuzzlePanel.define
def.static("number", "number").ShowPuzzle = function(time, question)
  if instance == nil then
    instance = PuzzlePanel()
    instance.time = time
    instance.question = question
    instance:CreatePanel(RESPATH.PREFAB_PUZZLE, 1)
    instance:SetModal(true)
  else
    warn("Can not show an other")
  end
end
def.static().Close = function()
  if instance ~= nil then
    instance:DelayClose()
  end
end
def.static().DebugWin = function()
  if instance then
    instance.finish = true
    require("Main.PhantomCave.PuzzleMgr").Instance():Success()
    instance:SetWinOrLose(1)
  end
end
def.const("table").ADJOINTBL = {
  [1] = {
    [2] = true,
    [4] = true
  },
  [2] = {
    [1] = true,
    [3] = true,
    [5] = true
  },
  [3] = {
    [2] = true,
    [6] = true
  },
  [4] = {
    [1] = true,
    [5] = true,
    [7] = true
  },
  [5] = {
    [2] = true,
    [4] = true,
    [6] = true,
    [8] = true
  },
  [6] = {
    [3] = true,
    [5] = true,
    [9] = true
  },
  [7] = {
    [4] = true,
    [8] = true
  },
  [8] = {
    [5] = true,
    [7] = true,
    [9] = true
  },
  [9] = {
    [6] = true,
    [8] = true
  }
}
def.field("number").question = 0
def.field("number").time = 0
def.field("number").timer = 0
def.field("table").index2Img = nil
def.field("number").select = 0
def.field("boolean").tweening = false
def.field("boolean").finish = false
def.override().OnCreate = function(self)
  local closeBtn = self.m_panel:FindDirect("Img_Bg0/Btn_Close")
  closeBtn:SetActive(false)
  self:SetWinOrLose(0)
  self:SetTime(self.time)
  self:SetPreview(self.question)
  self:InitPuzzle(self.question)
  self.timer = GameUtil.AddGlobalTimer(1, false, function()
    self.time = self.time - 1
    if self.finish then
      self:SetWaitTime(self.time)
    else
      self:SetTime(self.time)
    end
    if self.time <= 0 then
      GameUtil.RemoveGlobalTimer(self.timer)
      self.timer = 0
      if not self.finish then
        require("Main.PhantomCave.PuzzleMgr").Instance():Fail()
        self:SetWinOrLose(-1)
        self.finish = true
      end
      self:DelayClose()
    end
  end)
end
def.override().OnDestroy = function(self)
  GameUtil.RemoveGlobalTimer(self.timer)
  self.timer = 0
  instance = nil
end
def.method().DelayClose = function(self)
  GameUtil.AddGlobalTimer(1, true, function()
    self:DestroyPanel()
  end)
end
def.method("number").SetWinOrLose = function(self, winOrLose)
  local win = self.m_panel:FindDirect("Img_Bg0/Img_Success")
  local lose = self.m_panel:FindDirect("Img_Bg0/Img_Lose")
  win:SetActive(false)
  lose:SetActive(false)
  local wait = self.m_panel:FindDirect("Img_Bg0/Label_Finish")
  if winOrLose == 0 then
    wait:SetActive(false)
  elseif winOrLose == 1 then
    wait:SetActive(true)
    require("Fx.GUIFxMan").Instance():Play(RESPATH.YANHUA_EFFECT, "yanhua", 0, 0, -1, false)
  elseif winOrLose == -1 then
    wait:SetActive(false)
  end
end
def.method("number").SetWaitTime = function(self, time)
  local wait = self.m_panel:FindDirect("Img_Bg0/Label_Finish/Label")
  local waitLabel = wait:GetComponent("UILabel")
  if time > 0 then
    waitLabel:set_text(string.format(textRes.Question[37], time))
  else
    waitLabel:set_text("")
  end
end
def.method("number").SetTime = function(self, time)
  if time < 0 then
    local timeGroup = self.m_panel:FindDirect("Img_Bg0/Group_Time")
    timeGroup:SetActive(false)
  else
    local timeObj = self.m_panel:FindDirect("Img_Bg0/Group_Time/Label_Time")
    local timeLabel = timeObj:GetComponent("UILabel")
    local timetbl = Seconds2HMSTime(time)
    timeLabel:set_text(string.format("%02d:%02d", timetbl.m, timetbl.s))
  end
end
def.method("number").SetPreview = function(self, question)
  local spriteName = string.format("%d_%d", question, 0)
  local preview = self.m_panel:FindDirect("Img_Bg0/Group_View/Img_View")
  local sprite = preview:GetComponent("UISprite"):set_spriteName(spriteName)
end
def.method("number").InitPuzzle = function(self, question)
  local puzzleGroup = self.m_panel:FindDirect("Img_Bg0/Group_PinTu")
  local imgs = {}
  for i = 1, 9 do
    local img = puzzleGroup:FindDirect(string.format("Img_%d", i))
    img:GetComponent("UISprite"):set_spriteName(string.format("%d_%d", question, i))
    table.insert(imgs, img)
  end
  MathHelper.ShuffleTable(imgs)
  self.index2Img = {}
  for i = 1, 9 do
    self.index2Img[i] = imgs[i]
  end
  for i = 1, 9 do
    local povit = puzzleGroup:FindDirect(string.format("Img_PinTu_%d", i))
    self.index2Img[i].localPosition = povit.localPosition
  end
end
def.method("number", "number").Switch = function(self, a, b)
  local puzzleGroup = self.m_panel:FindDirect("Img_Bg0/Group_PinTu")
  local povitA = puzzleGroup:FindDirect(string.format("Img_PinTu_%d", a))
  local povitB = puzzleGroup:FindDirect(string.format("Img_PinTu_%d", b))
  local imgA = self.index2Img[a]
  local imgB = self.index2Img[b]
  TweenPosition.Begin(imgA, 0.2, povitB.localPosition)
  TweenPosition.Begin(imgB, 0.2, povitA.localPosition)
  self.tweening = true
  self.index2Img[a] = imgB
  self.index2Img[b] = imgA
  GameUtil.AddGlobalTimer(0.2, true, function()
    self.tweening = false
    if self.m_panel and not self.m_panel.isnil and self:CheckSuccess() then
      self.finish = true
      self:SetTime(-1)
      require("Main.PhantomCave.PuzzleMgr").Instance():Success()
      self:SetWinOrLose(1)
    else
    end
  end)
end
def.method().UnselectAll = function(self)
  local puzzleGroup = self.m_panel:FindDirect("Img_Bg0/Group_PinTu")
  for i = 1, 9 do
    local highLight = puzzleGroup:FindDirect(string.format("Img_PinTu_%d/Img_Select", i))
    highLight:SetActive(false)
  end
  self.select = 0
end
def.method("number").SelectOne = function(self, index)
  local puzzleGroup = self.m_panel:FindDirect("Img_Bg0/Group_PinTu")
  for i = 1, 9 do
    local highLight = puzzleGroup:FindDirect(string.format("Img_PinTu_%d/Img_Select", i))
    if i == index then
      highLight:SetActive(true)
    else
      highLight:SetActive(false)
    end
  end
  self.select = index
end
def.method("=>", "boolean").CheckSuccess = function(self)
  for i = 1, 9 do
    local go = self.index2Img[i]
    if go.name ~= string.format("Img_%d", i) then
      return false
    end
  end
  return true
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    if not self.finish then
      require("Main.PhantomCave.PuzzleMgr").Instance():Fail()
    end
    self:DestroyPanel()
  elseif string.find(id, "Img_PinTu_") then
    if self.tweening or self.finish then
      return
    end
    local index = tonumber(string.sub(id, 11))
    if self.select > 0 then
      if PuzzlePanel.ADJOINTBL[self.select][index] then
        self:Switch(self.select, index)
        self:UnselectAll()
      elseif self.select == index then
        self:UnselectAll()
      else
        self:SelectOne(index)
      end
    else
      self:SelectOne(index)
    end
  end
end
PuzzlePanel.Commit()
return PuzzlePanel
