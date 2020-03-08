local CRequestRoleInfoInView = class("CRequestRoleInfoInView")
CRequestRoleInfoInView.TYPEID = 12590863
function CRequestRoleInfoInView:ctor()
  self.id = 12590863
end
function CRequestRoleInfoInView:marshal(os)
end
function CRequestRoleInfoInView:unmarshal(os)
end
function CRequestRoleInfoInView:sizepolicy(size)
  return size <= 65535
end
return CRequestRoleInfoInView
