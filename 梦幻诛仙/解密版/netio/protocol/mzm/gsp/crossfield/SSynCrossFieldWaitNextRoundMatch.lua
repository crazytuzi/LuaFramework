local SSynCrossFieldWaitNextRoundMatch = class("SSynCrossFieldWaitNextRoundMatch")
SSynCrossFieldWaitNextRoundMatch.TYPEID = 12619538
SSynCrossFieldWaitNextRoundMatch.REASON_MATCH_ROLE_NOT_ENOUGH = 0
SSynCrossFieldWaitNextRoundMatch.REASON_NO_ROAM_SERVER = 1
SSynCrossFieldWaitNextRoundMatch.REASON_ROAM_SERVER_ROLE_TOO_MUCH = 2
SSynCrossFieldWaitNextRoundMatch.REASON_MATCH_ROLE_TOO_MUCH = 3
function SSynCrossFieldWaitNextRoundMatch:ctor(reason)
  self.id = 12619538
  self.reason = reason or nil
end
function SSynCrossFieldWaitNextRoundMatch:marshal(os)
  os:marshalUInt8(self.reason)
end
function SSynCrossFieldWaitNextRoundMatch:unmarshal(os)
  self.reason = os:unmarshalUInt8()
end
function SSynCrossFieldWaitNextRoundMatch:sizepolicy(size)
  return size <= 65535
end
return SSynCrossFieldWaitNextRoundMatch
