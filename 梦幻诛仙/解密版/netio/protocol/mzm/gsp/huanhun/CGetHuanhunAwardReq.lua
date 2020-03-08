local CGetHuanhunAwardReq = class("CGetHuanhunAwardReq")
CGetHuanhunAwardReq.TYPEID = 12584449
function CGetHuanhunAwardReq:ctor()
  self.id = 12584449
end
function CGetHuanhunAwardReq:marshal(os)
end
function CGetHuanhunAwardReq:unmarshal(os)
end
function CGetHuanhunAwardReq:sizepolicy(size)
  return size <= 65535
end
return CGetHuanhunAwardReq
