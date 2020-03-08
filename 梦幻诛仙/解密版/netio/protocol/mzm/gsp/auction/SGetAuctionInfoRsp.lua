local SGetAuctionInfoRsp = class("SGetAuctionInfoRsp")
SGetAuctionInfoRsp.TYPEID = 12627208
function SGetAuctionInfoRsp:ctor(activityId, turnIndex, itemInfoList)
  self.id = 12627208
  self.activityId = activityId or nil
  self.turnIndex = turnIndex or nil
  self.itemInfoList = itemInfoList or {}
end
function SGetAuctionInfoRsp:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.turnIndex)
  os:marshalCompactUInt32(table.getn(self.itemInfoList))
  for _, v in ipairs(self.itemInfoList) do
    v:marshal(os)
  end
end
function SGetAuctionInfoRsp:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.turnIndex = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.auction.ItemInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.itemInfoList, v)
  end
end
function SGetAuctionInfoRsp:sizepolicy(size)
  return size <= 65535
end
return SGetAuctionInfoRsp
