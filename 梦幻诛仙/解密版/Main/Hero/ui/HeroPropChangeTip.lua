local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local HeroPropChangTip = Lplus.Extend(ECPanelBase, "HeroPropChangTip")
local def = HeroPropChangTip.define
local HeroSecondProp = Lplus.ForwardDeclare("HeroSecondProp")
local HeroExtraProp = Lplus.ForwardDeclare("HeroExtraProp")
local Vector = require("Types.Vector")
def.const("table").attrSpriteName = {
  maxHp = "Img_QX",
  maxMp = "Img_FL",
  phyAtk = "Img_WG",
  phyDef = "Img_WF",
  magAtk = "Img_FG",
  magDef = "Img_FF",
  speed = "Img_Speed",
  antiSeal = "Img_FK",
  phyCritical = "Img_WB",
  magCritical = "Img_FB",
  sealHit = "Img_FY"
}
def.const("number").MAX_WIDGET = 3
def.const("number").WIDGET_MOVE_DURATION = 1.5
def.const("number").WIDGET_APPEAR_INTERVAL = 0.8
def.field("table")._waittingQueue = nil
def.field("table")._widgetQueue = nil
def.field("table")._transforms = nil
def.field("table")._propPair = nil
def.field("boolean")._pending = false
def.field("number")._timerId = 0
def.field("userdata").ui_Panel_Clip = nil
def.field("userdata").ui_Widget_Tween = nil
def.field("userdata").ui_Img_Label = nil
def.field("userdata").ui_Label_Green = nil
def.field("userdata").ui_Label_Red = nil
local instance
def.static("=>", HeroPropChangTip).Instance = function()
  if instance == nil then
    instance = HeroPropChangTip()
  end
  return instance
end
def.method("table").ShowTip = function(self, propMap)
  self._waittingQueue = self._waittingQueue or {}
  table.insert(self._waittingQueue, propMap)
  if self:IsShow() then
    self:ShowPendingTips()
    return
  end
  self:_ShowTip()
end
def.method()._ShowTip = function(self)
  local propPair = self._waittingQueue[1]
  if propPair == nil then
    return
  end
  self._propPair = propMap
  self.m_HideOnDestroy = true
  self:CreatePanel(RESPATH.PREFAB_PROP_CHANGE, 0)
  self:SetDepth(GUIDEPTH.TOPMOST)
end
def.method().HideTip = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:ShowPendingTips()
end
def.method().InitUI = function(self)
  self.ui_Panel_Clip = self.m_panel:FindDirect("Panel_Clip")
  self.ui_Widget_Tween = self.ui_Panel_Clip:FindDirect("Widget_Tween")
  self.ui_Widget_Tween:SetActive(false)
  self._widgetQueue = {}
  self._transforms = {}
  for i = 1, 3 do
    local transform = self.ui_Panel_Clip:FindDirect("Widget_" .. i).transform
    table.insert(self._transforms, transform)
  end
end
def.method().ShowPendingTips = function(self)
  if self._timerId ~= 0 then
    return
  end
  self:ShowOne()
  self:RemoveOne()
  self._timerId = GameUtil.AddGlobalTimer(HeroPropChangTip.WIDGET_APPEAR_INTERVAL, false, function()
    self:ShowOne()
    self:RemoveOne()
  end)
end
def.method().ShowOne = function(self)
  local propPair = self._waittingQueue[1]
  if propPair == nil then
    self:RemoveTimer()
    return
  end
  self._propPair = propPair
  local widget = GameObject.Instantiate(self.ui_Widget_Tween)
  widget.transform.parent = self.ui_Panel_Clip.transform
  widget.transform.localScale = Vector.Vector3.one
  widget.transform.localPosition = self.ui_Widget_Tween.transform.localPosition
  widget:SetActive(true)
  self:SetTipContent(widget, propPair)
  self:PushWidget(widget)
  self:MoveWidgets()
end
def.method().RemoveOne = function(self)
  table.remove(self._waittingQueue, 1)
end
def.method().RemoveTimer = function(self)
  if self._timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self._timerId)
    self._timerId = 0
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
end
def.override().OnDestroy = function(self)
end
def.method("userdata", "table").SetTipContent = function(self, widget, propPair)
  local ui_Label_Green = widget:FindDirect("Label_Green")
  local ui_Label_Red = widget:FindDirect("Label_Red")
  local ui_Img_Label = widget:FindDirect("Img_Label")
  ui_Label_Green:SetActive(false)
  ui_Label_Red:SetActive(false)
  local labelObj, imgName, labelValue
  if propPair.value > 0 then
    labelObj = ui_Label_Green
    imgName = string.format("%s_G", HeroPropChangTip.attrSpriteName[propPair.key])
    labelValue = string.format("+%d", propPair.value)
  else
    labelObj = ui_Label_Red
    imgName = string.format("%s_R", HeroPropChangTip.attrSpriteName[propPair.key])
    labelValue = string.format("%d", propPair.value)
  end
  labelObj:SetActive(true)
  labelObj:GetComponent("UILabel"):set_text(labelValue)
  local uiSprite = ui_Img_Label:GetComponent("UISprite")
  uiSprite:set_spriteName(imgName)
  uiSprite:MakePixelPerfect()
end
def.method("userdata").PushWidget = function(self, widget)
  table.insert(self._widgetQueue, 1, widget)
end
def.method().MoveWidgets = function(self)
  for i = 1, HeroPropChangTip.MAX_WIDGET do
    local widget = self._widgetQueue[i]
    if widget == nil then
      return
    end
    local dest = self._transforms[i]
    if dest then
      self:MoveUp(widget, dest)
    end
  end
  self:PopWidget()
end
def.method().PopWidget = function(self)
  local amount = #self._widgetQueue
  if amount > HeroPropChangTip.MAX_WIDGET then
    local widget = self._widgetQueue[amount]
    GameObject.Destroy(widget)
    table.remove(self._widgetQueue, #self._widgetQueue)
  end
end
def.method("userdata", "userdata").MoveUp = function(self, widget, destTransform)
  local tween = TweenTransform.BeginEx(widget, HeroPropChangTip.WIDGET_MOVE_DURATION, widget.transform, destTransform)
  tween.duration = HeroPropChangTip.WIDGET_MOVE_DURATION
end
def.method("userdata").Disapper = function(self, widget)
  TweenAlpha.Begin(widget, 0.1, 0)
end
return HeroPropChangTip.Commit()
