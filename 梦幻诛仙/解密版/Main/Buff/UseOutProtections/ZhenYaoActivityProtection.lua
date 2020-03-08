local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ActivityProtection = import(".ActivityProtection")
local ZhenYaoActivityProtection = Lplus.Extend(ActivityProtection, CUR_CLASS_NAME)
local def = ZhenYaoActivityProtection.define
def.override().StopAction = function(self)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  Debug.LogWarning("Stop ZhenYao, because of BaoShiDu not enough")
  self:StopDoingTaskPathFind(constant.ZhenYaoActivityCfgConsts.ZhenYao_GRAPH_ID)
end
return ZhenYaoActivityProtection.Commit()
