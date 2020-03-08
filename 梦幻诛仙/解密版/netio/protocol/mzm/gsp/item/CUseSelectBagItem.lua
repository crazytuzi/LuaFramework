local CUseSelectBagItem = class("CUseSelectBagItem")
CUseSelectBagItem.TYPEID = 12584825
function CUseSelectBagItem:ctor(uuid, selectindex)
  self.id = 12584825
  self.uuid = uuid or nil
  self.selectindex = selectindex or nil
end
function CUseSelectBagItem:marshal(os)
  os:marshalInt64(self.uuid)
  os:marshalInt32(self.selectindex)
end
function CUseSelectBagItem:unmarshal(os)
  self.uuid = os:unmarshalInt64()
  self.selectindex = os:unmarshalInt32()
end
function CUseSelectBagItem:sizepolicy(size)
  return size <= 65535
end
return CUseSelectBagItem
