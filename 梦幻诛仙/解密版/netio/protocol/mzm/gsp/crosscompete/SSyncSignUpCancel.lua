local SSyncSignUpCancel = class("SSyncSignUpCancel")
SSyncSignUpCancel.TYPEID = 12616734
function SSyncSignUpCancel:ctor()
  self.id = 12616734
end
function SSyncSignUpCancel:marshal(os)
end
function SSyncSignUpCancel:unmarshal(os)
end
function SSyncSignUpCancel:sizepolicy(size)
  return size <= 65535
end
return SSyncSignUpCancel
