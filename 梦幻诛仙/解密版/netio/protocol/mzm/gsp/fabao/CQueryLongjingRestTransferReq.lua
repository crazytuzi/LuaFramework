local CQueryLongjingRestTransferReq = class("CQueryLongjingRestTransferReq")
CQueryLongjingRestTransferReq.TYPEID = 12596038
function CQueryLongjingRestTransferReq:ctor()
  self.id = 12596038
end
function CQueryLongjingRestTransferReq:marshal(os)
end
function CQueryLongjingRestTransferReq:unmarshal(os)
end
function CQueryLongjingRestTransferReq:sizepolicy(size)
  return size <= 65535
end
return CQueryLongjingRestTransferReq
