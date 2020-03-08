local MODULE_NAME = (...)
local Lplus = require("Lplus")
local KnockOutBetInfo = import(".KnockOutBetInfo")
local FinalBetInfo = Lplus.Extend(KnockOutBetInfo, MODULE_NAME)
local def = FinalBetInfo.define
def.final("table", "=>", FinalBetInfo).new = function(self, params)
  local obj = FinalBetInfo()
  obj:ctor(params)
  return obj
end
return FinalBetInfo.Commit()
