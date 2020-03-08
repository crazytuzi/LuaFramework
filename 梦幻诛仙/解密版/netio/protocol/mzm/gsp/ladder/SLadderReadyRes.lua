local SLadderReadyRes = class("SLadderReadyRes")
SLadderReadyRes.TYPEID = 12607242
function SLadderReadyRes:ctor(roleid)
  self.id = 12607242
  self.roleid = roleid or nil
end
function SLadderReadyRes:marshal(os)
  os:marshalInt64(self.roleid)
end
function SLadderReadyRes:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
function SLadderReadyRes:sizepolicy(size)
  return size <= 65535
end
return SLadderReadyRes
