local SMemoryCompetitionEndNotify = class("SMemoryCompetitionEndNotify")
SMemoryCompetitionEndNotify.TYPEID = 12613129
function SMemoryCompetitionEndNotify:ctor(activity_cfg_id, roles_answer_map)
  self.id = 12613129
  self.activity_cfg_id = activity_cfg_id or nil
  self.roles_answer_map = roles_answer_map or {}
end
function SMemoryCompetitionEndNotify:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  local _size_ = 0
  for _, _ in pairs(self.roles_answer_map) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.roles_answer_map) do
    os:marshalInt64(k)
    v:marshal(os)
  end
end
function SMemoryCompetitionEndNotify:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.memorycompetition.QuestionIdList")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.roles_answer_map[k] = v
  end
end
function SMemoryCompetitionEndNotify:sizepolicy(size)
  return size <= 65535
end
return SMemoryCompetitionEndNotify
