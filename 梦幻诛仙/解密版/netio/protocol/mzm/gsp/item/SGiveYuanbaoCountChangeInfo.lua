local SGiveYuanbaoCountChangeInfo = class("SGiveYuanbaoCountChangeInfo")
SGiveYuanbaoCountChangeInfo.TYPEID = 12584707
function SGiveYuanbaoCountChangeInfo:ctor(roleid, count)
  self.id = 12584707
  self.roleid = roleid or nil
  self.count = count or nil
end
function SGiveYuanbaoCountChangeInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt64(self.count)
end
function SGiveYuanbaoCountChangeInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.count = os:unmarshalInt64()
end
function SGiveYuanbaoCountChangeInfo:sizepolicy(size)
  return size <= 65535
end
return SGiveYuanbaoCountChangeInfo
