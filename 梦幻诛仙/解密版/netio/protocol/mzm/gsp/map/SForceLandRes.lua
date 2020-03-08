local SForceLandRes = class("SForceLandRes")
SForceLandRes.TYPEID = 12590934
function SForceLandRes:ctor(roleid)
  self.id = 12590934
  self.roleid = roleid or nil
end
function SForceLandRes:marshal(os)
  os:marshalInt64(self.roleid)
end
function SForceLandRes:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
function SForceLandRes:sizepolicy(size)
  return size <= 65535
end
return SForceLandRes
