local CQueryOcpEquipReq = class("CQueryOcpEquipReq")
CQueryOcpEquipReq.TYPEID = 12607751
function CQueryOcpEquipReq:ctor(ocp)
  self.id = 12607751
  self.ocp = ocp or nil
end
function CQueryOcpEquipReq:marshal(os)
  os:marshalInt32(self.ocp)
end
function CQueryOcpEquipReq:unmarshal(os)
  self.ocp = os:unmarshalInt32()
end
function CQueryOcpEquipReq:sizepolicy(size)
  return size <= 65535
end
return CQueryOcpEquipReq
