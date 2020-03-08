local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local FlipCardPanel = Lplus.Extend(ECPanelBase, CUR_CLASS_NAME)
local def = FlipCardPanel.define
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local CLOSE_DELAY_TIME = 3
def.field("table").uiObjs = nil
def.field("number").timerId = 0
def.field("number").countTimes = 5
def.method("number").ShowPanelEx = function(self, countdown)
  self.countTimes = countdown
  self:CreatePanel(RESPATH.PREFAB_JZJX_AWARD_PANEL, 0)
end
def.method("number", "number", "number", "string").FlipOverCard = function(self, index, itemId, num, rolename)
  local itemBase = ItemUtils.GetItemBase(itemId)
  self:FlipOverCardEx(index, itemBase, num, rolename)
end
def.method("number", "table", "number", "string").FlipOverCardEx = function(self, index, itemBase, num, rolename)
  local iconId = itemBase.icon
  local itemObj = self.uiObjs.Item_List:FindDirect("item_" .. index)
  if itemObj == nil then
    warn(string.format("FlipOverCardEx failed to flip card (index = %d)", index))
    return
  end
  local nameLabel = itemObj:FindDirect("Label"):GetComponent("UILabel")
  nameLabel.text = rolename
  local Img_BgPrize = GUIUtils.FindDirect(itemObj, "Img_BgPrize")
  local sprite = GUIUtils.FindDirect(Img_BgPrize, "Sprite")
  local spriteName = string.format("Cell_%02d", itemBase.namecolor)
  GUIUtils.SetSprite(sprite, spriteName)
  local texture = GUIUtils.FindDirect(sprite, "Icon")
  GUIUtils.SetTexture(texture, iconId)
  local Label_item = GUIUtils.FindDirect(sprite, "Label_item")
  local itemColor = HtmlHelper.NameColor[itemBase.namecolor]
  local text = string.format("[%s]%sx%d[-]", "ffffff", itemBase.name, num)
  GUIUtils.SetText(Label_item, text)
  local playTween = Img_BgPrize:GetComponent("UIPlayTween")
  playTween:Play(true)
end
def.method().ForceEndCountDown = function(self)
  self.countTimes = 0
  self:SetCountDownValue(self.countTimes)
  self:RemoveTimer()
  self:EndCountDown()
end
def.virtual("number").OnCardSelected = function(self, index)
end
def.virtual("=>", "table").OnTimeout = function(self)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  self:StartCountDown()
  self:SetModal(true)
end
def.override().OnDestroy = function(self)
  self:Clear()
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.uiObjs.Label_TimeLeft = self.uiObjs.Img_Bg:FindDirect("Label_TimeLeft")
  self.uiObjs.Item_List = self.uiObjs.Img_Bg:FindDirect("Item_List")
  local uiList = self.uiObjs.Item_List:GetComponent("UIList")
  uiList.itemCount = uiList.itemCount
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, uiList.itemCount do
    local uiItem = uiItems[i]
    GUIUtils.SetText(uiItem:FindDirect("Label"), "")
    local Img_BgPrize = uiItem:FindDirect("Img_BgPrize")
    local playTween = Img_BgPrize:GetComponent("UIPlayTween")
    playTween.enabled = false
  end
  local Vector = require("Types.Vector")
  local boxCollider = self.uiObjs.Img_Bg:GetComponent("BoxCollider")
  if boxCollider == nil then
    boxCollider = self.uiObjs.Img_Bg:AddComponent("BoxCollider")
  end
  boxCollider.size = Vector.Vector3.new(2048, 2048, 0)
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().Clear = function(self)
  self:RemoveTimer()
  self.uiObjs = nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Img_BgPrize" then
    local parentObj = obj.transform.parent.gameObject
    local index = tonumber(string.sub(parentObj.name, #"item_" + 1, -1))
    self:OnCardSelected(index)
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
end
def.method().UpdateUI = function(self)
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
  local uiLabel = self.uiObjs.Label_TimeLeft:GetComponent("UILabel")
  local text = value
  if value <= 0 then
    text = 0
  end
  uiLabel.text = text
end
def.method().EndCountDown = function(self)
  if self.countTimes > 0 then
    return
  end
  local canClose, isfliped = unpack(self:OnTimeout())
  if not canClose then
    return
  end
  local time = CLOSE_DELAY_TIME
  if isfliped then
    time = time + 1
  end
  GameUtil.AddGlobalTimer(time, true, function()
    self:DestroyPanel()
  end)
end
return FlipCardPanel.Commit()
