local SBroadcastBreakEggRewardInfo = class("SBroadcastBreakEggRewardInfo")
SBroadcastBreakEggRewardInfo.TYPEID = 12623372
function SBroadcastBreakEggRewardInfo:ctor(activity_id, inviter_id, inviter_name, break_egg_info)
  self.id = 12623372
  self.activity_id = activity_id or nil
  self.inviter_id = inviter_id or nil
  self.inviter_name = inviter_name or nil
  self.break_egg_info = break_egg_info or {}
end
function SBroadcastBreakEggRewardInfo:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt64(self.inviter_id)
  os:marshalString(self.inviter_name)
  os:marshalCompactUInt32(table.getn(self.break_egg_info))
  for _, v in ipairs(self.break_egg_info) do
    v:marshal(os)
  end
end
function SBroadcastBreakEggRewardInfo:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.inviter_id = os:unmarshalInt64()
  self.inviter_name = os:unmarshalString()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.breakegg.BreakEggInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.break_egg_info, v)
  end
end
function SBroadcastBreakEggRewardInfo:sizepolicy(size)
  return size <= 65535
end
return SBroadcastBreakEggRewardInfo
