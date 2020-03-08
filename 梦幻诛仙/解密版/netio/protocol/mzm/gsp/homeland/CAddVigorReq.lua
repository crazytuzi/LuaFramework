local CAddVigorReq = class("CAddVigorReq")
CAddVigorReq.TYPEID = 12605458
function CAddVigorReq:ctor()
  self.id = 12605458
end
function CAddVigorReq:marshal(os)
end
function CAddVigorReq:unmarshal(os)
end
function CAddVigorReq:sizepolicy(size)
  return size <= 65535
end
return CAddVigorReq
