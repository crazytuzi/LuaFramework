local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local WaitingTip = Lplus.Extend(ECPanelBase, "WaitingTip")
local def = WaitingTip.define
def.field("string")._tip = ""
def.field("table").uiObjs = nil
def.field("number").delayTime = 0
def.field("number").delayTimerId = 0
def.static("string").ShowTip = function(content)
  WaitingTip.ShowTipEx(content, {delayTime = 0})
end
def.static("string", "table").ShowTipEx = function(content, params)
  local self = WaitingTip._Instance()
  self._tip = content
  self.delayTime = params.delayTime
  if self:IsShow() then
    self:UpdateTip()
    return
  elseif self:IsLoaded() then
    self:DestroyPanel()
  end
  self:SetDepth(4)
  self:CreatePanel(RESPATH.PREFAB_COMMON_WAITING_PANEL, 0)
  self:SetModal(true)
end
def.static().HideTip = function()
  local self = WaitingTip._Instance()
  self:DestroyPanel()
end
local instance
def.static("=>", WaitingTip)._Instance = function()
  if instance == nil then
    instance = WaitingTip()
  end
  return instance
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateTip()
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Tex_Beauty = self.uiObjs.Img_Bg0:FindDirect("Tex_Beauty")
  self.uiObjs.Label = self.uiObjs.Img_Bg0:FindDirect("Label")
  self:StartDelayTimer()
end
def.override().OnDestroy = function(self)
  self._tip = ""
  self.uiObjs = nil
  self.delayTime = 0
  self:StopDelayTimer()
end
def.method("string").onClick = function(self, id)
end
def.method().UpdateTip = function(self)
  self.uiObjs.Label:GetComponent("UILabel").text = self._tip
end
def.method().StartDelayTimer = function(self)
  self:StopDelayTimer()
  if self.delayTime == 0 then
    return
  end
  self.m_panel:SetActive(false)
  self.delayTimerId = GameUtil.AddGlobalTimer(self.delayTime, true, function(...)
    self:OnDelayTimer()
  end)
end
def.method().StopDelayTimer = function(self)
  if self.delayTimerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.delayTimerId)
    self.delayTimerId = 0
  end
end
def.method().OnDelayTimer = function(self)
  self.delayTimerId = 0
  if _G.IsNil(self.m_panel) then
    return
  end
  self.m_panel:SetActive(true)
end
return WaitingTip.Commit()
