local SCanGetGiftAward = class("SCanGetGiftAward")
SCanGetGiftAward.TYPEID = 12583443
function SCanGetGiftAward:ctor(giftAwardCfgIds)
  self.id = 12583443
  self.giftAwardCfgIds = giftAwardCfgIds or {}
end
function SCanGetGiftAward:marshal(os)
  os:marshalCompactUInt32(table.getn(self.giftAwardCfgIds))
  for _, v in ipairs(self.giftAwardCfgIds) do
    os:marshalInt32(v)
  end
end
function SCanGetGiftAward:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.giftAwardCfgIds, v)
  end
end
function SCanGetGiftAward:sizepolicy(size)
  return size <= 65535
end
return SCanGetGiftAward
