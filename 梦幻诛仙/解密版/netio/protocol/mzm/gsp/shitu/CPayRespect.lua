local CPayRespect = class("CPayRespect")
CPayRespect.TYPEID = 12601627
function CPayRespect:ctor(pay_respect_str)
  self.id = 12601627
  self.pay_respect_str = pay_respect_str or nil
end
function CPayRespect:marshal(os)
  os:marshalOctets(self.pay_respect_str)
end
function CPayRespect:unmarshal(os)
  self.pay_respect_str = os:unmarshalOctets()
end
function CPayRespect:sizepolicy(size)
  return size <= 65535
end
return CPayRespect
