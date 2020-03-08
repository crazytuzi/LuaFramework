local CEquipDisassembleReq = class("CEquipDisassembleReq")
CEquipDisassembleReq.TYPEID = 12584861
function CEquipDisassembleReq:ctor(uuid)
  self.id = 12584861
  self.uuid = uuid or nil
end
function CEquipDisassembleReq:marshal(os)
  os:marshalInt64(self.uuid)
end
function CEquipDisassembleReq:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CEquipDisassembleReq:sizepolicy(size)
  return size <= 65535
end
return CEquipDisassembleReq
