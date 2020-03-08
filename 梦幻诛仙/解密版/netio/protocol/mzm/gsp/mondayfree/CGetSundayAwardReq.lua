local CGetSundayAwardReq = class("CGetSundayAwardReq")
CGetSundayAwardReq.TYPEID = 12626178
function CGetSundayAwardReq:ctor()
  self.id = 12626178
end
function CGetSundayAwardReq:marshal(os)
end
function CGetSundayAwardReq:unmarshal(os)
end
function CGetSundayAwardReq:sizepolicy(size)
  return size <= 65535
end
return CGetSundayAwardReq
