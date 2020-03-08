local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local DlgConfirm = Lplus.Extend(ECPanelBase, "DlgConfirm")
local EC = require("Types.Vector3")
local def = DlgConfirm.define
def.field("number").id = 0
def.static("number", "=>", DlgConfirm).new = function(id)
  local obj = DlgConfirm()
  obj.id = id
  return obj
end
def.method().ShowDlg = function(self)
  if self:IsShow() then
    self:UpdateInfo()
  else
    self:CreatePanel(RESPATH.PREFAB_LAYOUT_CONFIRM_PANEL, 0)
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
end
def.override().OnDestroy = function(self)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Yes" then
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.END_EDIT, {
      self.id
    })
  elseif id == "Btn_No" then
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.CANCEL_EDIT, {
      self.id
    })
  elseif id == "Btn_Cancel" then
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.OPPOSITE, {
      self.id
    })
  end
end
def.method("table").SetPos = function(self, pos)
  if self.m_panel == nil or pos == nil then
    return
  end
  self.m_panel.localPosition = pos
end
def.method().UpdateInfo = function(self)
end
return DlgConfirm.Commit()
