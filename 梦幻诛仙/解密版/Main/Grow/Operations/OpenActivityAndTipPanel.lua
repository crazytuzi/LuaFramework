local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenActivityAndTipPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenActivityAndTipPanel.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local activityId = params[1]
  Event.DispatchEvent(ModuleId.GROW, gmodule.notifyId.Grow.OPEN_ACTIVITY_AND_TIP_PANEL, {
    activityId = tonumber(activityId)
  })
  warn("OPEN_ACTIVITY_AND_TIP_PANEL", activityId)
  return false
end
return OpenActivityAndTipPanel.Commit()
