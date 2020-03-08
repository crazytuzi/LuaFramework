local CSetAutoAddFlag = class("CSetAutoAddFlag")
CSetAutoAddFlag.TYPEID = 12590597
function CSetAutoAddFlag:ctor(petId, autoAddFlag)
  self.id = 12590597
  self.petId = petId or nil
  self.autoAddFlag = autoAddFlag or nil
end
function CSetAutoAddFlag:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.autoAddFlag)
end
function CSetAutoAddFlag:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.autoAddFlag = os:unmarshalInt32()
end
function CSetAutoAddFlag:sizepolicy(size)
  return size <= 65535
end
return CSetAutoAddFlag
