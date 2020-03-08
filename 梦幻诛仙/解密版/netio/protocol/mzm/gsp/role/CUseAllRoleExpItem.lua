local CUseAllRoleExpItem = class("CUseAllRoleExpItem")
CUseAllRoleExpItem.TYPEID = 12586010
function CUseAllRoleExpItem:ctor(itemKey)
  self.id = 12586010
  self.itemKey = itemKey or nil
end
function CUseAllRoleExpItem:marshal(os)
  os:marshalInt32(self.itemKey)
end
function CUseAllRoleExpItem:unmarshal(os)
  self.itemKey = os:unmarshalInt32()
end
function CUseAllRoleExpItem:sizepolicy(size)
  return size <= 65535
end
return CUseAllRoleExpItem
