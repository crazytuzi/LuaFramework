local SGetBidRankRsp = class("SGetBidRankRsp")
SGetBidRankRsp.TYPEID = 12627209
function SGetBidRankRsp:ctor(activityId, itemInfoList)
  self.id = 12627209
  self.activityId = activityId or nil
  self.itemInfoList = itemInfoList or {}
end
function SGetBidRankRsp:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalCompactUInt32(table.getn(self.itemInfoList))
  for _, v in ipairs(self.itemInfoList) do
    v:marshal(os)
  end
end
function SGetBidRankRsp:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.auction.ItemInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.itemInfoList, v)
  end
end
function SGetBidRankRsp:sizepolicy(size)
  return size <= 65535
end
return SGetBidRankRsp
