local CCostMountsAddScore = class("CCostMountsAddScore")
CCostMountsAddScore.TYPEID = 12606241
function CCostMountsAddScore:ctor(cost_mounts_id, add_score_mounts_id)
  self.id = 12606241
  self.cost_mounts_id = cost_mounts_id or nil
  self.add_score_mounts_id = add_score_mounts_id or nil
end
function CCostMountsAddScore:marshal(os)
  os:marshalInt64(self.cost_mounts_id)
  os:marshalInt64(self.add_score_mounts_id)
end
function CCostMountsAddScore:unmarshal(os)
  self.cost_mounts_id = os:unmarshalInt64()
  self.add_score_mounts_id = os:unmarshalInt64()
end
function CCostMountsAddScore:sizepolicy(size)
  return size <= 65535
end
return CCostMountsAddScore
