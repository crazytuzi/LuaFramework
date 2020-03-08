local CAcceptMoralValueTaskReq = class("CAcceptMoralValueTaskReq")
CAcceptMoralValueTaskReq.TYPEID = 12619782
function CAcceptMoralValueTaskReq:ctor()
  self.id = 12619782
end
function CAcceptMoralValueTaskReq:marshal(os)
end
function CAcceptMoralValueTaskReq:unmarshal(os)
end
function CAcceptMoralValueTaskReq:sizepolicy(size)
  return size <= 65535
end
return CAcceptMoralValueTaskReq
