local SLadderUnMatchRes = class("SLadderUnMatchRes")
SLadderUnMatchRes.TYPEID = 12607238
function SLadderUnMatchRes:ctor(roleid)
  self.id = 12607238
  self.roleid = roleid or nil
end
function SLadderUnMatchRes:marshal(os)
  os:marshalInt64(self.roleid)
end
function SLadderUnMatchRes:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
function SLadderUnMatchRes:sizepolicy(size)
  return size <= 65535
end
return SLadderUnMatchRes
