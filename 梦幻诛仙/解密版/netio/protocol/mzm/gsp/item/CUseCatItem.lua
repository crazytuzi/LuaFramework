local CUseCatItem = class("CUseCatItem")
CUseCatItem.TYPEID = 12584849
function CUseCatItem:ctor(uuid)
  self.id = 12584849
  self.uuid = uuid or nil
end
function CUseCatItem:marshal(os)
  os:marshalInt64(self.uuid)
end
function CUseCatItem:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CUseCatItem:sizepolicy(size)
  return size <= 65535
end
return CUseCatItem
