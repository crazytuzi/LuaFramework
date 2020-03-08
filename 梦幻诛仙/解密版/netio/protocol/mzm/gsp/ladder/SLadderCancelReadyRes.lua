local SLadderCancelReadyRes = class("SLadderCancelReadyRes")
SLadderCancelReadyRes.TYPEID = 12607241
function SLadderCancelReadyRes:ctor(roleid)
  self.id = 12607241
  self.roleid = roleid or nil
end
function SLadderCancelReadyRes:marshal(os)
  os:marshalInt64(self.roleid)
end
function SLadderCancelReadyRes:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
function SLadderCancelReadyRes:sizepolicy(size)
  return size <= 65535
end
return SLadderCancelReadyRes
