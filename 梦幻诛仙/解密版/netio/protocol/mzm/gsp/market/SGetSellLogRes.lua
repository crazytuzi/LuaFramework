local SGetSellLogRes = class("SGetSellLogRes")
SGetSellLogRes.TYPEID = 12601439
function SGetSellLogRes:ctor(sellLogs)
  self.id = 12601439
  self.sellLogs = sellLogs or {}
end
function SGetSellLogRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.sellLogs))
  for _, v in ipairs(self.sellLogs) do
    v:marshal(os)
  end
end
function SGetSellLogRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.market.MarketLog")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.sellLogs, v)
  end
end
function SGetSellLogRes:sizepolicy(size)
  return size <= 65535
end
return SGetSellLogRes
