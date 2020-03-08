local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECPanelBase = require("GUI.ECPanelBase")
local FlashTipMan = Lplus.ForwardDeclare("FlashTipMan")
local ECPanelFlashTip = Lplus.Extend(ECPanelBase, "ECPanelFlashTip")
local def = ECPanelFlashTip.define
def.field("number").TimerID = 0
def.field("number").m_DurationTime = 0
def.field("string").m_Content = ""
def.field("string").m_category = ""
def.static("=>", ECPanelFlashTip).new = function()
  local obj = ECPanelFlashTip()
  obj.m_depthLayer = GUIDEPTH.TOP + 1
  return obj
end
def.method("number", "string", "string").UpdateContent = function(self, duration, content, category)
  self.m_Content = content
  self.m_DurationTime = duration
  self.m_category = category
end
def.method().Update = function(self)
  if not self.m_panel then
    return
  end
  if string.len(self.m_Content) ~= 0 then
    local sprite = self.m_panel:FindChild("Sprite")
    local label = self.m_panel:FindChild("Label")
    label:GetComponent("UILabel").text = self.m_Content
    sprite:GetComponent("TweenAlpha").duration = self.m_DurationTime
    label:GetComponent("TweenAlpha").duration = self.m_DurationTime
  end
  if self.TimerID ~= 0 then
    GameUtil.RemoveGlobalTimer(self.TimerID)
    self.TimerID = 0
  end
  self.TimerID = GameUtil.AddGlobalTimer(self.m_DurationTime * 2, false, function()
    FlashTipMan.Instance():RemoveFlashTip(self)
  end)
end
def.method().CreateFlashTip = function(self)
  if not self.m_panel then
    self:CreatePanel(RESPATH.Panel_FlashTip)
  end
end
def.override().OnCreate = function(self)
  self:Update()
  local temp = {}
  temp.instance = self
  temp.panel = self.m_panel
  FlashTipMan.Instance():InsertFlashTipList(temp)
end
def.override().OnDestroy = function(self)
  if self.TimerID ~= 0 then
    GameUtil.RemoveGlobalTimer(self.TimerID)
    self.TimerID = 0
  end
end
ECPanelFlashTip.Commit()
return ECPanelFlashTip
