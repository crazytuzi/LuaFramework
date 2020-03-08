local Lplus = require("Lplus")
local TopFloatBtnBase = require("Main.MainUI.ui.TopFloatBtnBase")
local BackToGameMainUIEntry = Lplus.Extend(TopFloatBtnBase, "BackToGameMainUIEntry")
local GUIUtils = require("GUI.GUIUtils")
local BackToGameModule = require("Main.BackToGame.BackToGameModule")
local NotifyId = require("Main.BackToGame.NotifyId")
local def = BackToGameMainUIEntry.define
local instance
def.static("=>", BackToGameMainUIEntry).Instance = function()
  if instance == nil then
    instance = BackToGameMainUIEntry()
  end
  return instance
end
def.const("table").RelatedNotifyIds = {
  NotifyId.DailySignUpdate,
  NotifyId.ActivityUpdate,
  NotifyId.ExpUpdate,
  NotifyId.TaskUpdate,
  NotifyId.BackHomeUpdate,
  NotifyId.LimitSellUpdate,
  NotifyId.CatTokenChange
}
def.override("=>", "boolean").IsOpen = function(self)
  return BackToGameModule.Instance():IsBackGamePlayer()
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
    local bNeedRed = BackToGameModule.Instance():IsRed()
    GUIUtils.SetActive(Img_Red, bNeedRed)
  end
end
def.method().Register = function(self)
  for k, v in ipairs(BackToGameMainUIEntry.RelatedNotifyIds) do
    Event.RegisterEventWithContext(ModuleId.BACK_TO_GAME, v, BackToGameMainUIEntry.OnUpdate, self)
  end
end
def.method().Unregister = function(self)
  for k, v in ipairs(BackToGameMainUIEntry.RelatedNotifyIds) do
    Event.UnregisterEvent(ModuleId.BACK_TO_GAME, v, BackToGameMainUIEntry.OnUpdate)
  end
end
def.method("table").OnUpdate = function(self, param)
  self:UpdateRed()
end
def.override("string").onClick = function(self, id)
  BackToGameModule.Instance():ShowBackToGame()
end
return BackToGameMainUIEntry.Commit()
