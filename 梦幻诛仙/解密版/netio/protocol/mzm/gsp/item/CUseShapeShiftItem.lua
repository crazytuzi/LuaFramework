local CUseShapeShiftItem = class("CUseShapeShiftItem")
CUseShapeShiftItem.TYPEID = 12584873
function CUseShapeShiftItem:ctor(uuid)
  self.id = 12584873
  self.uuid = uuid or nil
end
function CUseShapeShiftItem:marshal(os)
  os:marshalInt64(self.uuid)
end
function CUseShapeShiftItem:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CUseShapeShiftItem:sizepolicy(size)
  return size <= 65535
end
return CUseShapeShiftItem
