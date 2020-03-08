local CCallGangHelpReq = class("CCallGangHelpReq")
CCallGangHelpReq.TYPEID = 12594697
function CCallGangHelpReq:ctor(questionid, pageIndex)
  self.id = 12594697
  self.questionid = questionid or nil
  self.pageIndex = pageIndex or nil
end
function CCallGangHelpReq:marshal(os)
  os:marshalInt32(self.questionid)
  os:marshalInt32(self.pageIndex)
end
function CCallGangHelpReq:unmarshal(os)
  self.questionid = os:unmarshalInt32()
  self.pageIndex = os:unmarshalInt32()
end
function CCallGangHelpReq:sizepolicy(size)
  return size <= 65535
end
return CCallGangHelpReq
