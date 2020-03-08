local SGrapPositionFail = class("SGrapPositionFail")
SGrapPositionFail.TYPEID = 12621587
SGrapPositionFail.FAIL_FIGHT = 1
SGrapPositionFail.FAIL_MOVE = 2
SGrapPositionFail.FAIL_BATTLE_END = 3
function SGrapPositionFail:ctor(positionId, reason)
  self.id = 12621587
  self.positionId = positionId or nil
  self.reason = reason or nil
end
function SGrapPositionFail:marshal(os)
  os:marshalInt32(self.positionId)
  os:marshalInt32(self.reason)
end
function SGrapPositionFail:unmarshal(os)
  self.positionId = os:unmarshalInt32()
  self.reason = os:unmarshalInt32()
end
function SGrapPositionFail:sizepolicy(size)
  return size <= 65535
end
return SGrapPositionFail
