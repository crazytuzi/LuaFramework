local CUseMarriageSugerItem = class("CUseMarriageSugerItem")
CUseMarriageSugerItem.TYPEID = 12584821
function CUseMarriageSugerItem:ctor(uuid)
  self.id = 12584821
  self.uuid = uuid or nil
end
function CUseMarriageSugerItem:marshal(os)
  os:marshalInt64(self.uuid)
end
function CUseMarriageSugerItem:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CUseMarriageSugerItem:sizepolicy(size)
  return size <= 65535
end
return CUseMarriageSugerItem
