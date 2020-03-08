local CEquipFabaoReq = class("CEquipFabaoReq")
CEquipFabaoReq.TYPEID = 12595994
function CEquipFabaoReq:ctor(key)
  self.id = 12595994
  self.key = key or nil
end
function CEquipFabaoReq:marshal(os)
  os:marshalInt32(self.key)
end
function CEquipFabaoReq:unmarshal(os)
  self.key = os:unmarshalInt32()
end
function CEquipFabaoReq:sizepolicy(size)
  return size <= 65535
end
return CEquipFabaoReq
