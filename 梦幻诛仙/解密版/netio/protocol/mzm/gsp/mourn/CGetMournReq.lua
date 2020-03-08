local CGetMournReq = class("CGetMournReq")
CGetMournReq.TYPEID = 12613381
function CGetMournReq:ctor()
  self.id = 12613381
end
function CGetMournReq:marshal(os)
end
function CGetMournReq:unmarshal(os)
end
function CGetMournReq:sizepolicy(size)
  return size <= 65535
end
return CGetMournReq
