local SLeavePrepareMapFail = class("SLeavePrepareMapFail")
SLeavePrepareMapFail.TYPEID = 12629262
SLeavePrepareMapFail.NOT_IN_PREPARE_MAP = 1
SLeavePrepareMapFail.NOT_TEAM_LEADER = 2
function SLeavePrepareMapFail:ctor(reason)
  self.id = 12629262
  self.reason = reason or nil
end
function SLeavePrepareMapFail:marshal(os)
  os:marshalInt32(self.reason)
end
function SLeavePrepareMapFail:unmarshal(os)
  self.reason = os:unmarshalInt32()
end
function SLeavePrepareMapFail:sizepolicy(size)
  return size <= 65535
end
return SLeavePrepareMapFail
