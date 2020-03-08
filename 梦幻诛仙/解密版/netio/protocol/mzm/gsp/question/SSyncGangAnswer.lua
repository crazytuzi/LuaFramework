local SSyncGangAnswer = class("SSyncGangAnswer")
SSyncGangAnswer.TYPEID = 12594696
function SSyncGangAnswer:ctor(questionid, pageIndex, roleId, answerString, answerRoleId)
  self.id = 12594696
  self.questionid = questionid or nil
  self.pageIndex = pageIndex or nil
  self.roleId = roleId or nil
  self.answerString = answerString or nil
  self.answerRoleId = answerRoleId or nil
end
function SSyncGangAnswer:marshal(os)
  os:marshalInt32(self.questionid)
  os:marshalInt32(self.pageIndex)
  os:marshalInt64(self.roleId)
  os:marshalString(self.answerString)
  os:marshalInt64(self.answerRoleId)
end
function SSyncGangAnswer:unmarshal(os)
  self.questionid = os:unmarshalInt32()
  self.pageIndex = os:unmarshalInt32()
  self.roleId = os:unmarshalInt64()
  self.answerString = os:unmarshalString()
  self.answerRoleId = os:unmarshalInt64()
end
function SSyncGangAnswer:sizepolicy(size)
  return size <= 65535
end
return SSyncGangAnswer
