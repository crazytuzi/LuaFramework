local CGangHelpAnswerReq = class("CGangHelpAnswerReq")
CGangHelpAnswerReq.TYPEID = 12594698
function CGangHelpAnswerReq:ctor(questionid, pageIndex, roleId, answerString)
  self.id = 12594698
  self.questionid = questionid or nil
  self.pageIndex = pageIndex or nil
  self.roleId = roleId or nil
  self.answerString = answerString or nil
end
function CGangHelpAnswerReq:marshal(os)
  os:marshalInt32(self.questionid)
  os:marshalInt32(self.pageIndex)
  os:marshalInt64(self.roleId)
  os:marshalString(self.answerString)
end
function CGangHelpAnswerReq:unmarshal(os)
  self.questionid = os:unmarshalInt32()
  self.pageIndex = os:unmarshalInt32()
  self.roleId = os:unmarshalInt64()
  self.answerString = os:unmarshalString()
end
function CGangHelpAnswerReq:sizepolicy(size)
  return size <= 65535
end
return CGangHelpAnswerReq
