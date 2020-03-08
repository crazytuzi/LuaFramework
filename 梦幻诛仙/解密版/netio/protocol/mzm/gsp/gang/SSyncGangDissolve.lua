local SSyncGangDissolve = class("SSyncGangDissolve")
SSyncGangDissolve.TYPEID = 12589838
function SSyncGangDissolve:ctor()
  self.id = 12589838
end
function SSyncGangDissolve:marshal(os)
end
function SSyncGangDissolve:unmarshal(os)
end
function SSyncGangDissolve:sizepolicy(size)
  return size <= 65535
end
return SSyncGangDissolve
