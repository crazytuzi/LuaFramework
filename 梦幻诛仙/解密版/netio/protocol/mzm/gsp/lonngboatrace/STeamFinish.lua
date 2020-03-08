local STeamFinish = class("STeamFinish")
STeamFinish.TYPEID = 12619274
function STeamFinish:ctor(role2Statistic)
  self.id = 12619274
  self.role2Statistic = role2Statistic or {}
end
function STeamFinish:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.role2Statistic) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.role2Statistic) do
    os:marshalInt64(k)
    v:marshal(os)
  end
end
function STeamFinish:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.lonngboatrace.Statistic")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.role2Statistic[k] = v
  end
end
function STeamFinish:sizepolicy(size)
  return size <= 65535
end
return STeamFinish
