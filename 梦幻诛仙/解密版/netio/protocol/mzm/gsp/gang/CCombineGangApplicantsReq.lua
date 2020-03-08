local CCombineGangApplicantsReq = class("CCombineGangApplicantsReq")
CCombineGangApplicantsReq.TYPEID = 12589976
function CCombineGangApplicantsReq:ctor()
  self.id = 12589976
end
function CCombineGangApplicantsReq:marshal(os)
end
function CCombineGangApplicantsReq:unmarshal(os)
end
function CCombineGangApplicantsReq:sizepolicy(size)
  return size <= 65535
end
return CCombineGangApplicantsReq
