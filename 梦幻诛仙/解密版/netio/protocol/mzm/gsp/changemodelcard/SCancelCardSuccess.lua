local SCancelCardSuccess = class("SCancelCardSuccess")
SCancelCardSuccess.TYPEID = 12624407
function SCancelCardSuccess:ctor()
  self.id = 12624407
end
function SCancelCardSuccess:marshal(os)
end
function SCancelCardSuccess:unmarshal(os)
end
function SCancelCardSuccess:sizepolicy(size)
  return size <= 65535
end
return SCancelCardSuccess
