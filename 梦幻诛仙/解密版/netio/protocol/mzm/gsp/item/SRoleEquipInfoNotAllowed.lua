local SRoleEquipInfoNotAllowed = class("SRoleEquipInfoNotAllowed")
SRoleEquipInfoNotAllowed.TYPEID = 12584833
function SRoleEquipInfoNotAllowed:ctor()
  self.id = 12584833
end
function SRoleEquipInfoNotAllowed:marshal(os)
end
function SRoleEquipInfoNotAllowed:unmarshal(os)
end
function SRoleEquipInfoNotAllowed:sizepolicy(size)
  return size <= 65535
end
return SRoleEquipInfoNotAllowed
