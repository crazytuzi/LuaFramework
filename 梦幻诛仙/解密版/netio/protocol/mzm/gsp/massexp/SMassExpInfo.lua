local MassExpInfo = require("netio.protocol.mzm.gsp.massexp.MassExpInfo")
local SMassExpInfo = class("SMassExpInfo")
SMassExpInfo.TYPEID = 12608257
function SMassExpInfo:ctor(mass_exp_info)
  self.id = 12608257
  self.mass_exp_info = mass_exp_info or MassExpInfo.new()
end
function SMassExpInfo:marshal(os)
  self.mass_exp_info:marshal(os)
end
function SMassExpInfo:unmarshal(os)
  self.mass_exp_info = MassExpInfo.new()
  self.mass_exp_info:unmarshal(os)
end
function SMassExpInfo:sizepolicy(size)
  return size <= 65535
end
return SMassExpInfo
