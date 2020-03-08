local SSwornDissolve = class("SSwornDissolve")
SSwornDissolve.TYPEID = 12597788
function SSwornDissolve:ctor()
  self.id = 12597788
end
function SSwornDissolve:marshal(os)
end
function SSwornDissolve:unmarshal(os)
end
function SSwornDissolve:sizepolicy(size)
  return size <= 65535
end
return SSwornDissolve
