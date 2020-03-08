local Lplus = require("Lplus")
local TopFloatBtnBase = require("Main.MainUI.ui.TopFloatBtnBase")
local GroupShoppingMainUIEntry = Lplus.Extend(TopFloatBtnBase, "GroupShoppingMainUIEntry")
local GUIUtils = require("GUI.GUIUtils")
local def = GroupShoppingMainUIEntry.define
local instance
def.static("=>", GroupShoppingMainUIEntry).Instance = function()
  if instance == nil then
    instance = GroupShoppingMainUIEntry()
  end
  return instance
end
def.const("table").RelatedNotifyIds = {}
def.override("=>", "boolean").IsOpen = function(self)
  local isopen = require("Main.GroupShopping.GroupShoppingModule").Instance():IsOpen()
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
    local bNeedRed = require("Main.GroupShopping.GroupShoppingModule").Instance():IsRed()
    GUIUtils.SetActive(Img_Red, bNeedRed)
  end
end
def.method().Register = function(self)
  for k, v in ipairs(GroupShoppingMainUIEntry.RelatedNotifyIds) do
    Event.RegisterEventWithContext(ModuleId.GROUP_SHOPPING, v, GroupShoppingMainUIEntry.OnUpdate, self)
  end
end
def.method().Unregister = function(self)
  for k, v in ipairs(GroupShoppingMainUIEntry.RelatedNotifyIds) do
    Event.UnregisterEvent(ModuleId.GROUP_SHOPPING, v, GroupShoppingMainUIEntry.OnUpdate)
  end
end
def.method("table").OnUpdate = function(self, param)
  self:UpdateRed()
end
def.override("string").onClick = function(self, id)
  require("Main.GroupShopping.GroupShoppingModule").Instance():ShowGroupShoppingPanel()
end
return GroupShoppingMainUIEntry.Commit()
