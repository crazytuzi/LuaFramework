local SApprenticePayRespect = class("SApprenticePayRespect")
SApprenticePayRespect.TYPEID = 12601626
function SApprenticePayRespect:ctor(pay_respect_str, apprentice_role_id, session_id)
  self.id = 12601626
  self.pay_respect_str = pay_respect_str or nil
  self.apprentice_role_id = apprentice_role_id or nil
  self.session_id = session_id or nil
end
function SApprenticePayRespect:marshal(os)
  os:marshalOctets(self.pay_respect_str)
  os:marshalInt64(self.apprentice_role_id)
  os:marshalInt64(self.session_id)
end
function SApprenticePayRespect:unmarshal(os)
  self.pay_respect_str = os:unmarshalOctets()
  self.apprentice_role_id = os:unmarshalInt64()
  self.session_id = os:unmarshalInt64()
end
function SApprenticePayRespect:sizepolicy(size)
  return size <= 65535
end
return SApprenticePayRespect
