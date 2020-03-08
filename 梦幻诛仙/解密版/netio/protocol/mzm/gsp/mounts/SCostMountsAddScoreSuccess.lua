local SCostMountsAddScoreSuccess = class("SCostMountsAddScoreSuccess")
SCostMountsAddScoreSuccess.TYPEID = 12606245
function SCostMountsAddScoreSuccess:ctor(cost_mounts_id, add_score_mounts_id, now_score)
  self.id = 12606245
  self.cost_mounts_id = cost_mounts_id or nil
  self.add_score_mounts_id = add_score_mounts_id or nil
  self.now_score = now_score or nil
end
function SCostMountsAddScoreSuccess:marshal(os)
  os:marshalInt64(self.cost_mounts_id)
  os:marshalInt64(self.add_score_mounts_id)
  os:marshalInt32(self.now_score)
end
function SCostMountsAddScoreSuccess:unmarshal(os)
  self.cost_mounts_id = os:unmarshalInt64()
  self.add_score_mounts_id = os:unmarshalInt64()
  self.now_score = os:unmarshalInt32()
end
function SCostMountsAddScoreSuccess:sizepolicy(size)
  return size <= 65535
end
return SCostMountsAddScoreSuccess
