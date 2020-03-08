local CFrozenPointReq = class("CFrozenPointReq")
CFrozenPointReq.TYPEID = 12591105
function CFrozenPointReq:ctor()
  self.id = 12591105
end
function CFrozenPointReq:marshal(os)
end
function CFrozenPointReq:unmarshal(os)
end
function CFrozenPointReq:sizepolicy(size)
  return size <= 32
end
return CFrozenPointReq
