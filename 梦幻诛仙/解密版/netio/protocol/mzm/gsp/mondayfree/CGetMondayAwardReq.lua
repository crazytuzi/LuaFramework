local CGetMondayAwardReq = class("CGetMondayAwardReq")
CGetMondayAwardReq.TYPEID = 12626186
function CGetMondayAwardReq:ctor()
  self.id = 12626186
end
function CGetMondayAwardReq:marshal(os)
end
function CGetMondayAwardReq:unmarshal(os)
end
function CGetMondayAwardReq:sizepolicy(size)
  return size <= 65535
end
return CGetMondayAwardReq
