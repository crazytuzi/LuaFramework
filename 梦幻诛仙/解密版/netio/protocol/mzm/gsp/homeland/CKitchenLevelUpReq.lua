local CKitchenLevelUpReq = class("CKitchenLevelUpReq")
CKitchenLevelUpReq.TYPEID = 12605486
function CKitchenLevelUpReq:ctor()
  self.id = 12605486
end
function CKitchenLevelUpReq:marshal(os)
end
function CKitchenLevelUpReq:unmarshal(os)
end
function CKitchenLevelUpReq:sizepolicy(size)
  return size <= 65535
end
return CKitchenLevelUpReq
