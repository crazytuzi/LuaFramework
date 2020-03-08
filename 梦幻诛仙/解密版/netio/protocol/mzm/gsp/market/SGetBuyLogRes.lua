local SGetBuyLogRes = class("SGetBuyLogRes")
SGetBuyLogRes.TYPEID = 12601437
function SGetBuyLogRes:ctor(buyLogs)
  self.id = 12601437
  self.buyLogs = buyLogs or {}
end
function SGetBuyLogRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.buyLogs))
  for _, v in ipairs(self.buyLogs) do
    v:marshal(os)
  end
end
function SGetBuyLogRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.market.MarketLog")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.buyLogs, v)
  end
end
function SGetBuyLogRes:sizepolicy(size)
  return size <= 65535
end
return SGetBuyLogRes
