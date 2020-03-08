local CClearQQGroupReq = class("CClearQQGroupReq")
CClearQQGroupReq.TYPEID = 12589983
function CClearQQGroupReq:ctor()
  self.id = 12589983
end
function CClearQQGroupReq:marshal(os)
end
function CClearQQGroupReq:unmarshal(os)
end
function CClearQQGroupReq:sizepolicy(size)
  return size <= 65535
end
return CClearQQGroupReq
