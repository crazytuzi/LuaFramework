local CUseFireWorksItem = class("CUseFireWorksItem")
CUseFireWorksItem.TYPEID = 12584822
function CUseFireWorksItem:ctor(uuid)
  self.id = 12584822
  self.uuid = uuid or nil
end
function CUseFireWorksItem:marshal(os)
  os:marshalInt64(self.uuid)
end
function CUseFireWorksItem:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CUseFireWorksItem:sizepolicy(size)
  return size <= 65535
end
return CUseFireWorksItem
