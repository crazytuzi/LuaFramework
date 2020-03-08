local CGetInJailLeftTimeReq = class("CGetInJailLeftTimeReq")
CGetInJailLeftTimeReq.TYPEID = 12620045
function CGetInJailLeftTimeReq:ctor()
  self.id = 12620045
end
function CGetInJailLeftTimeReq:marshal(os)
end
function CGetInJailLeftTimeReq:unmarshal(os)
end
function CGetInJailLeftTimeReq:sizepolicy(size)
  return size <= 65535
end
return CGetInJailLeftTimeReq
