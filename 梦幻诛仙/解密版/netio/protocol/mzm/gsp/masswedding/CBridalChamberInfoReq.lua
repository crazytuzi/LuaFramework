local CBridalChamberInfoReq = class("CBridalChamberInfoReq")
CBridalChamberInfoReq.TYPEID = 12604939
function CBridalChamberInfoReq:ctor(roleid)
  self.id = 12604939
  self.roleid = roleid or nil
end
function CBridalChamberInfoReq:marshal(os)
  os:marshalInt64(self.roleid)
end
function CBridalChamberInfoReq:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
function CBridalChamberInfoReq:sizepolicy(size)
  return size <= 65535
end
return CBridalChamberInfoReq
