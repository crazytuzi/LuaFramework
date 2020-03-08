local SSignUpBrd = class("SSignUpBrd")
SSignUpBrd.TYPEID = 12616729
function SSignUpBrd:ctor(manager_id, manager_name)
  self.id = 12616729
  self.manager_id = manager_id or nil
  self.manager_name = manager_name or nil
end
function SSignUpBrd:marshal(os)
  os:marshalInt64(self.manager_id)
  os:marshalString(self.manager_name)
end
function SSignUpBrd:unmarshal(os)
  self.manager_id = os:unmarshalInt64()
  self.manager_name = os:unmarshalString()
end
function SSignUpBrd:sizepolicy(size)
  return size <= 65535
end
return SSignUpBrd
