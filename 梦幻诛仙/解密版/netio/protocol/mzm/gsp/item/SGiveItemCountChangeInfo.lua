local SGiveItemCountChangeInfo = class("SGiveItemCountChangeInfo")
SGiveItemCountChangeInfo.TYPEID = 12584726
function SGiveItemCountChangeInfo:ctor(roleid, count)
  self.id = 12584726
  self.roleid = roleid or nil
  self.count = count or nil
end
function SGiveItemCountChangeInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.count)
end
function SGiveItemCountChangeInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.count = os:unmarshalInt32()
end
function SGiveItemCountChangeInfo:sizepolicy(size)
  return size <= 65535
end
return SGiveItemCountChangeInfo
