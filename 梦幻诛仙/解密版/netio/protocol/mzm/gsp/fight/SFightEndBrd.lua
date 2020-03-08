local SFightEndBrd = class("SFightEndBrd")
SFightEndBrd.TYPEID = 12594188
SFightEndBrd.RESULT_ACTIVE_WIN = 1
SFightEndBrd.RESULT_ACTIVE_LOSE = 2
SFightEndBrd.END_REASON_MAX_ROUND = 100
SFightEndBrd.END_REASON_NORMAL = 101
SFightEndBrd.END_REASON_UNKNOWN_ERROR = 102
SFightEndBrd.END_REASON_TIME_LIMIT = 103
SFightEndBrd.END_REASON_FORCE_END = 104
function SFightEndBrd:ctor(result, reason, fight_uuid)
  self.id = 12594188
  self.result = result or nil
  self.reason = reason or nil
  self.fight_uuid = fight_uuid or nil
end
function SFightEndBrd:marshal(os)
  os:marshalInt32(self.result)
  os:marshalInt32(self.reason)
  os:marshalInt64(self.fight_uuid)
end
function SFightEndBrd:unmarshal(os)
  self.result = os:unmarshalInt32()
  self.reason = os:unmarshalInt32()
  self.fight_uuid = os:unmarshalInt64()
end
function SFightEndBrd:sizepolicy(size)
  return size <= 65535
end
return SFightEndBrd
