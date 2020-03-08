local SEnterPrepareMapFail = class("SEnterPrepareMapFail")
SEnterPrepareMapFail.TYPEID = 12629252
SEnterPrepareMapFail.ACTIVITY_NOT_OPEN = 1
SEnterPrepareMapFail.ACTIVITY_IN_LAST_ROUND = 2
SEnterPrepareMapFail.NOT_TEAM_LEADER = 3
function SEnterPrepareMapFail:ctor(reason)
  self.id = 12629252
  self.reason = reason or nil
end
function SEnterPrepareMapFail:marshal(os)
  os:marshalInt32(self.reason)
end
function SEnterPrepareMapFail:unmarshal(os)
  self.reason = os:unmarshalInt32()
end
function SEnterPrepareMapFail:sizepolicy(size)
  return size <= 65535
end
return SEnterPrepareMapFail
