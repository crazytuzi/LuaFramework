local MassExpInfo = require("netio.protocol.mzm.gsp.massexp.MassExpInfo")
local SGetMassExpTaskSuccess = class("SGetMassExpTaskSuccess")
SGetMassExpTaskSuccess.TYPEID = 12608265
function SGetMassExpTaskSuccess:ctor(mass_exp_info)
  self.id = 12608265
  self.mass_exp_info = mass_exp_info or MassExpInfo.new()
end
function SGetMassExpTaskSuccess:marshal(os)
  self.mass_exp_info:marshal(os)
end
function SGetMassExpTaskSuccess:unmarshal(os)
  self.mass_exp_info = MassExpInfo.new()
  self.mass_exp_info:unmarshal(os)
end
function SGetMassExpTaskSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetMassExpTaskSuccess
