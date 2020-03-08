local SAgreeSwornNameRes = class("SAgreeSwornNameRes")
SAgreeSwornNameRes.TYPEID = 12597777
function SAgreeSwornNameRes:ctor(swornid, roleid)
  self.id = 12597777
  self.swornid = swornid or nil
  self.roleid = roleid or nil
end
function SAgreeSwornNameRes:marshal(os)
  os:marshalInt64(self.swornid)
  os:marshalInt64(self.roleid)
end
function SAgreeSwornNameRes:unmarshal(os)
  self.swornid = os:unmarshalInt64()
  self.roleid = os:unmarshalInt64()
end
function SAgreeSwornNameRes:sizepolicy(size)
  return size <= 65535
end
return SAgreeSwornNameRes
