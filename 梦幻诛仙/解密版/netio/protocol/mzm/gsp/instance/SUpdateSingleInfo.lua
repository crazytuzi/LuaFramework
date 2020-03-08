local SingleInfo = require("netio.protocol.mzm.gsp.instance.SingleInfo")
local SUpdateSingleInfo = class("SUpdateSingleInfo")
SUpdateSingleInfo.TYPEID = 12591370
function SUpdateSingleInfo:ctor(singleInfo, failTime)
  self.id = 12591370
  self.singleInfo = singleInfo or SingleInfo.new()
  self.failTime = failTime or nil
end
function SUpdateSingleInfo:marshal(os)
  self.singleInfo:marshal(os)
  os:marshalInt32(self.failTime)
end
function SUpdateSingleInfo:unmarshal(os)
  self.singleInfo = SingleInfo.new()
  self.singleInfo:unmarshal(os)
  self.failTime = os:unmarshalInt32()
end
function SUpdateSingleInfo:sizepolicy(size)
  return size <= 65535
end
return SUpdateSingleInfo
