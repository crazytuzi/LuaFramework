local CJoinLunHuiQuestionReq = class("CJoinLunHuiQuestionReq")
CJoinLunHuiQuestionReq.TYPEID = 12594693
function CJoinLunHuiQuestionReq:ctor()
  self.id = 12594693
end
function CJoinLunHuiQuestionReq:marshal(os)
end
function CJoinLunHuiQuestionReq:unmarshal(os)
end
function CJoinLunHuiQuestionReq:sizepolicy(size)
  return size <= 65535
end
return CJoinLunHuiQuestionReq
