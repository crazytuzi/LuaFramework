local CGetLevelGuideInfoReq = class("CGetLevelGuideInfoReq")
CGetLevelGuideInfoReq.TYPEID = 12597003
function CGetLevelGuideInfoReq:ctor()
  self.id = 12597003
end
function CGetLevelGuideInfoReq:marshal(os)
end
function CGetLevelGuideInfoReq:unmarshal(os)
end
function CGetLevelGuideInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetLevelGuideInfoReq
