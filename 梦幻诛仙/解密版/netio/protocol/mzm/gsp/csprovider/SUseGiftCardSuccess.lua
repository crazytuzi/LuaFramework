local SUseGiftCardSuccess = class("SUseGiftCardSuccess")
SUseGiftCardSuccess.TYPEID = 12589314
function SUseGiftCardSuccess:ctor()
  self.id = 12589314
end
function SUseGiftCardSuccess:marshal(os)
end
function SUseGiftCardSuccess:unmarshal(os)
end
function SUseGiftCardSuccess:sizepolicy(size)
  return size <= 65535
end
return SUseGiftCardSuccess
