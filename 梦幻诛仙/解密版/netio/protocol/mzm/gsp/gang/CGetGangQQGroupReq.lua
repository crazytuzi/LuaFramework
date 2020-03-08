local CGetGangQQGroupReq = class("CGetGangQQGroupReq")
CGetGangQQGroupReq.TYPEID = 12589950
function CGetGangQQGroupReq:ctor()
  self.id = 12589950
end
function CGetGangQQGroupReq:marshal(os)
end
function CGetGangQQGroupReq:unmarshal(os)
end
function CGetGangQQGroupReq:sizepolicy(size)
  return size <= 65535
end
return CGetGangQQGroupReq
