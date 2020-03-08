local TencentSecureInfo = class("TencentSecureInfo")
TencentSecureInfo.TYPEID = 150
function TencentSecureInfo:ctor(roleid, secure_data)
  self.id = 150
  self.roleid = roleid or nil
  self.secure_data = secure_data or nil
end
function TencentSecureInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalOctets(self.secure_data)
end
function TencentSecureInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.secure_data = os:unmarshalOctets()
end
function TencentSecureInfo:sizepolicy(size)
  return size <= 12800
end
return TencentSecureInfo
