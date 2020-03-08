local SSingleBossAward = class("SSingleBossAward")
SSingleBossAward.TYPEID = 12591385
function SSingleBossAward:ctor(items)
  self.id = 12591385
  self.items = items or {}
end
function SSingleBossAward:marshal(os)
  os:marshalCompactUInt32(table.getn(self.items))
  for _, v in ipairs(self.items) do
    v:marshal(os)
  end
end
function SSingleBossAward:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.instance.Item2Count")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.items, v)
  end
end
function SSingleBossAward:sizepolicy(size)
  return size <= 65535
end
return SSingleBossAward
