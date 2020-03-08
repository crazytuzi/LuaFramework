local CUseRoleExpItem = class("CUseRoleExpItem")
CUseRoleExpItem.TYPEID = 12585999
function CUseRoleExpItem:ctor(itemKey)
  self.id = 12585999
  self.itemKey = itemKey or nil
end
function CUseRoleExpItem:marshal(os)
  os:marshalInt32(self.itemKey)
end
function CUseRoleExpItem:unmarshal(os)
  self.itemKey = os:unmarshalInt32()
end
function CUseRoleExpItem:sizepolicy(size)
  return size <= 65535
end
return CUseRoleExpItem
