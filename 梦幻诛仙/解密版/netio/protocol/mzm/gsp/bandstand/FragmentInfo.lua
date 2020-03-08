local OctetsStream = require("netio.OctetsStream")
local FragmentInfo = class("FragmentInfo")
function FragmentInfo:ctor(answer_sequence)
  self.answer_sequence = answer_sequence or {}
end
function FragmentInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.answer_sequence))
  for _, v in ipairs(self.answer_sequence) do
    os:marshalInt32(v)
  end
end
function FragmentInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.answer_sequence, v)
  end
end
return FragmentInfo
