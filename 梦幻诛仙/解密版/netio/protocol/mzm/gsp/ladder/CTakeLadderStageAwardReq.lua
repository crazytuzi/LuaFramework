local CTakeLadderStageAwardReq = class("CTakeLadderStageAwardReq")
CTakeLadderStageAwardReq.TYPEID = 12607265
function CTakeLadderStageAwardReq:ctor(stage)
  self.id = 12607265
  self.stage = stage or nil
end
function CTakeLadderStageAwardReq:marshal(os)
  os:marshalInt32(self.stage)
end
function CTakeLadderStageAwardReq:unmarshal(os)
  self.stage = os:unmarshalInt32()
end
function CTakeLadderStageAwardReq:sizepolicy(size)
  return size <= 65535
end
return CTakeLadderStageAwardReq
