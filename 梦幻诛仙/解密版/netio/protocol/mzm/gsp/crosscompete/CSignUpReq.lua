local CSignUpReq = class("CSignUpReq")
CSignUpReq.TYPEID = 12616717
function CSignUpReq:ctor()
  self.id = 12616717
end
function CSignUpReq:marshal(os)
end
function CSignUpReq:unmarshal(os)
end
function CSignUpReq:sizepolicy(size)
  return size <= 65535
end
return CSignUpReq
