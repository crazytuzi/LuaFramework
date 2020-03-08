local CCloseBridalChamberInfoReq = class("CCloseBridalChamberInfoReq")
CCloseBridalChamberInfoReq.TYPEID = 12604959
function CCloseBridalChamberInfoReq:ctor(roleid)
  self.id = 12604959
  self.roleid = roleid or nil
end
function CCloseBridalChamberInfoReq:marshal(os)
  os:marshalInt64(self.roleid)
end
function CCloseBridalChamberInfoReq:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
function CCloseBridalChamberInfoReq:sizepolicy(size)
  return size <= 65535
end
return CCloseBridalChamberInfoReq
