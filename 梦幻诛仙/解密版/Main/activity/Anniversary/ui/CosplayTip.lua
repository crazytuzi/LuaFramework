local Lplus = require("Lplus")
local AnnouncementTip = require("GUI.AnnouncementTip")
local ECPanelBase = require("GUI.ECPanelBase")
local CosplayTip = Lplus.Extend(ECPanelBase, "CosplayTip")
local instance
local def = CosplayTip.define
def.field("string").content = ""
def.field("userdata").label = nil
def.static("=>", CosplayTip).Instance = function()
  if instance == nil then
    instance = CosplayTip()
  end
  return instance
end
def.method("string").ShowPanel = function(self, content)
  self.content = content
  if self:IsShow() then
    self:SetContent(content)
  else
    instance:CreatePanel(RESPATH.PREFAB_ACTIVITY_COSPLAY_TIP, -1)
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
CosplayTip.Commit()
return CosplayTip
