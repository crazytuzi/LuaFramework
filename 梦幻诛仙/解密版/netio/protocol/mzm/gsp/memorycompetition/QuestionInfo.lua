local OctetsStream = require("netio.OctetsStream")
local QuestionInfo = class("QuestionInfo")
function QuestionInfo:ctor(question_id, option_list)
  self.question_id = question_id or nil
  self.option_list = option_list or {}
end
function QuestionInfo:marshal(os)
  os:marshalInt32(self.question_id)
  os:marshalCompactUInt32(table.getn(self.option_list))
  for _, v in ipairs(self.option_list) do
    os:marshalInt32(v)
  end
end
function QuestionInfo:unmarshal(os)
  self.question_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.option_list, v)
  end
end
return QuestionInfo
