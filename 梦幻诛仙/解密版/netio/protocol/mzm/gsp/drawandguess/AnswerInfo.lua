local OctetsStream = require("netio.OctetsStream")
local AnswerInfo = class("AnswerInfo")
function AnswerInfo:ctor(member_roleId, answer, result)
  self.member_roleId = member_roleId or nil
  self.answer = answer or nil
  self.result = result or nil
end
function AnswerInfo:marshal(os)
  os:marshalInt64(self.member_roleId)
  os:marshalString(self.answer)
  os:marshalInt32(self.result)
end
function AnswerInfo:unmarshal(os)
  self.member_roleId = os:unmarshalInt64()
  self.answer = os:unmarshalString()
  self.result = os:unmarshalInt32()
end
return AnswerInfo
