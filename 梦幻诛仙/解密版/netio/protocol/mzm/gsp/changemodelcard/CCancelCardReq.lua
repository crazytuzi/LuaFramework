local CCancelCardReq = class("CCancelCardReq")
CCancelCardReq.TYPEID = 12624412
function CCancelCardReq:ctor()
  self.id = 12624412
end
function CCancelCardReq:marshal(os)
end
function CCancelCardReq:unmarshal(os)
end
function CCancelCardReq:sizepolicy(size)
  return size <= 65535
end
return CCancelCardReq
