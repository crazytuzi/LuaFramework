local CUnEquip = class("CUnEquip")
CUnEquip.TYPEID = 12584745
function CUnEquip:ctor(key)
  self.id = 12584745
  self.key = key or nil
end
function CUnEquip:marshal(os)
  os:marshalInt32(self.key)
end
function CUnEquip:unmarshal(os)
  self.key = os:unmarshalInt32()
end
function CUnEquip:sizepolicy(size)
  return size <= 65535
end
return CUnEquip
