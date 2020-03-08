local MTaskInfo = require("netio.protocol.mzm.gsp.mourn.MTaskInfo")
local SSynSingleMournInfo = class("SSynSingleMournInfo")
SSynSingleMournInfo.TYPEID = 12613379
function SSynSingleMournInfo:ctor(mournId, mournInfo)
  self.id = 12613379
  self.mournId = mournId or nil
  self.mournInfo = mournInfo or MTaskInfo.new()
end
function SSynSingleMournInfo:marshal(os)
  os:marshalInt32(self.mournId)
  self.mournInfo:marshal(os)
end
function SSynSingleMournInfo:unmarshal(os)
  self.mournId = os:unmarshalInt32()
  self.mournInfo = MTaskInfo.new()
  self.mournInfo:unmarshal(os)
end
function SSynSingleMournInfo:sizepolicy(size)
  return size <= 65535
end
return SSynSingleMournInfo
