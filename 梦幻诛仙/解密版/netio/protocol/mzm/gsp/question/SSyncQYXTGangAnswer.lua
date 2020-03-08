local SSyncQYXTGangAnswer = class("SSyncQYXTGangAnswer")
SSyncQYXTGangAnswer.TYPEID = 12594752
function SSyncQYXTGangAnswer:ctor(questionId, seekHelpRoleId, helpAnswerString, helpAnswerRoleId)
  self.id = 12594752
  self.questionId = questionId or nil
  self.seekHelpRoleId = seekHelpRoleId or nil
  self.helpAnswerString = helpAnswerString or nil
  self.helpAnswerRoleId = helpAnswerRoleId or nil
end
function SSyncQYXTGangAnswer:marshal(os)
  os:marshalInt32(self.questionId)
  os:marshalInt64(self.seekHelpRoleId)
  os:marshalString(self.helpAnswerString)
  os:marshalInt64(self.helpAnswerRoleId)
end
function SSyncQYXTGangAnswer:unmarshal(os)
  self.questionId = os:unmarshalInt32()
  self.seekHelpRoleId = os:unmarshalInt64()
  self.helpAnswerString = os:unmarshalString()
  self.helpAnswerRoleId = os:unmarshalInt64()
end
function SSyncQYXTGangAnswer:sizepolicy(size)
  return size <= 65535
end
return SSyncQYXTGangAnswer
