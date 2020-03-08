local CEquip = class("CEquip")
CEquip.TYPEID = 12584736
function CEquip:ctor(key)
  self.id = 12584736
  self.key = key or nil
end
function CEquip:marshal(os)
  os:marshalInt32(self.key)
end
function CEquip:unmarshal(os)
  self.key = os:unmarshalInt32()
end
function CEquip:sizepolicy(size)
  return size <= 65535
end
return CEquip
