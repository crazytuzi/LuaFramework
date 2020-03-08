local CUseFlopLotteryItem = class("CUseFlopLotteryItem")
CUseFlopLotteryItem.TYPEID = 12618499
function CUseFlopLotteryItem:ctor(uuid)
  self.id = 12618499
  self.uuid = uuid or nil
end
function CUseFlopLotteryItem:marshal(os)
  os:marshalInt64(self.uuid)
end
function CUseFlopLotteryItem:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CUseFlopLotteryItem:sizepolicy(size)
  return size <= 65535
end
return CUseFlopLotteryItem
