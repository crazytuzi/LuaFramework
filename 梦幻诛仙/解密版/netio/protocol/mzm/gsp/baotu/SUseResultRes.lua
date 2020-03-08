local SUseResultRes = class("SUseResultRes")
SUseResultRes.TYPEID = 12583682
function SUseResultRes:ctor(awardIdList)
  self.id = 12583682
  self.awardIdList = awardIdList or {}
end
function SUseResultRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.awardIdList))
  for _, v in ipairs(self.awardIdList) do
    v:marshal(os)
  end
end
function SUseResultRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.baotu.RewardItem")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.awardIdList, v)
  end
end
function SUseResultRes:sizepolicy(size)
  return size <= 65535
end
return SUseResultRes
