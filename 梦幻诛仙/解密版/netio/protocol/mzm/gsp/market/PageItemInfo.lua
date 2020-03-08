local OctetsStream = require("netio.OctetsStream")
local PageItemInfo = class("PageItemInfo")
function PageItemInfo:ctor(pageIndex, totalPageNum, subid, marketItemList)
  self.pageIndex = pageIndex or nil
  self.totalPageNum = totalPageNum or nil
  self.subid = subid or nil
  self.marketItemList = marketItemList or {}
end
function PageItemInfo:marshal(os)
  os:marshalInt32(self.pageIndex)
  os:marshalInt32(self.totalPageNum)
  os:marshalInt32(self.subid)
  os:marshalCompactUInt32(table.getn(self.marketItemList))
  for _, v in ipairs(self.marketItemList) do
    v:marshal(os)
  end
end
function PageItemInfo:unmarshal(os)
  self.pageIndex = os:unmarshalInt32()
  self.totalPageNum = os:unmarshalInt32()
  self.subid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.market.MarketItem")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.marketItemList, v)
  end
end
return PageItemInfo
