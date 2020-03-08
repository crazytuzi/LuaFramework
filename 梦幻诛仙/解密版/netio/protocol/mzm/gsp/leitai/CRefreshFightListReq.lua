local CRefreshFightListReq = class("CRefreshFightListReq")
CRefreshFightListReq.TYPEID = 12591873
function CRefreshFightListReq:ctor()
  self.id = 12591873
end
function CRefreshFightListReq:marshal(os)
end
function CRefreshFightListReq:unmarshal(os)
end
function CRefreshFightListReq:sizepolicy(size)
  return size <= 65535
end
return CRefreshFightListReq
