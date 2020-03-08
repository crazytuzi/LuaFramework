local DressedInfo = require("netio.protocol.mzm.gsp.children.DressedInfo")
local SWearFashionSuccess = class("SWearFashionSuccess")
SWearFashionSuccess.TYPEID = 12609358
function SWearFashionSuccess:ctor(childid, dressed_info)
  self.id = 12609358
  self.childid = childid or nil
  self.dressed_info = dressed_info or DressedInfo.new()
end
function SWearFashionSuccess:marshal(os)
  os:marshalInt64(self.childid)
  self.dressed_info:marshal(os)
end
function SWearFashionSuccess:unmarshal(os)
  self.childid = os:unmarshalInt64()
  self.dressed_info = DressedInfo.new()
  self.dressed_info:unmarshal(os)
end
function SWearFashionSuccess:sizepolicy(size)
  return size <= 65535
end
return SWearFashionSuccess
