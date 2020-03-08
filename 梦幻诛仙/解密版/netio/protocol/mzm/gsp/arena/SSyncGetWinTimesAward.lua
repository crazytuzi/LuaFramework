local SSyncGetWinTimesAward = class("SSyncGetWinTimesAward")
SSyncGetWinTimesAward.TYPEID = 12596750
function SSyncGetWinTimesAward:ctor(awards)
  self.id = 12596750
  self.awards = awards or {}
end
function SSyncGetWinTimesAward:marshal(os)
  os:marshalCompactUInt32(table.getn(self.awards))
  for _, v in ipairs(self.awards) do
    os:marshalInt32(v)
  end
end
function SSyncGetWinTimesAward:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.awards, v)
  end
end
function SSyncGetWinTimesAward:sizepolicy(size)
  return size <= 65535
end
return SSyncGetWinTimesAward
