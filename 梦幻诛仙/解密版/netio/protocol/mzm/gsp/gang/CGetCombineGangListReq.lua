local CGetCombineGangListReq = class("CGetCombineGangListReq")
CGetCombineGangListReq.TYPEID = 12589959
function CGetCombineGangListReq:ctor()
  self.id = 12589959
end
function CGetCombineGangListReq:marshal(os)
end
function CGetCombineGangListReq:unmarshal(os)
end
function CGetCombineGangListReq:sizepolicy(size)
  return size <= 65535
end
return CGetCombineGangListReq
