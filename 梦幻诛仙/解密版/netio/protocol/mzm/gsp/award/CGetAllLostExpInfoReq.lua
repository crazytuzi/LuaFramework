local CGetAllLostExpInfoReq = class("CGetAllLostExpInfoReq")
CGetAllLostExpInfoReq.TYPEID = 12583452
function CGetAllLostExpInfoReq:ctor()
  self.id = 12583452
end
function CGetAllLostExpInfoReq:marshal(os)
end
function CGetAllLostExpInfoReq:unmarshal(os)
end
function CGetAllLostExpInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetAllLostExpInfoReq
