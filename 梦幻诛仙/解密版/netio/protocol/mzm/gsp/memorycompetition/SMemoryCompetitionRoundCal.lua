local SMemoryCompetitionRoundCal = class("SMemoryCompetitionRoundCal")
SMemoryCompetitionRoundCal.TYPEID = 12613135
function SMemoryCompetitionRoundCal:ctor(activity_cfg_id, answer_result_map, score)
  self.id = 12613135
  self.activity_cfg_id = activity_cfg_id or nil
  self.answer_result_map = answer_result_map or {}
  self.score = score or nil
end
function SMemoryCompetitionRoundCal:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  do
    local _size_ = 0
    for _, _ in pairs(self.answer_result_map) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.answer_result_map) do
      os:marshalInt64(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt32(self.score)
end
function SMemoryCompetitionRoundCal:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.answer_result_map[k] = v
  end
  self.score = os:unmarshalInt32()
end
function SMemoryCompetitionRoundCal:sizepolicy(size)
  return size <= 65535
end
return SMemoryCompetitionRoundCal
