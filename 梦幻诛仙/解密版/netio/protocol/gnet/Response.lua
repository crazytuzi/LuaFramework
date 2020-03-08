local Response = class("Response")
Response.TYPEID = 103
function Response:ctor(account, hmac, logintype, mid, extra, reserved1, reserved2, reserved3, reserved4)
  self.id = 103
  self.account = account or nil
  self.hmac = hmac or nil
  self.logintype = logintype or nil
  self.mid = mid or nil
  self.extra = extra or nil
  self.reserved1 = reserved1 or nil
  self.reserved2 = reserved2 or nil
  self.reserved3 = reserved3 or nil
  self.reserved4 = reserved4 or nil
end
function Response:marshal(os)
  os:marshalOctets(self.account)
  os:marshalOctets(self.hmac)
  os:marshalInt32(self.logintype)
  os:marshalOctets(self.mid)
  os:marshalOctets(self.extra)
  os:marshalUInt8(self.reserved1)
  os:marshalUInt8(self.reserved2)
  os:marshalUInt8(self.reserved3)
  os:marshalOctets(self.reserved4)
end
function Response:unmarshal(os)
  self.account = os:unmarshalOctets()
  self.hmac = os:unmarshalOctets()
  self.logintype = os:unmarshalInt32()
  self.mid = os:unmarshalOctets()
  self.extra = os:unmarshalOctets()
  self.reserved1 = os:unmarshalUInt8()
  self.reserved2 = os:unmarshalUInt8()
  self.reserved3 = os:unmarshalUInt8()
  self.reserved4 = os:unmarshalOctets()
end
function Response:sizepolicy(size)
  return size <= 65535
end
return Response
