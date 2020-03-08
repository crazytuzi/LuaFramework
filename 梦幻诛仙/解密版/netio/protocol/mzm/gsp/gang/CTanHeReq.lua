local CTanHeReq = class("CTanHeReq")
CTanHeReq.TYPEID = 12589883
function CTanHeReq:ctor()
  self.id = 12589883
end
function CTanHeReq:marshal(os)
end
function CTanHeReq:unmarshal(os)
end
function CTanHeReq:sizepolicy(size)
  return size <= 65535
end
return CTanHeReq
