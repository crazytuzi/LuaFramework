local CUseMoneyBagItem = class("CUseMoneyBagItem")
CUseMoneyBagItem.TYPEID = 12584827
function CUseMoneyBagItem:ctor(uuid, isUseAll)
  self.id = 12584827
  self.uuid = uuid or nil
  self.isUseAll = isUseAll or nil
end
function CUseMoneyBagItem:marshal(os)
  os:marshalInt64(self.uuid)
  os:marshalInt32(self.isUseAll)
end
function CUseMoneyBagItem:unmarshal(os)
  self.uuid = os:unmarshalInt64()
  self.isUseAll = os:unmarshalInt32()
end
function CUseMoneyBagItem:sizepolicy(size)
  return size <= 65535
end
return CUseMoneyBagItem
