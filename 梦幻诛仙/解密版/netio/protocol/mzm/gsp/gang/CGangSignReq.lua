local CGangSignReq = class("CGangSignReq")
CGangSignReq.TYPEID = 12589940
function CGangSignReq:ctor()
  self.id = 12589940
end
function CGangSignReq:marshal(os)
end
function CGangSignReq:unmarshal(os)
end
function CGangSignReq:sizepolicy(size)
  return size <= 65535
end
return CGangSignReq
