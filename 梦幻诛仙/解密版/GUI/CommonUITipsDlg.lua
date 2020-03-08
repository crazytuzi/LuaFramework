local Lplus = require("Lplus")
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
local ECPanelBase = require("GUI.ECPanelBase")
local CommonUITipsDlg = Lplus.Extend(ECPanelBase, "CommonUITipsDlg")
local def = CommonUITipsDlg.define
def.field("string").desc = ""
def.field("table").position = nil
def.field("number").textAlign = Alignment.Left
def.field("number").diappearTime = 0
def.field("number").timerId = 0
def.static("string", "table", "=>", CommonUITipsDlg).ShowCommonTip = function(desc, position)
  local tip = CommonUITipsDlg()
  tip:ShowDlg(desc, position)
  return tip
end
def.static("string", "table", "=>", CommonUITipsDlg).ShowConstTip = function(desc, position)
  local tip = CommonUITipsDlg()
  tip:ShowConstDlg(desc, position)
  return tip
end
def.static("string", "table", "number", "=>", CommonUITipsDlg).ShowConstTipWithAlign = function(desc, position, align)
  local tip = CommonUITipsDlg()
  tip.textAlign = align
  tip:ShowConstDlg(desc, position)
  return tip
end
local instance
def.static("=>", CommonUITipsDlg).Instance = function()
  if instance == nil then
    instance = CommonUITipsDlg()
  end
  return instance
end
def.method("string", "table").ShowDlg = function(self, desc, position)
  self.desc = desc
  self.position = position
  self.diappearTime = 0
  if self:IsShow() then
    self:UpdateInfo()
  else
    self:CreatePanel(RESPATH.PREFAB_COMMON_TIP_PANEL_RES, 2)
    self:SetOutTouchDisappear()
  end
end
def.method("string", "table").ShowConstDlg = function(self, desc, position)
  self.desc = desc
  self.position = position
  self.diappearTime = 0
  if self:IsShow() then
    self:UpdateInfo()
  else
    self:CreatePanel(RESPATH.PREFAB_COMMON_TIP_PANEL_RES, 0)
  end
end
def.method("string", "table", "number", "number").ShowDlgEx = function(self, desc, position, textAlign, diappearTime)
  self.desc = desc
  self.position = position
  self.textAlign = textAlign
  self.diappearTime = diappearTime
  if self:IsShow() then
    self:UpdateInfo()
  else
    self:CreatePanel(RESPATH.PREFAB_COMMON_TIP_PANEL_RES, 2)
    self:SetOutTouchDisappear()
  end
end
def.method().HideDlg = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  self:UpdateInfo()
end
def.override().OnDestroy = function(self)
  self.desc = ""
  self.position = nil
  self.timerId = 0
end
def.method().UpdateInfo = function(self)
  self:UpdateTimer()
  self:UpdateDiscribe()
  self.m_panel:SetActive(true)
  self.m_panel:set_localPosition(Vector.Vector3.new(self.position.x, self.position.y, 0))
  local uiWidget = self.m_panel:FindDirect("Label_Describe/Table_Tips"):GetComponent("UIWidget")
  uiWidget:UpdateAnchors()
end
def.method().UpdateDiscribe = function(self)
  local label = self.m_panel:FindDirect("Label_Describe"):GetComponent("UILabel")
  label:set_alignment(self.textAlign)
  label:set_text(self.desc)
  label:UpdateNGUIText()
end
def.method().UpdateTimer = function(self)
  if self.timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.timerId)
    self.timerId = 0
  end
  if self.diappearTime ~= 0 then
    self.timerId = GameUtil.AddGlobalTimer(self.diappearTime, true, function()
      self:DestroyPanel()
    end)
  end
end
CommonUITipsDlg.Commit()
return CommonUITipsDlg
