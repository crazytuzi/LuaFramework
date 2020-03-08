local CEquipMagicMarkReq = class("CEquipMagicMarkReq")
CEquipMagicMarkReq.TYPEID = 12609547
function CEquipMagicMarkReq:ctor(magicMarkType)
  self.id = 12609547
  self.magicMarkType = magicMarkType or nil
end
function CEquipMagicMarkReq:marshal(os)
  os:marshalInt32(self.magicMarkType)
end
function CEquipMagicMarkReq:unmarshal(os)
  self.magicMarkType = os:unmarshalInt32()
end
function CEquipMagicMarkReq:sizepolicy(size)
  return size <= 65535
end
return CEquipMagicMarkReq
