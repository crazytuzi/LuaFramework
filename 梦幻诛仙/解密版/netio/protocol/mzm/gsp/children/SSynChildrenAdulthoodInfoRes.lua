local AdulthoodInfo = require("netio.protocol.mzm.gsp.children.AdulthoodInfo")
local SSynChildrenAdulthoodInfoRes = class("SSynChildrenAdulthoodInfoRes")
SSynChildrenAdulthoodInfoRes.TYPEID = 12609406
function SSynChildrenAdulthoodInfoRes:ctor(childrenid, adulthoodInfo)
  self.id = 12609406
  self.childrenid = childrenid or nil
  self.adulthoodInfo = adulthoodInfo or AdulthoodInfo.new()
end
function SSynChildrenAdulthoodInfoRes:marshal(os)
  os:marshalInt64(self.childrenid)
  self.adulthoodInfo:marshal(os)
end
function SSynChildrenAdulthoodInfoRes:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.adulthoodInfo = AdulthoodInfo.new()
  self.adulthoodInfo:unmarshal(os)
end
function SSynChildrenAdulthoodInfoRes:sizepolicy(size)
  return size <= 65535
end
return SSynChildrenAdulthoodInfoRes
