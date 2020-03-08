local CGetCareActivityReq = class("CGetCareActivityReq")
CGetCareActivityReq.TYPEID = 12587567
function CGetCareActivityReq:ctor()
  self.id = 12587567
end
function CGetCareActivityReq:marshal(os)
end
function CGetCareActivityReq:unmarshal(os)
end
function CGetCareActivityReq:sizepolicy(size)
  return size <= 65535
end
return CGetCareActivityReq
