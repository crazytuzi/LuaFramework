local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BakeCakeTip = Lplus.Extend(ECPanelBase, MODULE_NAME)
local def = BakeCakeTip.define
def.field("string").content = ""
def.field("userdata").label = nil
local instance
def.static("=>", BakeCakeTip).Instance = function()
  if instance == nil then
    instance = BakeCakeTip()
  end
  return instance
end
def.method("string").ShowPanel = function(self, content)
  self.content = content
  if self:IsLoaded() then
    self:SetContent(content)
  else
    instance:CreatePanel(RESPATH.PREFAB_BAKECAKE_TIP, 0)
  end
end
def.override("boolean").OnShow = function(self, show)
  if not show then
    return
  end
  self:SetDepth(GUIDEPTH.TOPMOST)
  self:SetContent(self.content)
end
def.method("string").SetContent = function(self, content)
  self.content = content
  if self.m_panel == nil then
    return
  end
  self.label:GetComponent("UILabel"):set_text(self.content)
end
def.method("=>", "string").GetContent = function(self, content)
  return self.content
end
def.override().OnCreate = function(self)
  self.label = self.m_panel:FindDirect("Group_Info/Label_Info")
end
BakeCakeTip.Commit()
return BakeCakeTip
