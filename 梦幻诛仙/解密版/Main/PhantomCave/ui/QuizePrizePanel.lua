local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local QuizePrizePanel = Lplus.Extend(ECPanelBase, "QuizePrizePanel")
local def = QuizePrizePanel.define
local instance
def.const("table").Type = {
  Text = 1,
  Graphical = 2,
  Puzzle = 3
}
def.field("number").type = 0
def.field("table").memsInfo = nil
def.field("number").bSuccess = 0
def.field("number").timerId = 0
def.field("number").countTimes = 10
local CLOSE_DELAY_TIME = 1
def.static("=>", QuizePrizePanel).Instance = function()
  if instance == nil then
    instance = QuizePrizePanel()
  end
  return instance
end
def.method("number", "table", "number", "number").ShowFinalEstimatePanel = function(self, type, memsInfo, bSuccess, countdown)
  self.type = type
  self.memsInfo = memsInfo
  self.bSuccess = bSuccess
  self.countTimes = countdown
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_QUIZE_PRIZE_PANEL, 0)
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
  self = nil
end
def.override().OnCreate = function(self)
  self:UpdateInfo()
  self:StartCountDown()
end
def.override().OnDestroy = function(self)
  self:Clear()
end
def.method().UpdateInfo = function(self)
  self:UpdateTitle()
  self:FillMembersInfo()
end
def.method().FillMembersInfo = function(self)
  local Item_List = self.m_panel:FindDirect("Img_Bg/Item_List")
  local uiList = Item_List:GetComponent("UIList")
  uiList:set_itemCount(5)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  local itemsUI = uiList:get_children()
  for i = 1, #itemsUI do
    local itemUI = itemsUI[i]
    local itemInfo = self.memsInfo[i]
    self:FillMemInfo(itemUI, i, itemInfo)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("userdata", "number", "table").FillMemInfo = function(self, itemUI, index, itemInfo)
  local Group_Player = itemUI:FindDirect(string.format("Group_Player_%d", index))
  local Group_Empty = itemUI:FindDirect(string.format("Group_Empty_%d", index))
  if itemInfo then
    Group_Player:SetActive(true)
    Group_Empty:SetActive(false)
    local Label_Name = Group_Player:FindDirect(string.format("Label_Name_%d", index)):GetComponent("UILabel")
    local Img_BgHead = Group_Player:FindDirect(string.format("Img_BgHead_%d", index))
    local Img_Head = Img_BgHead:FindDirect(string.format("Img_Head_%d", index))
    local Label_Correct = Group_Player:FindDirect(string.format("Label_Correct_%d", index)):GetComponent("UILabel")
    Label_Name:set_text(itemInfo.name)
    SetAvatarIcon(Img_Head, itemInfo.avatarId)
    SetAvatarFrameIcon(Img_BgHead, itemInfo.avatarFrameId)
    local occupationSpriteName = GUIUtils.GetOccupationSmallIcon(itemInfo.occupation)
    local occupationSprite = Group_Player:FindDirect(string.format("Img_School_%d", index)):GetComponent("UISprite")
    occupationSprite:set_spriteName(occupationSpriteName)
    local genderSprite = Group_Player:FindDirect(string.format("Img_Sex_%d", index)):GetComponent("UISprite")
    genderSprite:set_spriteName(GUIUtils.GetGenderSprite(itemInfo.sex))
    local detial = self:GetDetialByType(itemInfo)
    Label_Correct:set_text(detial)
  else
    Group_Player:SetActive(false)
    Group_Empty:SetActive(true)
  end
end
def.method("table", "=>", "string").GetDetialByType = function(self, memInfo)
  if self.type == QuizePrizePanel.Type.Text then
    local str = string.format("%d/%d", memInfo.rightnum, memInfo.totalnum)
    return str
  elseif self.type == QuizePrizePanel.Type.Graphical then
    local str = string.format(textRes.PhantomCave[18], memInfo.point)
    return str
  elseif self.type == QuizePrizePanel.Type.Puzzle then
    local str = ""
    if memInfo.ispass == 1 then
      str = textRes.PhantomCave[19]
    elseif memInfo.ispass == 0 then
      str = textRes.PhantomCave[20]
    end
    return str
  else
    return ""
  end
end
def.method().UpdateTitle = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Img_Loss = Img_Bg:FindDirect("Img_Loss")
  local Group_HY = Img_Bg:FindDirect("Group_HY")
  if self.bSuccess == 1 then
    Img_Loss:SetActive(false)
    Group_HY:SetActive(true)
  elseif self.bSuccess == 0 then
    Img_Loss:SetActive(true)
    Group_HY:SetActive(false)
  end
end
def.method().Clear = function(self)
  self:RemoveTimer()
end
def.method().ForceEndCountDown = function(self)
  self.countTimes = 0
  self:SetCountDownValue(self.countTimes)
  self:RemoveTimer()
  self:EndCountDown()
end
def.method().StartCountDown = function(self)
  self:RemoveTimer()
  self.timerId = GameUtil.AddGlobalTimer(1, false, function()
    if not self:IsShow() then
      return
    end
    self.countTimes = self.countTimes - 1
    self:SetCountDownValue(self.countTimes)
    if self.countTimes <= 0 then
      self:EndCountDown()
    end
  end)
  self:SetCountDownValue(self.countTimes)
end
def.method().RemoveTimer = function(self)
  if self.timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.timerId)
    self.timerId = 0
  end
end
def.method("number").SetCountDownValue = function(self, value)
  local uiLabel = self.m_panel:FindDirect("Img_Bg/Label_Time"):GetComponent("UILabel")
  local text = value
  if value <= 0 then
    text = 0
  end
  uiLabel.text = text
end
def.virtual("=>", "table").OnTimeout = function(self)
  return {true, true}
end
def.method().EndCountDown = function(self)
  if self.countTimes > 0 then
    return
  end
  self:DestroyPanel()
end
def.method().OnConfirmClick = function(self)
  self:ForceEndCountDown()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Confirm" then
    self:OnConfirmClick()
  end
end
return QuizePrizePanel.Commit()
