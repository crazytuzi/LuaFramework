local CUseGangFileItem = class("CUseGangFileItem")
CUseGangFileItem.TYPEID = 12584711
function CUseGangFileItem:ctor(uuid)
  self.id = 12584711
  self.uuid = uuid or nil
end
function CUseGangFileItem:marshal(os)
  os:marshalInt64(self.uuid)
end
function CUseGangFileItem:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CUseGangFileItem:sizepolicy(size)
  return size <= 65535
end
return CUseGangFileItem
