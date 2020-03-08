local SMemberReturnBrd = class("SMemberReturnBrd")
SMemberReturnBrd.TYPEID = 12588330
function SMemberReturnBrd:ctor(roleId)
  self.id = 12588330
  self.roleId = roleId or nil
end
function SMemberReturnBrd:marshal(os)
  os:marshalInt64(self.roleId)
end
function SMemberReturnBrd:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function SMemberReturnBrd:sizepolicy(size)
  return size <= 65535
end
return SMemberReturnBrd
