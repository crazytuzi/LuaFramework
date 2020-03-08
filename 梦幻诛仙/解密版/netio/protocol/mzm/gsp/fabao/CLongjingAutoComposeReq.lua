local CLongjingAutoComposeReq = class("CLongjingAutoComposeReq")
CLongjingAutoComposeReq.TYPEID = 12596024
function CLongjingAutoComposeReq:ctor()
  self.id = 12596024
end
function CLongjingAutoComposeReq:marshal(os)
end
function CLongjingAutoComposeReq:unmarshal(os)
end
function CLongjingAutoComposeReq:sizepolicy(size)
  return size <= 65535
end
return CLongjingAutoComposeReq
