local Lplus = require("Lplus")
local MainUIComponentBase = Lplus.Class("MainUIComponentBase")
local MainUIPanel = Lplus.ForwardDeclare("MainUIPanel")
local FightMgr = require("Main.Fight.FightMgr")
local BitMap = require("Types.BitMap")
local Vector = require("Types.Vector")
local def = MainUIComponentBase.define
local Dir = {
  Left = 1,
  Top = 2,
  Right = 3,
  Bottom = 4
}
def.const("table").Dir = Dir
def.field("userdata").m_node = nil
def.field("userdata").m_anchorNode = nil
def.field("userdata").m_panel = nil
def.field("userdata").m_parent = nil
def.field(MainUIPanel).m_container = nil
def.field("boolean").m_isShow = false
def.field(BitMap).m_displayableBitMap = nil
def.virtual().Init = function(self)
end
def.virtual().OnCreate = function(self)
end
def.method().Destroy = function(self)
  self.m_isShow = false
  self.m_node = nil
  self.m_anchorNode = nil
  self:OnDestroy()
end
def.virtual().OnDestroy = function(self)
end
def.virtual("number").OnLayerChange = function(self, layer)
end
def.virtual("boolean").SetVisible = function(self, visible)
  if visible then
    self.m_node:GetComponent("UIWidget"):set_alpha(1)
  else
    self.m_node:GetComponent("UIWidget"):set_alpha(0)
  end
end
def.method().Show = function(self)
  if self.m_node then
    self.m_node:SetActive(true)
    self:SetVisible(true)
  end
  if self:IsShow() then
    return
  end
  self.m_isShow = true
  self:OnShow()
end
def.virtual("=>", "boolean").CanDispaly = function(self)
  return true
end
def.method().Hide = function(self)
  if self.m_node then
    self.m_node:SetActive(false)
  end
  self:PassiveHide()
end
def.method().PassiveHide = function(self)
  if not self:IsShow() then
    return
  end
  self.m_isShow = false
  self:OnHide()
end
def.virtual().OnShow = function(self)
end
def.virtual().OnHide = function(self)
end
def.virtual().OnEnterFight = function(self)
end
def.virtual().OnLeaveFight = function(self)
end
def.method("=>", "boolean").IsShow = function(self)
  return self.m_isShow
end
def.method("=>", "boolean").IsInFight = function(self)
  return FightMgr.Instance().isInFight
end
def.virtual("string").OnClick = function(self, id)
end
def.virtual("string", "boolean").OnToggle = function(self, id, value)
end
def.virtual("=>", "boolean").CanShowInFight = function(self)
  return false
end
def.method("userdata", "number", "boolean").SetSliderBar = function(self, slider, value, isAutoProgress)
  if isAutoProgress then
    local lastValue = slider:get_sliderValue()
    local time = 0.5
    slider:AutoProgress(true, lastValue, value, time)
  else
    slider:set_sliderValue(value)
  end
end
def.virtual().Expand = function(self)
  if self.m_node == nil then
    return
  end
  local tweenPosition = self.m_node:GetComponent("TweenPosition")
  if tweenPosition then
    if self.m_anchorNode and self.m_anchorNode.isnil == false then
      tweenPosition.from = self.m_anchorNode.localPosition
    end
    tweenPosition:PlayReverse()
  end
end
def.virtual().Shrink = function(self)
  if self.m_node == nil then
    return
  end
  local widget = self.m_node:GetComponent("UIWidget")
  local transform = self.m_node.transform
  local dir
  if widget.width > widget.height then
    if transform.localPosition.y > 0 then
      dir = Dir.Top
    else
      dir = Dir.Bottom
    end
  elseif 0 < transform.localPosition.x then
    dir = Dir.Right
  else
    dir = Dir.Left
  end
  self:_Shrink(self.m_node, dir)
end
def.method("userdata", "number")._Shrink = function(self, node, dir)
  if node == nil then
    return
  end
  if self.m_anchorNode == nil or self.m_anchorNode.isnil then
    self.m_anchorNode = GameObject.GameObject("anchorNode")
    self.m_anchorNode:SetLayer(ClientDef_Layer.UI)
    self.m_anchorNode.parent = node.parent
    self.m_anchorNode.localScale = Vector.Vector3.one
    self.m_anchorNode.localPosition = node.localPosition
    local tmpNode = GameObject.Instantiate(node)
    local uiWidget = tmpNode:GetComponent("UIWidget")
    if uiWidget then
      local cloneWidget = self.m_anchorNode:AddComponent("UIWidget")
      cloneWidget.pivot = uiWidget.pivot
      cloneWidget.leftAnchor = uiWidget.leftAnchor
      cloneWidget.rightAnchor = uiWidget.rightAnchor
      cloneWidget.bottomAnchor = uiWidget.bottomAnchor
      cloneWidget.topAnchor = uiWidget.topAnchor
      cloneWidget:set_updateAnchors(0)
    end
    GameObject.Destroy(tmpNode)
  end
  local tweenPosition = node:GetComponent("TweenPosition")
  if tweenPosition == nil then
    tweenPosition = node:AddComponent("TweenPosition")
    tweenPosition.from = node.transform.localPosition
    tweenPosition.to = Vector.Vector3.zero
    tweenPosition.duration = 0.4
    tweenPosition.steeperCurves = true
    local widget = node:GetComponent("UIWidget")
    local transform = node.transform
    local GUIMan = require("GUI.ECGUIMan")
    local uiRoot = GUIMan.Instance().m_uiRootCom
    local uiscreenWidth = Screen.width * uiRoot:GetPixelSizeAdjustment_int(Screen.height)
    local uiscreenHeight = uiRoot.activeHeight
    local x, y
    if dir == Dir.Top then
      x = transform.localPosition.x
      y = uiscreenHeight
    elseif dir == Dir.Bottom then
      x = transform.localPosition.x
      y = -uiscreenHeight
    elseif dir == Dir.Right then
      x = uiscreenWidth
      y = transform.localPosition.y
    elseif dir == Dir.Left then
      x = -uiscreenWidth
      y = transform.localPosition.y
    end
    tweenPosition.to = Vector.Vector3.new(x, y, 0)
  else
    tweenPosition.from = self.m_anchorNode.localPosition
  end
  tweenPosition:PlayForward()
end
def.method("table").SetUndisplayScenes = function(self, sceneids)
  if self.m_displayableBitMap == nil then
    self.m_displayableBitMap = BitMap.New(0)
  end
  for i, id in ipairs(sceneids) do
    self.m_displayableBitMap:SetBit(id, 1)
  end
end
def.virtual().CheckDisplayable = function(self)
  if self.m_displayableBitMap == nil then
    if not self:IsShow() then
      self:Show()
    end
    return
  end
  local MainUIModule = require("Main.MainUI.MainUIModule")
  local sceneBitMap = MainUIModule.Instance().sceneBitMap
  if self.m_displayableBitMap:AND(sceneBitMap):IsZero() then
    self:Show()
  else
    self:Hide()
  end
end
MainUIComponentBase.Commit()
return MainUIComponentBase
