local SPetFightSetPositionFail = class("SPetFightSetPositionFail")
SPetFightSetPositionFail.TYPEID = 12590701
SPetFightSetPositionFail.PET_NOT_EXISTS = 1
SPetFightSetPositionFail.PET_NOT_BOUND = 2
SPetFightSetPositionFail.REMOVE_LAST_PET_IN_DEFENSE_TEAM = 3
function SPetFightSetPositionFail:ctor(reason, team)
  self.id = 12590701
  self.reason = reason or nil
  self.team = team or nil
end
function SPetFightSetPositionFail:marshal(os)
  os:marshalInt32(self.reason)
  os:marshalInt32(self.team)
end
function SPetFightSetPositionFail:unmarshal(os)
  self.reason = os:unmarshalInt32()
  self.team = os:unmarshalInt32()
end
function SPetFightSetPositionFail:sizepolicy(size)
  return size <= 65535
end
return SPetFightSetPositionFail
