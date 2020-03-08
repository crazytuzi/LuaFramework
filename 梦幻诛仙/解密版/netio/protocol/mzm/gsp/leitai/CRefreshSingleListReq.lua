local CRefreshSingleListReq = class("CRefreshSingleListReq")
CRefreshSingleListReq.TYPEID = 12591878
function CRefreshSingleListReq:ctor()
  self.id = 12591878
end
function CRefreshSingleListReq:marshal(os)
end
function CRefreshSingleListReq:unmarshal(os)
end
function CRefreshSingleListReq:sizepolicy(size)
  return size <= 65535
end
return CRefreshSingleListReq
