local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TopFloatBtnBase = require("Main.MainUI.ui.TopFloatBtnBase")
local MonkeyRunEntry = Lplus.Extend(TopFloatBtnBase, "MonkeyRunEntry")
local GUIUtils = require("GUI.GUIUtils")
local def = MonkeyRunEntry.define
local instance
def.static("=>", MonkeyRunEntry).Instance = function()
  if instance == nil then
    instance = MonkeyRunEntry()
  end
  return instance
end
def.override().OnShow = function(self)
  self:UpdateNotifyBadge()
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Notify_Change, MonkeyRunEntry.OnNotifyUpdate)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, MonkeyRunEntry.OnNotifyUpdate)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Notify_Change, MonkeyRunEntry.OnNotifyUpdate)
  Event.UnregisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, MonkeyRunEntry.OnNotifyUpdate)
end
def.override("=>", "boolean").IsOpen = function(self)
  local MonkeyRunMgr = require("Main.activity.MonkeyRun.MonkeyRunMgr")
  return MonkeyRunMgr.Instance():IsActivityOpened()
end
def.method().UpdateNotifyBadge = function(self)
  local Btn_MonkeyRun = self.m_node
  local Img_Red = Btn_MonkeyRun:FindDirect("Img_Red")
  local MonkeyRunMgr = require("Main.activity.MonkeyRun.MonkeyRunMgr")
  local hasNotify = MonkeyRunMgr.Instance():HasMonkeyRunNotify()
  if hasNotify then
    GUIUtils.SetLightEffect(Btn_MonkeyRun, GUIUtils.Light.Round)
    Img_Red:SetActive(false)
  else
    GUIUtils.SetLightEffect(Btn_MonkeyRun, GUIUtils.Light.None)
    Img_Red:SetActive(false)
  end
end
def.override("string").onClick = function(self, id)
  if id == "Btn_MonkeyRun" then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_MONKEYRUN_CLICK, nil)
  end
end
def.static("table", "table").OnNotifyUpdate = function(params, context)
  local self = instance
  self:UpdateNotifyBadge()
end
return MonkeyRunEntry.Commit()
