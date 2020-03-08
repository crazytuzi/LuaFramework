local CJoinTmpTaskReq = class("CJoinTmpTaskReq")
CJoinTmpTaskReq.TYPEID = 12587595
function CJoinTmpTaskReq:ctor()
  self.id = 12587595
end
function CJoinTmpTaskReq:marshal(os)
end
function CJoinTmpTaskReq:unmarshal(os)
end
function CJoinTmpTaskReq:sizepolicy(size)
  return size <= 65535
end
return CJoinTmpTaskReq
