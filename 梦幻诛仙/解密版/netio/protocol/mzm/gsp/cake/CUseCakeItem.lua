local CUseCakeItem = class("CUseCakeItem")
CUseCakeItem.TYPEID = 12627717
function CUseCakeItem:ctor(uuid, num)
  self.id = 12627717
  self.uuid = uuid or nil
  self.num = num or nil
end
function CUseCakeItem:marshal(os)
  os:marshalInt64(self.uuid)
  os:marshalInt32(self.num)
end
function CUseCakeItem:unmarshal(os)
  self.uuid = os:unmarshalInt64()
  self.num = os:unmarshalInt32()
end
function CUseCakeItem:sizepolicy(size)
  return size <= 65535
end
return CUseCakeItem
