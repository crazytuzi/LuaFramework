local CUseGeniusStoneItem = class("CUseGeniusStoneItem")
CUseGeniusStoneItem.TYPEID = 12584870
function CUseGeniusStoneItem:ctor(uuid, use_all)
  self.id = 12584870
  self.uuid = uuid or nil
  self.use_all = use_all or nil
end
function CUseGeniusStoneItem:marshal(os)
  os:marshalInt64(self.uuid)
  os:marshalUInt8(self.use_all)
end
function CUseGeniusStoneItem:unmarshal(os)
  self.uuid = os:unmarshalInt64()
  self.use_all = os:unmarshalUInt8()
end
function CUseGeniusStoneItem:sizepolicy(size)
  return size <= 65535
end
return CUseGeniusStoneItem
