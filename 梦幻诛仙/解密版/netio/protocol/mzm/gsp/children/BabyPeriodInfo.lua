local OctetsStream = require("netio.OctetsStream")
local BabyPeriodInfo = class("BabyPeriodInfo")
BabyPeriodInfo.BREED_TYPE_PLAYER = 0
BabyPeriodInfo.BREED_TYPE_AUTO = 1
function BabyPeriodInfo:ctor(baby_property_info_map, health_score, remain_operator, remain_seconds, breed_type)
  self.baby_property_info_map = baby_property_info_map or {}
  self.health_score = health_score or nil
  self.remain_operator = remain_operator or nil
  self.remain_seconds = remain_seconds or nil
  self.breed_type = breed_type or nil
end
function BabyPeriodInfo:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.baby_property_info_map) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.baby_property_info_map) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt32(self.health_score)
  os:marshalInt32(self.remain_operator)
  os:marshalInt64(self.remain_seconds)
  os:marshalInt32(self.breed_type)
end
function BabyPeriodInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.baby_property_info_map[k] = v
  end
  self.health_score = os:unmarshalInt32()
  self.remain_operator = os:unmarshalInt32()
  self.remain_seconds = os:unmarshalInt64()
  self.breed_type = os:unmarshalInt32()
end
return BabyPeriodInfo
