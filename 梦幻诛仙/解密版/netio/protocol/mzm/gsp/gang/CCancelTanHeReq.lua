local CCancelTanHeReq = class("CCancelTanHeReq")
CCancelTanHeReq.TYPEID = 12589857
function CCancelTanHeReq:ctor()
  self.id = 12589857
end
function CCancelTanHeReq:marshal(os)
end
function CCancelTanHeReq:unmarshal(os)
end
function CCancelTanHeReq:sizepolicy(size)
  return size <= 65535
end
return CCancelTanHeReq
