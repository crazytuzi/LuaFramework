local CPraisePersonal = class("CPraisePersonal")
CPraisePersonal.TYPEID = 12603654
function CPraisePersonal:ctor(roleId)
  self.id = 12603654
  self.roleId = roleId or nil
end
function CPraisePersonal:marshal(os)
  os:marshalInt64(self.roleId)
end
function CPraisePersonal:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function CPraisePersonal:sizepolicy(size)
  return size <= 65535
end
return CPraisePersonal
