local SPetFightImproveFormationSuccess = class("SPetFightImproveFormationSuccess")
SPetFightImproveFormationSuccess.TYPEID = 12590686
function SPetFightImproveFormationSuccess:ctor(formation_id, level, exp)
  self.id = 12590686
  self.formation_id = formation_id or nil
  self.level = level or nil
  self.exp = exp or nil
end
function SPetFightImproveFormationSuccess:marshal(os)
  os:marshalInt32(self.formation_id)
  os:marshalInt32(self.level)
  os:marshalInt32(self.exp)
end
function SPetFightImproveFormationSuccess:unmarshal(os)
  self.formation_id = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.exp = os:unmarshalInt32()
end
function SPetFightImproveFormationSuccess:sizepolicy(size)
  return size <= 65535
end
return SPetFightImproveFormationSuccess
