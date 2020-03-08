local CGetXiangShiQuestionReq = class("CGetXiangShiQuestionReq")
CGetXiangShiQuestionReq.TYPEID = 12594700
function CGetXiangShiQuestionReq:ctor()
  self.id = 12594700
end
function CGetXiangShiQuestionReq:marshal(os)
end
function CGetXiangShiQuestionReq:unmarshal(os)
end
function CGetXiangShiQuestionReq:sizepolicy(size)
  return size <= 65535
end
return CGetXiangShiQuestionReq
