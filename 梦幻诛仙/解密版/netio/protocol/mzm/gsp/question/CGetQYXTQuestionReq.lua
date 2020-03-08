local CGetQYXTQuestionReq = class("CGetQYXTQuestionReq")
CGetQYXTQuestionReq.TYPEID = 12594747
function CGetQYXTQuestionReq:ctor()
  self.id = 12594747
end
function CGetQYXTQuestionReq:marshal(os)
end
function CGetQYXTQuestionReq:unmarshal(os)
end
function CGetQYXTQuestionReq:sizepolicy(size)
  return size <= 65535
end
return CGetQYXTQuestionReq
