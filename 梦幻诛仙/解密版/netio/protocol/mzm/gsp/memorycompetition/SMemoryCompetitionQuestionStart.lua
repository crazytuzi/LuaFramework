local SMemoryCompetitionQuestionStart = class("SMemoryCompetitionQuestionStart")
SMemoryCompetitionQuestionStart.TYPEID = 12613126
function SMemoryCompetitionQuestionStart:ctor(activity_cfg_id, memory_competition_cfg_id, score, now_round_num, total_round_num, left_seconds, left_seek_help_times, roles_question_map, roles_right_num_map)
  self.id = 12613126
  self.activity_cfg_id = activity_cfg_id or nil
  self.memory_competition_cfg_id = memory_competition_cfg_id or nil
  self.score = score or nil
  self.now_round_num = now_round_num or nil
  self.total_round_num = total_round_num or nil
  self.left_seconds = left_seconds or nil
  self.left_seek_help_times = left_seek_help_times or nil
  self.roles_question_map = roles_question_map or {}
  self.roles_right_num_map = roles_right_num_map or {}
end
function SMemoryCompetitionQuestionStart:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.memory_competition_cfg_id)
  os:marshalInt32(self.score)
  os:marshalInt32(self.now_round_num)
  os:marshalInt32(self.total_round_num)
  os:marshalInt32(self.left_seconds)
  os:marshalInt32(self.left_seek_help_times)
  do
    local _size_ = 0
    for _, _ in pairs(self.roles_question_map) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.roles_question_map) do
      os:marshalInt64(k)
      v:marshal(os)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.roles_right_num_map) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.roles_right_num_map) do
    os:marshalInt64(k)
    os:marshalInt32(v)
  end
end
function SMemoryCompetitionQuestionStart:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.memory_competition_cfg_id = os:unmarshalInt32()
  self.score = os:unmarshalInt32()
  self.now_round_num = os:unmarshalInt32()
  self.total_round_num = os:unmarshalInt32()
  self.left_seconds = os:unmarshalInt32()
  self.left_seek_help_times = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.memorycompetition.QuestionInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.roles_question_map[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.roles_right_num_map[k] = v
  end
end
function SMemoryCompetitionQuestionStart:sizepolicy(size)
  return size <= 65535
end
return SMemoryCompetitionQuestionStart
