local CUsePetBagItemReq = class("CUsePetBagItemReq")
CUsePetBagItemReq.TYPEID = 12590630
function CUsePetBagItemReq:ctor(itemKey)
  self.id = 12590630
  self.itemKey = itemKey or nil
end
function CUsePetBagItemReq:marshal(os)
  os:marshalInt32(self.itemKey)
end
function CUsePetBagItemReq:unmarshal(os)
  self.itemKey = os:unmarshalInt32()
end
function CUsePetBagItemReq:sizepolicy(size)
  return size <= 65535
end
return CUsePetBagItemReq
