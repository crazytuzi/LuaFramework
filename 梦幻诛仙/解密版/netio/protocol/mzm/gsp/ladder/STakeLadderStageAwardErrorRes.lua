local STakeLadderStageAwardErrorRes = class("STakeLadderStageAwardErrorRes")
STakeLadderStageAwardErrorRes.TYPEID = 12607266
STakeLadderStageAwardErrorRes.ALREADY_TAKEN = 0
STakeLadderStageAwardErrorRes.DO_NOT_JOIN_LADDER_BEFORE = 1
STakeLadderStageAwardErrorRes.DO_NOT_HAS_AWARD = 2
STakeLadderStageAwardErrorRes.STAGE_NOT_ENOUGH = 3
STakeLadderStageAwardErrorRes.SEND_AWARD_ERROR = 4
function STakeLadderStageAwardErrorRes:ctor(ret)
  self.id = 12607266
  self.ret = ret or nil
end
function STakeLadderStageAwardErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function STakeLadderStageAwardErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function STakeLadderStageAwardErrorRes:sizepolicy(size)
  return size <= 65535
end
return STakeLadderStageAwardErrorRes
