local SCostItemAddScoreSuccess = class("SCostItemAddScoreSuccess")
SCostItemAddScoreSuccess.TYPEID = 12606240
function SCostItemAddScoreSuccess:ctor(add_score_mounts_id, now_score)
  self.id = 12606240
  self.add_score_mounts_id = add_score_mounts_id or nil
  self.now_score = now_score or nil
end
function SCostItemAddScoreSuccess:marshal(os)
  os:marshalInt64(self.add_score_mounts_id)
  os:marshalInt32(self.now_score)
end
function SCostItemAddScoreSuccess:unmarshal(os)
  self.add_score_mounts_id = os:unmarshalInt64()
  self.now_score = os:unmarshalInt32()
end
function SCostItemAddScoreSuccess:sizepolicy(size)
  return size <= 65535
end
return SCostItemAddScoreSuccess
