local Lplus = require("Lplus")
local TopFloatBtnBase = require("Main.MainUI.ui.TopFloatBtnBase")
local WelcomePartyEntry = Lplus.Extend(TopFloatBtnBase, "WelcomePartyEntry")
local GUIUtils = require("GUI.GUIUtils")
local def = WelcomePartyEntry.define
local instance
local NotifyId = require("Main.WelcomeParty.NotifyId")
local WelcomePartyModule = require("Main.WelcomeParty.WelcomePartyModule")
def.const("table").RelatedNotifyIds = {
  NotifyId.TAB_NOTIFY_STATE_CHG
}
def.static("=>", WelcomePartyEntry).Instance = function()
  if instance == nil then
    instance = WelcomePartyEntry()
  end
  return instance
end
def.override("=>", "boolean").IsOpen = function(self)
  return WelcomePartyModule.Instance():IsOpen()
end
def.override().OnShow = function(self)
  self:UpdateRed()
  self:Register()
end
def.override().OnHide = function(self)
  self:Unregister()
end
def.method().UpdateRed = function(self)
  local Img_Red = self.m_node:FindDirect("Img_Red")
  if Img_Red then
    local bNeedRed = WelcomePartyModule.IsShowRedDot()
    GUIUtils.SetActive(Img_Red, bNeedRed)
  end
end
def.method().Register = function(self)
  for k, v in ipairs(WelcomePartyEntry.RelatedNotifyIds) do
    Event.RegisterEventWithContext(ModuleId.WELCOME_PARTY, v, WelcomePartyEntry.OnUpdate, self)
  end
end
def.method().Unregister = function(self)
  for k, v in ipairs(WelcomePartyEntry.RelatedNotifyIds) do
    Event.UnregisterEvent(ModuleId.WELCOME_PARTY, v, WelcomePartyEntry.OnUpdate)
  end
end
def.method("table").OnUpdate = function(self, param)
  self:UpdateRed()
end
def.override("string").onClick = function(self, id)
  require("Main.WelcomeParty.ui.UIWelcomePartyBasic").Instance():ShowPanel()
end
return WelcomePartyEntry.Commit()
