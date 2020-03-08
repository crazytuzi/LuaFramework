local STakeLadderStageAwardRes = class("STakeLadderStageAwardRes")
STakeLadderStageAwardRes.TYPEID = 12607267
function STakeLadderStageAwardRes:ctor(stage)
  self.id = 12607267
  self.stage = stage or nil
end
function STakeLadderStageAwardRes:marshal(os)
  os:marshalInt32(self.stage)
end
function STakeLadderStageAwardRes:unmarshal(os)
  self.stage = os:unmarshalInt32()
end
function STakeLadderStageAwardRes:sizepolicy(size)
  return size <= 65535
end
return STakeLadderStageAwardRes
