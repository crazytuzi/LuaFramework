local CLastMournReq = class("CLastMournReq")
CLastMournReq.TYPEID = 12613378
function CLastMournReq:ctor()
  self.id = 12613378
end
function CLastMournReq:marshal(os)
end
function CLastMournReq:unmarshal(os)
end
function CLastMournReq:sizepolicy(size)
  return size <= 65535
end
return CLastMournReq
