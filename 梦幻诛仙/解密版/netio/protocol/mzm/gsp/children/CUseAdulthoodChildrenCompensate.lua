local CUseAdulthoodChildrenCompensate = class("CUseAdulthoodChildrenCompensate")
CUseAdulthoodChildrenCompensate.TYPEID = 12609440
function CUseAdulthoodChildrenCompensate:ctor(item_uuid)
  self.id = 12609440
  self.item_uuid = item_uuid or nil
end
function CUseAdulthoodChildrenCompensate:marshal(os)
  os:marshalInt64(self.item_uuid)
end
function CUseAdulthoodChildrenCompensate:unmarshal(os)
  self.item_uuid = os:unmarshalInt64()
end
function CUseAdulthoodChildrenCompensate:sizepolicy(size)
  return size <= 65535
end
return CUseAdulthoodChildrenCompensate
