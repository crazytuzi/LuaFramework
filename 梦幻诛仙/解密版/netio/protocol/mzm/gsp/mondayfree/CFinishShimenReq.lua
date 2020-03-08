local CFinishShimenReq = class("CFinishShimenReq")
CFinishShimenReq.TYPEID = 12626185
function CFinishShimenReq:ctor()
  self.id = 12626185
end
function CFinishShimenReq:marshal(os)
end
function CFinishShimenReq:unmarshal(os)
end
function CFinishShimenReq:sizepolicy(size)
  return size <= 65535
end
return CFinishShimenReq
