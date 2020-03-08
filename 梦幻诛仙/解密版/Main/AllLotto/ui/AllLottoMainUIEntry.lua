local Lplus = require("Lplus")
local TopFloatBtnBase = require("Main.MainUI.ui.TopFloatBtnBase")
local AllLottoMainUIEntry = Lplus.Extend(TopFloatBtnBase, "AllLottoMainUIEntry")
local GUIUtils = require("GUI.GUIUtils")
local def = AllLottoMainUIEntry.define
local instance
def.static("=>", AllLottoMainUIEntry).Instance = function()
  if instance == nil then
    instance = AllLottoMainUIEntry()
  end
  return instance
end
def.const("table").RelatedNotifyIds = {}
def.override("=>", "boolean").IsOpen = function(self)
  local isopen = require("Main.AllLotto.AllLottoModule").Instance():IsOpen()
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
    local bNeedRed = require("Main.AllLotto.AllLottoModule").Instance():IsRed()
    GUIUtils.SetActive(Img_Red, bNeedRed)
  end
end
def.method().Register = function(self)
  for k, v in ipairs(AllLottoMainUIEntry.RelatedNotifyIds) do
    Event.RegisterEventWithContext(ModuleId.ALLLOTTO, v, AllLottoMainUIEntry.OnUpdate, self)
  end
end
def.method().Unregister = function(self)
  for k, v in ipairs(AllLottoMainUIEntry.RelatedNotifyIds) do
    Event.UnregisterEvent(ModuleId.ALLLOTTO, v, AllLottoMainUIEntry.OnUpdate)
  end
end
def.method("table").OnUpdate = function(self, param)
  self:UpdateRed()
end
def.override("string").onClick = function(self, id)
  require("Main.AllLotto.AllLottoModule").Instance():ShowActivityPanel()
end
return AllLottoMainUIEntry.Commit()
