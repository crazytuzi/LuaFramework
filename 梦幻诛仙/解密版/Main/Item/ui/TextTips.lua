local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TextTips = Lplus.Extend(ECPanelBase, "TextTips")
local Vector = require("Types.Vector")
local def = TextTips.define
def.field("string").title = ""
def.field("string").desc1 = ""
def.field("string").desc2 = ""
def.field("string").desc3 = ""
def.field("table").position = nil
def.static("string", "string", "string", "string", "number", "number").ShowTextTip = function(title, desc1, desc2, desc3, x, y)
  local tip = TextTips()
  tip.title = title
  tip.desc1 = desc1
  tip.desc2 = desc2
  tip.desc3 = desc3
  tip.position = {x = x, y = y}
  tip:CreatePanel(RESPATH.TEXTTIP, 2)
  tip:SetOutTouchDisappear()
end
def.override().OnCreate = function(self)
  self:UpdateTitle()
  self:UpdateDesc()
  self:UpdatePosition()
end
def.method().UpdatePosition = function(self)
  self:SetLayer(ClientDef_Layer.Invisible)
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if self.m_panel and not self.m_panel.isnil then
      local tipFrame = self.m_panel:FindDirect("Img_Bg0")
      local widget = tipFrame:GetComponent("UIWidget")
      local width = widget:get_width()
      local height = widget:get_height()
      local x = self.position.x - width / 2
      local y = self.position.y + height
      tipFrame:set_localPosition(Vector.Vector3.new(x, y, 0))
      self:SetLayer(ClientDef_Layer.UI)
    end
  end)
end
def.method().UpdateTitle = function(self)
  local titleGo = self.m_panel:FindDirect("Img_Bg0/Label_QLTtile")
  if self.title == "" then
    titleGo:SetActive(false)
  else
    titleGo:SetActive(true)
    titleGo:GetComponent("UILabel"):set_text(self.title)
  end
end
def.method().UpdateDesc = function(self)
  local label1Go = self.m_panel:FindDirect("Img_Bg0/Label_QLStatus")
  if self.desc1 == "" then
    label1Go:SetActive(false)
  else
    label1Go:SetActive(true)
    label1Go:GetComponent("UILabel"):set_text(self.desc1)
  end
  local label2Go = self.m_panel:FindDirect("Img_Bg0/Label_QLCondition")
  if self.desc2 == "" then
    label2Go:SetActive(false)
  else
    label2Go:SetActive(true)
    label2Go:GetComponent("UILabel"):set_text(self.desc2)
  end
  local label3Go = self.m_panel:FindDirect("Img_Bg0/Label_QLAdd")
  if self.desc3 == "" then
    label3Go:SetActive(false)
  else
    label3Go:SetActive(true)
    label3Go:GetComponent("UILabel"):set_text(self.desc3)
  end
end
def.override().OnDestroy = function(self)
end
TextTips.Commit()
return TextTips
