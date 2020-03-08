local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MiniGameTip = Lplus.Extend(ECPanelBase, "MiniGameTip")
local GUIUtils = require("GUI.GUIUtils")
local def = MiniGameTip.define
def.field("string").content = ""
def.field("function").endCallback = nil
local instance
def.static("=>", MiniGameTip).Instance = function()
  if instance == nil then
    instance = MiniGameTip()
  end
  return instance
end
def.method("string", "function").ShowDlg = function(self, content, callback)
  if self:IsShow() then
    return
  end
  self.content = content
  self.endCallback = callback
  self:CreatePanel(RESPATH.PREFAB_CHILDREN_TIPS, 0)
  self:SetModal(true)
  self:SetDepth(GUIDEPTH.TOPMOST2)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    local Drag_Tips = self.m_panel:FindDirect("Img_Bg/Scrollview_Tips/Drag_Tips")
    Drag_Tips:GetComponent("UILabel"):set_text(self.content)
  else
  end
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
end
def.method().Hide = function(self)
  self:DestroyPanel()
  if self.endCallback then
    self.endCallback()
    self.endCallback = nil
  end
  self.content = ""
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Confirm" then
    self:Hide()
  end
end
MiniGameTip.Commit()
return MiniGameTip
