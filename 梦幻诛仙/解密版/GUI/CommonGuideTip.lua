local Lplus = require("Lplus")
local Vector = require("Types.Vector")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGame = Lplus.ForwardDeclare("ECGame")
local CommonGuideTip = Lplus.Extend(ECPanelBase, "CommonGuideTip")
CommonGuideTip.StyleEnum = {
  LEFT = 1,
  RIGHT = 0,
  UP = 2,
  DOWN = 3
}
local def = CommonGuideTip.define
def.field("string").content = ""
def.field("table").rect = nil
def.field("number").style = CommonGuideTip.StyleEnum.LEFT
def.static("string", "userdata", "number", "=>", CommonGuideTip).ShowGuideTip = function(content, target, style)
  if target == nil or target.isnil then
    return nil
  end
  local tip = CommonGuideTip()
  local box = target:GetComponent("BoxCollider")
  local gx = target.position.x
  local gy = target.position.y
  local screenPos = WorldPosToScreen(gx, gy)
  if box then
    screenPos.x = screenPos.x + box.center.x
    screenPos.y = screenPos.y + box.center.y
  end
  local widget = target:GetComponent("UIWidget")
  local w = box and box.size.x or widget and widget.width or 0
  local h = box and box.size.y or widget and widget.height or 0
  if w <= 0 or h <= 0 then
    warn("[ShowGuideTip]Invalid target size")
    return nil
  end
  tip:ShowDlg(content, screenPos.x, screenPos.y, w, h, style)
  return tip
end
def.method("string", "number", "number", "number", "number", "number").ShowDlg = function(self, tip, x, y, w, h, style)
  self.content = tip
  self.rect = {
    x = x,
    y = y,
    w = w,
    h = h
  }
  self.style = style
  if self:IsShow() then
    self:UpdateInfo()
  else
    self:CreatePanel(RESPATH.PREFAB_COMMON_GUIDE_TIP, 0)
  end
end
def.method().HideDlg = function(self)
  self:DestroyPanel()
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self.m_panel:SetActive(true)
  self:UpdateInfo()
end
def.override().OnDestroy = function(self)
  self.content = ""
  self.rect = nil
  self.style = 0
end
def.method().UpdateInfo = function(self)
  self:UpdateContent()
  self.m_panel.localPosition = Vector.Vector3.new(self.rect.x, self.rect.y, 0)
  local groupInfo = self.m_panel:FindDirect("Group_All/Group_Info")
  local contentBg = groupInfo:FindDirect("Img_Info")
  local labelbg = contentBg:GetComponent("UIWidget")
  local groupEff = self.m_panel:FindDirect("Group_All/Group_Effect")
  local eff = groupEff:FindDirect("UI_Effect")
  local effObj = eff:GetComponent("UIParticle").gameObject
  local arrow = groupEff:FindDirect("Arrow")
  local arrowSize = arrow:GetComponent("UIWidget")
  local uiWidget = effObj:GetComponent("UIWidget")
  eff.localScale = Vector.Vector3.new(self.rect.w / uiWidget.width, self.rect.h / uiWidget.height, 1)
  if self.style == CommonGuideTip.StyleEnum.LEFT then
    arrow.localRotation = Quaternion.Euler(Vector.Vector3.new(0, 0, 0))
    arrow.localPosition = Vector.Vector3.new(-self.rect.w / 2 - arrowSize.width / 2 - 2, 0, arrow.localPosition.z)
    groupInfo.localPosition = Vector.Vector3.new(-(labelbg.width + self.rect.w) / 2 - arrowSize.width, 0, 0)
  elseif self.style == CommonGuideTip.StyleEnum.RIGHT then
    arrow.localRotation = Quaternion.Euler(Vector.Vector3.new(0, 0, 180))
    arrow.localPosition = Vector.Vector3.new(self.rect.w / 2 + arrowSize.width / 2 + 2, 0, arrow.localPosition.z)
    groupInfo.localPosition = Vector.Vector3.new((labelbg.width + self.rect.w) / 2 + arrowSize.width, 0, 0)
  elseif self.style == CommonGuideTip.StyleEnum.DOWN then
    arrow.localRotation = Quaternion.Euler(Vector.Vector3.new(0, 0, 90))
    arrow.localPosition = Vector.Vector3.new(0, -(self.rect.h / 2 + arrowSize.width / 2 + 2), arrow.localPosition.z)
    groupInfo.localPosition = Vector.Vector3.new(0, -(labelbg.height + self.rect.h) / 2 - arrowSize.width, 0)
  elseif self.style == CommonGuideTip.StyleEnum.UP then
    arrow.localRotation = Quaternion.Euler(Vector.Vector3.new(0, 0, 270))
    arrow.localPosition = Vector.Vector3.new(0, self.rect.h / 2 + arrowSize.width / 2 + 2, arrow.localPosition.z)
    groupInfo.localPosition = Vector.Vector3.new(0, (labelbg.height + self.rect.h) / 2 + arrowSize.width, 0)
  end
end
def.method().UpdateContent = function(self)
  if self.m_panel == nil then
    return
  end
  local label = self.m_panel:FindDirect("Group_All/Group_Info/Label_Info"):GetComponent("UILabel")
  label.text = self.content
  label:UpdateNGUIText()
end
CommonGuideTip.Commit()
return CommonGuideTip
