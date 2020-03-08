local CStartPictureQuestionReq = class("CStartPictureQuestionReq")
CStartPictureQuestionReq.TYPEID = 12594742
function CStartPictureQuestionReq:ctor()
  self.id = 12594742
end
function CStartPictureQuestionReq:marshal(os)
end
function CStartPictureQuestionReq:unmarshal(os)
end
function CStartPictureQuestionReq:sizepolicy(size)
  return size <= 65535
end
return CStartPictureQuestionReq
