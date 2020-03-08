local OctetsStream = require("netio.OctetsStream")
local QuestionIdList = class("QuestionIdList")
function QuestionIdList:ctor(quesition_id_list)
  self.quesition_id_list = quesition_id_list or {}
end
function QuestionIdList:marshal(os)
  os:marshalCompactUInt32(table.getn(self.quesition_id_list))
  for _, v in ipairs(self.quesition_id_list) do
    os:marshalInt32(v)
  end
end
function QuestionIdList:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.quesition_id_list, v)
  end
end
return QuestionIdList
