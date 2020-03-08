local SSyncTanHeSuccess = class("SSyncTanHeSuccess")
SSyncTanHeSuccess.TYPEID = 12589844
function SSyncTanHeSuccess:ctor(tanHeId, bangZhuId)
  self.id = 12589844
  self.tanHeId = tanHeId or nil
  self.bangZhuId = bangZhuId or nil
end
function SSyncTanHeSuccess:marshal(os)
  os:marshalInt64(self.tanHeId)
  os:marshalInt64(self.bangZhuId)
end
function SSyncTanHeSuccess:unmarshal(os)
  self.tanHeId = os:unmarshalInt64()
  self.bangZhuId = os:unmarshalInt64()
end
function SSyncTanHeSuccess:sizepolicy(size)
  return size <= 65535
end
return SSyncTanHeSuccess
