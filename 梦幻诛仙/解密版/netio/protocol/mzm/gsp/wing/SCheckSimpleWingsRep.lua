local WingSimpleData = require("netio.protocol.mzm.gsp.wing.WingSimpleData")
local SCheckSimpleWingsRep = class("SCheckSimpleWingsRep")
SCheckSimpleWingsRep.TYPEID = 12596543
function SCheckSimpleWingsRep:ctor(checkInfo)
  self.id = 12596543
  self.checkInfo = checkInfo or WingSimpleData.new()
end
function SCheckSimpleWingsRep:marshal(os)
  self.checkInfo:marshal(os)
end
function SCheckSimpleWingsRep:unmarshal(os)
  self.checkInfo = WingSimpleData.new()
  self.checkInfo:unmarshal(os)
end
function SCheckSimpleWingsRep:sizepolicy(size)
  return size <= 65535
end
return SCheckSimpleWingsRep
