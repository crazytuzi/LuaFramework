local CStartFightReq = class("CStartFightReq")
CStartFightReq.TYPEID = 12595714
function CStartFightReq:ctor(opponentRoleid)
  self.id = 12595714
  self.opponentRoleid = opponentRoleid or nil
end
function CStartFightReq:marshal(os)
  os:marshalInt64(self.opponentRoleid)
end
function CStartFightReq:unmarshal(os)
  self.opponentRoleid = os:unmarshalInt64()
end
function CStartFightReq:sizepolicy(size)
  return size <= 65535
end
return CStartFightReq
