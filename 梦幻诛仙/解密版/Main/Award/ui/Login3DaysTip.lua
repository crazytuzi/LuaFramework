local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Login3DaysTip = Lplus.Extend(ECPanelBase, "Login3DaysTip")
local def = Login3DaysTip.define
local instance
local function Instance()
  if instance == nil then
    instance = Login3DaysTip()
  end
  return instance
end
def.static("=>", Login3DaysTip).ShowTip = function()
  local self = Instance()
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_LOGIN_3DAYS_TIP_PANEL, 2)
  self:SetModal(true)
  return self
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  end
end
def.override().OnDestroy = function(self)
  instance = nil
end
return Login3DaysTip.Commit()
