local Lplus = require("Lplus")
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
local ECPanelBase = require("GUI.ECPanelBase")
local CommonUIScrollTip = Lplus.Extend(ECPanelBase, "CommonUIScrollTip")
local def = CommonUIScrollTip.define
def.const("number").MAX_HEIGHT = 350
def.field("string").desc = ""
def.field("table").position = nil
def.field("number").textAlign = Alignment.Left
def.field("number").diappearTime = 0
def.field("number").timerId = 0
def.static("string", "table", "=>", CommonUIScrollTip).ShowCommonTip = function(desc, position)
  local tip = CommonUIScrollTip.Instance()
  tip:ShowDlg(desc, position)
  return tip
end
def.static("string", "table", "=>", CommonUIScrollTip).ShowConstTip = function(desc, position)
  local tip = CommonUIScrollTip.Instance()
  tip:ShowConstDlg(desc, position)
  return tip
end
local instance
def.static("=>", CommonUIScrollTip).Instance = function()
  if instance == nil then
    instance = CommonUIScrollTip()
  end
  return instance
end
def.method("string", "table").ShowDlg = function(self, desc, position)
  self.desc = desc
  self.position = position
  self.textAlign = Alignment.Left
  self.diappearTime = 0
  if self:IsShow() then
    self:UpdateInfo()
  else
    self:CreatePanel(RESPATH.PREFAB_COMMON_SCROLL_TIP_PANEL_RES, 2)
    self:SetOutTouchDisappear()
  end
end
def.method("string", "table").ShowConstDlg = function(self, desc, position)
  self.desc = desc
  self.position = position
  self.textAlign = Alignment.Left
  self.diappearTime = 0
  if self:IsShow() then
    self:UpdateInfo()
  else
    self:CreatePanel(RESPATH.PREFAB_COMMON_SCROLL_TIP_PANEL_RES, 0)
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
  self:UpdateContent()
  self.m_panel:SetActive(true)
  self.m_panel:set_localPosition(Vector.Vector3.new(self.position.x, self.position.y, 0))
end
def.method().UpdateContent = function(self)
  local Scrollview = self.m_panel:FindDirect("Group_Tips/Scrollview_Note")
  local label = Scrollview:FindDirect("Drag_Tips"):GetComponent("UILabel")
  label:set_alignment(self.textAlign)
  label:set_text(self.desc)
  label:UpdateNGUIText()
  local labelHeight = label:GetComponent("UILabel").height
  local bg = self.m_panel:FindDirect("Table_Tips")
  bg:GetComponent("UIWidget").height = math.min(labelHeight, CommonUIScrollTip.MAX_HEIGHT)
  GameUtil.AddGlobalTimer(0.05, true, function()
    if self.m_panel == nil then
      return
    end
    Scrollview:GetComponent("UIScrollView"):ResetPosition()
  end)
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
CommonUIScrollTip.Commit()
return CommonUIScrollTip
