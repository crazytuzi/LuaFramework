local CUnrideMultiRoleMounts = class("CUnrideMultiRoleMounts")
CUnrideMultiRoleMounts.TYPEID = 12606256
function CUnrideMultiRoleMounts:ctor()
  self.id = 12606256
end
function CUnrideMultiRoleMounts:marshal(os)
end
function CUnrideMultiRoleMounts:unmarshal(os)
end
function CUnrideMultiRoleMounts:sizepolicy(size)
  return size <= 65535
end
return CUnrideMultiRoleMounts
