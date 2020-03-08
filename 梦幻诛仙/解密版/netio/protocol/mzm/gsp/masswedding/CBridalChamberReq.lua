local CBridalChamberReq = class("CBridalChamberReq")
CBridalChamberReq.TYPEID = 12604948
function CBridalChamberReq:ctor(roleid)
  self.id = 12604948
  self.roleid = roleid or nil
end
function CBridalChamberReq:marshal(os)
  os:marshalInt64(self.roleid)
end
function CBridalChamberReq:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
function CBridalChamberReq:sizepolicy(size)
  return size <= 65535
end
return CBridalChamberReq
