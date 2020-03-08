local CJoinBanquet = class("CJoinBanquet")
CJoinBanquet.TYPEID = 12605953
function CJoinBanquet:ctor(masterId)
  self.id = 12605953
  self.masterId = masterId or nil
end
function CJoinBanquet:marshal(os)
  os:marshalInt64(self.masterId)
end
function CJoinBanquet:unmarshal(os)
  self.masterId = os:unmarshalInt64()
end
function CJoinBanquet:sizepolicy(size)
  return size <= 65535
end
return CJoinBanquet
