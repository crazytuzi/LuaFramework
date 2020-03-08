local Lplus = require("Lplus")
local ActivityAlert = Lplus.Class("ActivityAlert")
local def = ActivityAlert.define
local instance
def.static("=>", ActivityAlert).Instance = function()
  if instance == nil then
    instance = ActivityAlert()
    instance:_Init()
  end
  return instance
end
def.field("table")._startActivitys = nil
def.field("number")._timerID = -1
def.method()._Init = function(self)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ListChanged, ActivityAlert._OnActivityListChanged)
end
def.static("table", "table")._OnActivityListChanged = function(p1, p2, p3)
  local self = instance
  if self._timerID < 0 then
    self._timerID = GameUtil.AddGlobalTimer(1, true, ActivityAlert._OnTimer)
  end
end
def.static()._OnTimer = function()
  self._timerID = -1
  instance:CheckActivities()
end
def.method().CheckActivities = function(self)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local activityInterface = ActivityInterface.Instance()
  local weeklyList = activityInterface:GetWeeklyActivityList()
  if self._timerID < 0 then
    self._timerID = GameUtil.AddGlobalTimer(1, true, ActivityAlert._OnTimer)
  end
end
ActivityAlert.Commit()
return ActivityAlert
