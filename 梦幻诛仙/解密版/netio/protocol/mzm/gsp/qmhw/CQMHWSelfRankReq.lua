local CQMHWSelfRankReq = class("CQMHWSelfRankReq")
CQMHWSelfRankReq.TYPEID = 12601865
function CQMHWSelfRankReq:ctor()
  self.id = 12601865
end
function CQMHWSelfRankReq:marshal(os)
end
function CQMHWSelfRankReq:unmarshal(os)
end
function CQMHWSelfRankReq:sizepolicy(size)
  return size <= 65535
end
return CQMHWSelfRankReq
