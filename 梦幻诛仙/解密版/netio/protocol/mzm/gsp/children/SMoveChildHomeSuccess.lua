local SMoveChildHomeSuccess = class("SMoveChildHomeSuccess")
SMoveChildHomeSuccess.TYPEID = 12609290
function SMoveChildHomeSuccess:ctor(child_id)
  self.id = 12609290
  self.child_id = child_id or nil
end
function SMoveChildHomeSuccess:marshal(os)
  os:marshalInt64(self.child_id)
end
function SMoveChildHomeSuccess:unmarshal(os)
  self.child_id = os:unmarshalInt64()
end
function SMoveChildHomeSuccess:sizepolicy(size)
  return size <= 65535
end
return SMoveChildHomeSuccess
