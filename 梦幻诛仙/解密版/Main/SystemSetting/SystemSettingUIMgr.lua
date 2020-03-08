local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local SystemSettingUIMgr = Lplus.Class("SystemSettingUIMgr")
local def = SystemSettingUIMgr.define
local UISet = {
  SystemSettingPanel = "SystemSettingPanel"
}
def.const("table").UISet = UISet
def.field("string").modulePrefix = ""
local instance
def.static("=>", SystemSettingUIMgr).Instance = function()
  if instance == nil then
    instance = SystemSettingUIMgr()
  end
  return instance
end
def.method().Init = function(self)
  self:InitModulePrefix()
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_SYSTEM_SETTING_CLICK, SystemSettingUIMgr.OnSystemSettingButtonClick)
end
def.method().InitModulePrefix = function(self)
  local sPos, ePos = string.find(MODULE_NAME, ".[%w_]+$")
  self.modulePrefix = string.sub(MODULE_NAME, 1, sPos - 1)
end
def.method("string", "=>", "table").GetUI = function(self, uiName)
  return require(self.modulePrefix .. ".ui." .. uiName)
end
def.static("table", "table").OnSystemSettingButtonClick = function()
  local self = instance
  self:GetUI(UISet.SystemSettingPanel).Instance():ShowPanel()
end
def.static().ShowSetSuccessMessage = function()
  Toast(textRes.SystemSetting[1])
end
def.static().ShowUnsetSuccessMessage = function()
  Toast(textRes.SystemSetting[2])
end
return SystemSettingUIMgr.Commit()
