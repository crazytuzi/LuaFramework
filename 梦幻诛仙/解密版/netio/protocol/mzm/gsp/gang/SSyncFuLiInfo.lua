local SSyncFuLiInfo = class("SSyncFuLiInfo")
SSyncFuLiInfo.TYPEID = 12589930
function SSyncFuLiInfo:ctor(totalCount, leftCount)
  self.id = 12589930
  self.totalCount = totalCount or nil
  self.leftCount = leftCount or nil
end
function SSyncFuLiInfo:marshal(os)
  os:marshalInt32(self.totalCount)
  os:marshalInt32(self.leftCount)
end
function SSyncFuLiInfo:unmarshal(os)
  self.totalCount = os:unmarshalInt32()
  self.leftCount = os:unmarshalInt32()
end
function SSyncFuLiInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncFuLiInfo
