local CPutOffOcpEquipReq = class("CPutOffOcpEquipReq")
CPutOffOcpEquipReq.TYPEID = 12607747
function CPutOffOcpEquipReq:ctor(ocp, key)
  self.id = 12607747
  self.ocp = ocp or nil
  self.key = key or nil
end
function CPutOffOcpEquipReq:marshal(os)
  os:marshalInt32(self.ocp)
  os:marshalInt32(self.key)
end
function CPutOffOcpEquipReq:unmarshal(os)
  self.ocp = os:unmarshalInt32()
  self.key = os:unmarshalInt32()
end
function CPutOffOcpEquipReq:sizepolicy(size)
  return size <= 65535
end
return CPutOffOcpEquipReq
