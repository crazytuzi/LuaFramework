local CUseAircraftItem = class("CUseAircraftItem")
CUseAircraftItem.TYPEID = 12624649
function CUseAircraftItem:ctor(item_uuid)
  self.id = 12624649
  self.item_uuid = item_uuid or nil
end
function CUseAircraftItem:marshal(os)
  os:marshalInt64(self.item_uuid)
end
function CUseAircraftItem:unmarshal(os)
  self.item_uuid = os:unmarshalInt64()
end
function CUseAircraftItem:sizepolicy(size)
  return size <= 65535
end
return CUseAircraftItem
