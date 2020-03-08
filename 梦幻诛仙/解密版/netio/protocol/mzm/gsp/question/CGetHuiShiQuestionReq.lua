local CGetHuiShiQuestionReq = class("CGetHuiShiQuestionReq")
CGetHuiShiQuestionReq.TYPEID = 12594711
function CGetHuiShiQuestionReq:ctor()
  self.id = 12594711
end
function CGetHuiShiQuestionReq:marshal(os)
end
function CGetHuiShiQuestionReq:unmarshal(os)
end
function CGetHuiShiQuestionReq:sizepolicy(size)
  return size <= 65535
end
return CGetHuiShiQuestionReq
