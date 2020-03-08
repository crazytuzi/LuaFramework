local CQYXTGangHelpAnswerReq = class("CQYXTGangHelpAnswerReq")
CQYXTGangHelpAnswerReq.TYPEID = 12594750
function CQYXTGangHelpAnswerReq:ctor(questionCfgId, seekHelpRoleId, helpAnswerString)
  self.id = 12594750
  self.questionCfgId = questionCfgId or nil
  self.seekHelpRoleId = seekHelpRoleId or nil
  self.helpAnswerString = helpAnswerString or nil
end
function CQYXTGangHelpAnswerReq:marshal(os)
  os:marshalInt32(self.questionCfgId)
  os:marshalInt64(self.seekHelpRoleId)
  os:marshalString(self.helpAnswerString)
end
function CQYXTGangHelpAnswerReq:unmarshal(os)
  self.questionCfgId = os:unmarshalInt32()
  self.seekHelpRoleId = os:unmarshalInt64()
  self.helpAnswerString = os:unmarshalString()
end
function CQYXTGangHelpAnswerReq:sizepolicy(size)
  return size <= 65535
end
return CQYXTGangHelpAnswerReq
