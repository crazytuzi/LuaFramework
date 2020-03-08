local Lplus = require("Lplus")
local TopFloatBtnBase = require("Main.MainUI.ui.TopFloatBtnBase")
local MainUIDuoBaoEntry = Lplus.Extend(TopFloatBtnBase, "MainUIDuoBaoEntry")
local NotifyId = require("Main.YiYuanDuoBao.NotifyId")
local GUIUtils = require("GUI.GUIUtils")
local def = MainUIDuoBaoEntry.define
local instance
def.static("=>", MainUIDuoBaoEntry).Instance = function()
  if instance == nil then
    instance = MainUIDuoBaoEntry()
  end
  return instance
end
def.const("table").RelatedNotifyIds = {
  NotifyId.RedChange
}
def.override("=>", "boolean").IsOpen = function(self)
  local isopen = require("Main.YiYuanDuoBao.YiYuanDuoBaoModule").Instance():IsOpen()
  return isopen
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
    local bNeedRed = require("Main.YiYuanDuoBao.YiYuanDuoBaoModule").Instance():IsRed()
    GUIUtils.SetActive(Img_Red, bNeedRed)
  end
end
def.method().Register = function(self)
  for k, v in ipairs(MainUIDuoBaoEntry.RelatedNotifyIds) do
    Event.RegisterEventWithContext(ModuleId.YIYUANDUOBAO, v, MainUIDuoBaoEntry.OnUpdate, self)
  end
end
def.method().Unregister = function(self)
  for k, v in ipairs(MainUIDuoBaoEntry.RelatedNotifyIds) do
    Event.UnregisterEvent(ModuleId.YIYUANDUOBAO, v, MainUIDuoBaoEntry.OnUpdate)
  end
end
def.method("table").OnUpdate = function(self, param)
  self:UpdateRed()
end
def.override("string").onClick = function(self, id)
  require("Main.YiYuanDuoBao.YiYuanDuoBaoModule").Instance():OpenDuoBaoPanel()
end
return MainUIDuoBaoEntry.Commit()
