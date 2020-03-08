local CRenXingYiXiaReq = class("CRenXingYiXiaReq")
CRenXingYiXiaReq.TYPEID = 12587528
function CRenXingYiXiaReq:ctor()
  self.id = 12587528
end
function CRenXingYiXiaReq:marshal(os)
end
function CRenXingYiXiaReq:unmarshal(os)
end
function CRenXingYiXiaReq:sizepolicy(size)
  return size <= 65535
end
return CRenXingYiXiaReq
