local SItemCarryMaxErr = class("SItemCarryMaxErr")
SItemCarryMaxErr.TYPEID = 12583439
function SItemCarryMaxErr:ctor(itemId)
  self.id = 12583439
  self.itemId = itemId or nil
end
function SItemCarryMaxErr:marshal(os)
  os:marshalInt32(self.itemId)
end
function SItemCarryMaxErr:unmarshal(os)
  self.itemId = os:unmarshalInt32()
end
function SItemCarryMaxErr:sizepolicy(size)
  return size <= 65535
end
return SItemCarryMaxErr
