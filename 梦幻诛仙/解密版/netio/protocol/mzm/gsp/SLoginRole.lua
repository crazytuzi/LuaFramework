local SLoginRole = class("SLoginRole")
SLoginRole.TYPEID = 12590083
SLoginRole.ERR_LOGIN_SUCCESS = 0
SLoginRole.ERR_LOGIN_NOT_EXIST = 1
SLoginRole.ERR_LOGIN_ALREADY = 2
SLoginRole.ERR_LOGIN_ROLE_FORBIDE = 3
SLoginRole.ERR_LOGIN_USER_FORBIDE = 4
function SLoginRole:ctor(result, roleid, expire_time, reason)
  self.id = 12590083
  self.result = result or nil
  self.roleid = roleid or nil
  self.expire_time = expire_time or nil
  self.reason = reason or nil
end
function SLoginRole:marshal(os)
  os:marshalInt32(self.result)
  os:marshalInt64(self.roleid)
  os:marshalInt64(self.expire_time)
  os:marshalOctets(self.reason)
end
function SLoginRole:unmarshal(os)
  self.result = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
  self.expire_time = os:unmarshalInt64()
  self.reason = os:unmarshalOctets()
end
function SLoginRole:sizepolicy(size)
  return size <= 1024
end
return SLoginRole
