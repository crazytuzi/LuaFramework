local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenActivityWeeklyAndTipPanelByTime = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenActivityWeeklyAndTipPanelByTime.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local timeHour = params[1]
  Event.DispatchEvent(ModuleId.GROW, gmodule.notifyId.Grow.OPEN_ACTIVITY_WEEKLY_AND_TIP_PANEL_BY_TIME, {
    hour = tonumber(timeHour)
  })
  warn("OPEN_ACTIVITY_WEEKLY_AND_TIP_PANEL_BY_TIME", timeHour)
  return false
end
return OpenActivityWeeklyAndTipPanelByTime.Commit()
