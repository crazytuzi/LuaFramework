local CGetCustomConfirmInfoReq = class("CGetCustomConfirmInfoReq")
CGetCustomConfirmInfoReq.TYPEID = 12617991
function CGetCustomConfirmInfoReq:ctor()
  self.id = 12617991
end
function CGetCustomConfirmInfoReq:marshal(os)
end
function CGetCustomConfirmInfoReq:unmarshal(os)
end
function CGetCustomConfirmInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetCustomConfirmInfoReq
