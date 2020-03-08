local OctetsStream = require("netio.OctetsStream")
local PagePetInfo = class("PagePetInfo")
function PagePetInfo:ctor(pageIndex, totalPageNum, subid, marketPetList)
  self.pageIndex = pageIndex or nil
  self.totalPageNum = totalPageNum or nil
  self.subid = subid or nil
  self.marketPetList = marketPetList or {}
end
function PagePetInfo:marshal(os)
  os:marshalInt32(self.pageIndex)
  os:marshalInt32(self.totalPageNum)
  os:marshalInt32(self.subid)
  os:marshalCompactUInt32(table.getn(self.marketPetList))
  for _, v in ipairs(self.marketPetList) do
    v:marshal(os)
  end
end
function PagePetInfo:unmarshal(os)
  self.pageIndex = os:unmarshalInt32()
  self.totalPageNum = os:unmarshalInt32()
  self.subid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.market.MarketPet")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.marketPetList, v)
  end
end
return PagePetInfo
