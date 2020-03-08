local CRideMultiRoleMounts = class("CRideMultiRoleMounts")
CRideMultiRoleMounts.TYPEID = 12606254
function CRideMultiRoleMounts:ctor()
  self.id = 12606254
end
function CRideMultiRoleMounts:marshal(os)
end
function CRideMultiRoleMounts:unmarshal(os)
end
function CRideMultiRoleMounts:sizepolicy(size)
  return size <= 65535
end
return CRideMultiRoleMounts
