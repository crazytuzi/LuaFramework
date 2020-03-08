local SPraisePersonalSuccess = class("SPraisePersonalSuccess")
SPraisePersonalSuccess.TYPEID = 12603650
function SPraisePersonalSuccess:ctor(roleId, praiseNum, praise)
  self.id = 12603650
  self.roleId = roleId or nil
  self.praiseNum = praiseNum or nil
  self.praise = praise or nil
end
function SPraisePersonalSuccess:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.praiseNum)
  os:marshalInt32(self.praise)
end
function SPraisePersonalSuccess:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.praiseNum = os:unmarshalInt32()
  self.praise = os:unmarshalInt32()
end
function SPraisePersonalSuccess:sizepolicy(size)
  return size <= 65535
end
return SPraisePersonalSuccess
