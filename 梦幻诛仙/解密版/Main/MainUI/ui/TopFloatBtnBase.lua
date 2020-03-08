local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TabNode = require("GUI.TabNode")
local TopFloatBtnBase = Lplus.Extend(TabNode, MODULE_NAME)
local def = TopFloatBtnBase.define
def.method().ShowEntry = function(self)
  if self.m_node == nil or self.m_node.isnil then
    return
  end
  self:ShowBtn()
  self.m_base:UpdateBtnPos()
end
def.method().HideEntry = function(self)
  if self.m_node == nil or self.m_node.isnil then
    return
  end
  self:HideBtn()
  self.m_base:UpdateBtnPos()
end
def.virtual().ShowBtn = function(self)
  if self.m_node == nil or self.m_node.isnil then
    return
  end
  self.m_node:SetActive(true)
  if self.isShow then
    return
  end
  self:Show()
end
def.virtual().HideBtn = function(self)
  if self.m_node == nil or self.m_node.isnil then
    return
  end
  self.m_node:SetActive(false)
  if self.isShow == false then
    return
  end
  self:Hide()
end
def.virtual("=>", "boolean").IsOpen = function(self)
  return true
end
def.method().Destroy = function(self)
  self:HideBtn()
  self.m_base = nil
  self.m_panel = nil
  self.m_node = nil
  self.isShow = false
end
return TopFloatBtnBase.Commit()
