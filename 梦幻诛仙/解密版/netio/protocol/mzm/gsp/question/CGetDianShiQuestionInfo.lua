local CGetDianShiQuestionInfo = class("CGetDianShiQuestionInfo")
CGetDianShiQuestionInfo.TYPEID = 12594722
function CGetDianShiQuestionInfo:ctor()
  self.id = 12594722
end
function CGetDianShiQuestionInfo:marshal(os)
end
function CGetDianShiQuestionInfo:unmarshal(os)
end
function CGetDianShiQuestionInfo:sizepolicy(size)
  return size <= 65535
end
return CGetDianShiQuestionInfo
