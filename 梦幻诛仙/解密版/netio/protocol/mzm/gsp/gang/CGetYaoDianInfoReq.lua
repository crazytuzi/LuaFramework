local CGetYaoDianInfoReq = class("CGetYaoDianInfoReq")
CGetYaoDianInfoReq.TYPEID = 12589914
function CGetYaoDianInfoReq:ctor()
  self.id = 12589914
end
function CGetYaoDianInfoReq:marshal(os)
end
function CGetYaoDianInfoReq:unmarshal(os)
end
function CGetYaoDianInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetYaoDianInfoReq
