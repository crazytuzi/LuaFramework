local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenArenaPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenArenaPanel.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local activityId = _G.constant.JingjiActivityCfgConsts.IMAGE_PVP
  local ParticipateActivity = import(".ParticipateActivity", CUR_CLASS_NAME)
  return ParticipateActivity():Operate({activityId})
end
return OpenArenaPanel.Commit()
