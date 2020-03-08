local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local GoToLuanShiYaoMoMap = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = GoToLuanShiYaoMoMap.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local activityId = _G.constant.DeamonFight.LUANSHI_ACTIVITYID
  local ParticipateActivity = import(".ParticipateActivity", CUR_CLASS_NAME)
  return ParticipateActivity():Operate({activityId})
end
return GoToLuanShiYaoMoMap.Commit()
