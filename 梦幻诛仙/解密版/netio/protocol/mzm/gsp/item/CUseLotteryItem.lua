local CUseLotteryItem = class("CUseLotteryItem")
CUseLotteryItem.TYPEID = 12584777
function CUseLotteryItem:ctor(uuid, use_all)
  self.id = 12584777
  self.uuid = uuid or nil
  self.use_all = use_all or nil
end
function CUseLotteryItem:marshal(os)
  os:marshalInt64(self.uuid)
  os:marshalInt32(self.use_all)
end
function CUseLotteryItem:unmarshal(os)
  self.uuid = os:unmarshalInt64()
  self.use_all = os:unmarshalInt32()
end
function CUseLotteryItem:sizepolicy(size)
  return size <= 65535
end
return CUseLotteryItem
