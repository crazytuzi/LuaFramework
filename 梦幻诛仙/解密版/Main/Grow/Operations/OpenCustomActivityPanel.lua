local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenCustomActivityPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenCustomActivityPanel.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local CustomActivityPanel = require("Main.CustomActivity.ui.CustomActivityPanel")
  local activityId = params[1]
  activityId = activityId and tonumber(activityId)
  if activityId and activityId > 0 then
    local canOpenActivity = CustomActivityPanel.Instance():ShowPanelByActivityId(activityId)
    if canOpenActivity then
      return true
    else
      Toast(textRes.activity[51])
    end
    return false
  end
  if CustomActivityPanel.isOwnOpendActivity() then
    CustomActivityPanel.Instance():ShowPanel()
    return true
  else
    Toast(textRes.activity[51])
  end
  return false
end
return OpenCustomActivityPanel.Commit()
