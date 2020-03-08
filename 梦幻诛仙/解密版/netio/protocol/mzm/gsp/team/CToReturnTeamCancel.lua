local CToReturnTeamCancel = class("CToReturnTeamCancel")
CToReturnTeamCancel.TYPEID = 12588290
function CToReturnTeamCancel:ctor(role)
  self.id = 12588290
  self.role = role or nil
end
function CToReturnTeamCancel:marshal(os)
  os:marshalInt64(self.role)
end
function CToReturnTeamCancel:unmarshal(os)
  self.role = os:unmarshalInt64()
end
function CToReturnTeamCancel:sizepolicy(size)
  return size <= 65535
end
return CToReturnTeamCancel
