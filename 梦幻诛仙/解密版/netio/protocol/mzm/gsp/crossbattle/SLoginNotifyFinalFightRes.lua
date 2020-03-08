local SLoginNotifyFinalFightRes = class("SLoginNotifyFinalFightRes")
SLoginNotifyFinalFightRes.TYPEID = 12617055
SLoginNotifyFinalFightRes.FIGHT = 1
SLoginNotifyFinalFightRes.GIVE_UP = 2
SLoginNotifyFinalFightRes.LIMIT = 3
function SLoginNotifyFinalFightRes:ctor(ret, is_rank_up, reason)
  self.id = 12617055
  self.ret = ret or nil
  self.is_rank_up = is_rank_up or nil
  self.reason = reason or nil
end
function SLoginNotifyFinalFightRes:marshal(os)
  os:marshalInt32(self.ret)
  os:marshalInt32(self.is_rank_up)
  os:marshalInt32(self.reason)
end
function SLoginNotifyFinalFightRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
  self.is_rank_up = os:unmarshalInt32()
  self.reason = os:unmarshalInt32()
end
function SLoginNotifyFinalFightRes:sizepolicy(size)
  return size <= 65535
end
return SLoginNotifyFinalFightRes
