local CAddSatiationReq = class("CAddSatiationReq")
CAddSatiationReq.TYPEID = 12605491
function CAddSatiationReq:ctor()
  self.id = 12605491
end
function CAddSatiationReq:marshal(os)
end
function CAddSatiationReq:unmarshal(os)
end
function CAddSatiationReq:sizepolicy(size)
  return size <= 65535
end
return CAddSatiationReq
