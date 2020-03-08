local CRecoveryYuanShen = class("CRecoveryYuanShen")
CRecoveryYuanShen.TYPEID = 12588051
function CRecoveryYuanShen:ctor(partnerId)
  self.id = 12588051
  self.partnerId = partnerId or nil
end
function CRecoveryYuanShen:marshal(os)
  os:marshalInt32(self.partnerId)
end
function CRecoveryYuanShen:unmarshal(os)
  self.partnerId = os:unmarshalInt32()
end
function CRecoveryYuanShen:sizepolicy(size)
  return size <= 65535
end
return CRecoveryYuanShen
