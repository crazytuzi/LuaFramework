local MODULE_NAME = (...)
local Lplus = require("Lplus")
local TopFloatBtnBase = require("Main.MainUI.ui.TopFloatBtnBase")
local MedalEntry = Lplus.Extend(TopFloatBtnBase, MODULE_NAME)
local MedalMgr = require("Main.activity.Medal.MedalMgr")
local def = MedalEntry.define
local instance
def.static("=>", MedalEntry).Instance = function()
  if instance == nil then
    instance = MedalEntry()
  end
  return instance
end
def.override("=>", "boolean").IsOpen = function(self)
  return MedalMgr.Instance():isOpen()
end
def.override().OnShow = function(self)
  self:UpdateNotifyBadge()
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Medal_Red_Point_Change, MedalEntry.OnNotifyUpdate)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Medal_Red_Point_Change, MedalEntry.OnNotifyUpdate)
end
def.static("table", "table").OnNotifyUpdate = function(p1, p2)
  if instance and instance.m_node then
    instance:UpdateNotifyBadge()
  end
end
def.override("string").onClick = function(self, id)
  if id == "Btn_ActivityHonor" then
    require("Main.activity.Medal.ui.MedalPanel").Instance():ShowPanel()
  end
end
def.method().UpdateNotifyBadge = function(self)
  local Btn_ActivityHonor = self.m_node
  local Img_Red = Btn_ActivityHonor:FindDirect("Img_Red")
  local hasNotify = MedalMgr.Instance():HasNotify()
  if Img_Red then
    if hasNotify then
      Img_Red:SetActive(true)
    else
      Img_Red:SetActive(false)
    end
  end
end
return MedalEntry.Commit()
