local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local SwornMgr = require("Main.Sworn.SwornMgr")
local LeavePanel = Lplus.Extend(ECPanelBase, "LeavePanel")
local def = LeavePanel.define
local instance
def.static("=>", LeavePanel).Instance = function()
  if not instance then
    instance = LeavePanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_JIE_YI_LEAVE_PANEL, GUILEVEL.MUTEX)
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
end
def.method().LeaveConfirm = function(self)
  CommonConfirmDlg.ShowConfirmCoundDown(textRes.Sworn[26], textRes.Sworn[27], "", "", 0, 0, function(selection, tag)
    if selection == 1 then
      SwornMgr.LeaveSwornReq()
    end
  end, nil)
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Refuse" then
    self:DestroyPanel()
  elseif id == "Btn_Confirm" then
    self:DestroyPanel()
    self:LeaveConfirm()
  end
end
return LeavePanel.Commit()
