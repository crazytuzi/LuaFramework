local SLoginNotifySelectionFightRes = class("SLoginNotifySelectionFightRes")
SLoginNotifySelectionFightRes.TYPEID = 12617002
SLoginNotifySelectionFightRes.FIGHT = 1
SLoginNotifySelectionFightRes.GIVE_UP = 2
SLoginNotifySelectionFightRes.LIMIT = 3
function SLoginNotifySelectionFightRes:ctor(ret, is_rank_up, reason)
  self.id = 12617002
  self.ret = ret or nil
  self.is_rank_up = is_rank_up or nil
  self.reason = reason or nil
end
function SLoginNotifySelectionFightRes:marshal(os)
  os:marshalInt32(self.ret)
  os:marshalInt32(self.is_rank_up)
  os:marshalInt32(self.reason)
end
function SLoginNotifySelectionFightRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
  self.is_rank_up = os:unmarshalInt32()
  self.reason = os:unmarshalInt32()
end
function SLoginNotifySelectionFightRes:sizepolicy(size)
  return size <= 65535
end
return SLoginNotifySelectionFightRes
