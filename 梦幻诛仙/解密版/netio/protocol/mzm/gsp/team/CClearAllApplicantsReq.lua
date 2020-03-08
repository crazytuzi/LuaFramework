local CClearAllApplicantsReq = class("CClearAllApplicantsReq")
CClearAllApplicantsReq.TYPEID = 12588297
function CClearAllApplicantsReq:ctor()
  self.id = 12588297
end
function CClearAllApplicantsReq:marshal(os)
end
function CClearAllApplicantsReq:unmarshal(os)
end
function CClearAllApplicantsReq:sizepolicy(size)
  return size <= 65535
end
return CClearAllApplicantsReq
