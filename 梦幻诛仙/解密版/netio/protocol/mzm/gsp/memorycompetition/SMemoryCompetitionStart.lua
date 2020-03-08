local SMemoryCompetitionStart = class("SMemoryCompetitionStart")
SMemoryCompetitionStart.TYPEID = 12613136
function SMemoryCompetitionStart:ctor(activity_cfg_id, memory_competition_cfg_id, mapping_date, left_seconds)
  self.id = 12613136
  self.activity_cfg_id = activity_cfg_id or nil
  self.memory_competition_cfg_id = memory_competition_cfg_id or nil
  self.mapping_date = mapping_date or {}
  self.left_seconds = left_seconds or nil
end
function SMemoryCompetitionStart:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.memory_competition_cfg_id)
  do
    local _size_ = 0
    for _, _ in pairs(self.mapping_date) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.mapping_date) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt32(self.left_seconds)
end
function SMemoryCompetitionStart:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.memory_competition_cfg_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.mapping_date[k] = v
  end
  self.left_seconds = os:unmarshalInt32()
end
function SMemoryCompetitionStart:sizepolicy(size)
  return size <= 65535
end
return SMemoryCompetitionStart
