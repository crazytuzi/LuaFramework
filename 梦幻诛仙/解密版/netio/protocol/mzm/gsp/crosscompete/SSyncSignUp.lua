local SSyncSignUp = class("SSyncSignUp")
SSyncSignUp.TYPEID = 12616733
function SSyncSignUp:ctor()
  self.id = 12616733
end
function SSyncSignUp:marshal(os)
end
function SSyncSignUp:unmarshal(os)
end
function SSyncSignUp:sizepolicy(size)
  return size <= 65535
end
return SSyncSignUp
