local CQueryBoughtMoralValueReq = class("CQueryBoughtMoralValueReq")
CQueryBoughtMoralValueReq.TYPEID = 12619805
function CQueryBoughtMoralValueReq:ctor()
  self.id = 12619805
end
function CQueryBoughtMoralValueReq:marshal(os)
end
function CQueryBoughtMoralValueReq:unmarshal(os)
end
function CQueryBoughtMoralValueReq:sizepolicy(size)
  return size <= 65535
end
return CQueryBoughtMoralValueReq
