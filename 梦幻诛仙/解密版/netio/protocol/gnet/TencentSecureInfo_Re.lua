local TencentSecureInfo_Re = class("TencentSecureInfo_Re")
TencentSecureInfo_Re.TYPEID = 151
function TencentSecureInfo_Re:ctor(roleid, localsid, secure_data)
  self.id = 151
  self.roleid = roleid or nil
  self.localsid = localsid or nil
  self.secure_data = secure_data or nil
end
function TencentSecureInfo_Re:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.localsid)
  os:marshalOctets(self.secure_data)
end
function TencentSecureInfo_Re:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.localsid = os:unmarshalInt32()
  self.secure_data = os:unmarshalOctets()
end
function TencentSecureInfo_Re:sizepolicy(size)
  return size <= 12800
end
return TencentSecureInfo_Re
