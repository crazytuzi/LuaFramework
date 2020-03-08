local CPutOnOcpEquipReq = class("CPutOnOcpEquipReq")
CPutOnOcpEquipReq.TYPEID = 12607748
function CPutOnOcpEquipReq:ctor(ocp, uuid)
  self.id = 12607748
  self.ocp = ocp or nil
  self.uuid = uuid or nil
end
function CPutOnOcpEquipReq:marshal(os)
  os:marshalInt32(self.ocp)
  os:marshalInt64(self.uuid)
end
function CPutOnOcpEquipReq:unmarshal(os)
  self.ocp = os:unmarshalInt32()
  self.uuid = os:unmarshalInt64()
end
function CPutOnOcpEquipReq:sizepolicy(size)
  return size <= 65535
end
return CPutOnOcpEquipReq
