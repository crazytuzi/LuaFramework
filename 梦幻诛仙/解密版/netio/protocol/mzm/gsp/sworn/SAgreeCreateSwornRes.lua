local SAgreeCreateSwornRes = class("SAgreeCreateSwornRes")
SAgreeCreateSwornRes.TYPEID = 12597776
function SAgreeCreateSwornRes:ctor(swornid, roleid)
  self.id = 12597776
  self.swornid = swornid or nil
  self.roleid = roleid or nil
end
function SAgreeCreateSwornRes:marshal(os)
  os:marshalInt64(self.swornid)
  os:marshalInt64(self.roleid)
end
function SAgreeCreateSwornRes:unmarshal(os)
  self.swornid = os:unmarshalInt64()
  self.roleid = os:unmarshalInt64()
end
function SAgreeCreateSwornRes:sizepolicy(size)
  return size <= 65535
end
return SAgreeCreateSwornRes
