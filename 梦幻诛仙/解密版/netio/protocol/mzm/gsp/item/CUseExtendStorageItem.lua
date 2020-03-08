local CUseExtendStorageItem = class("CUseExtendStorageItem")
CUseExtendStorageItem.TYPEID = 12584712
function CUseExtendStorageItem:ctor(uuid)
  self.id = 12584712
  self.uuid = uuid or nil
end
function CUseExtendStorageItem:marshal(os)
  os:marshalInt64(self.uuid)
end
function CUseExtendStorageItem:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CUseExtendStorageItem:sizepolicy(size)
  return size <= 65535
end
return CUseExtendStorageItem
