local CJoinShimenReq = class("CJoinShimenReq")
CJoinShimenReq.TYPEID = 12587542
function CJoinShimenReq:ctor()
  self.id = 12587542
end
function CJoinShimenReq:marshal(os)
end
function CJoinShimenReq:unmarshal(os)
end
function CJoinShimenReq:sizepolicy(size)
  return size <= 65535
end
return CJoinShimenReq
