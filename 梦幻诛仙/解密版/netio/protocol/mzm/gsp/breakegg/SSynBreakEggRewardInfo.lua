local SSynBreakEggRewardInfo = class("SSynBreakEggRewardInfo")
SSynBreakEggRewardInfo.TYPEID = 12623363
function SSynBreakEggRewardInfo:ctor(activity_id, index2break_egg_info)
  self.id = 12623363
  self.activity_id = activity_id or nil
  self.index2break_egg_info = index2break_egg_info or {}
end
function SSynBreakEggRewardInfo:marshal(os)
  os:marshalInt32(self.activity_id)
  local _size_ = 0
  for _, _ in pairs(self.index2break_egg_info) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.index2break_egg_info) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SSynBreakEggRewardInfo:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.breakegg.BreakEggInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.index2break_egg_info[k] = v
  end
end
function SSynBreakEggRewardInfo:sizepolicy(size)
  return size <= 65535
end
return SSynBreakEggRewardInfo
