local SPetFightImproveFormationFail = class("SPetFightImproveFormationFail")
SPetFightImproveFormationFail.TYPEID = 12590694
SPetFightImproveFormationFail.INVALID_ITEM = 1
SPetFightImproveFormationFail.ITEM_NOT_EXISTS = 2
SPetFightImproveFormationFail.REACH_MAX_LEVEL = 3
SPetFightImproveFormationFail.USE_FRAGMENT_ON_LOCKED_FORMATION = 4
function SPetFightImproveFormationFail:ctor(reason, formation_id)
  self.id = 12590694
  self.reason = reason or nil
  self.formation_id = formation_id or nil
end
function SPetFightImproveFormationFail:marshal(os)
  os:marshalInt32(self.reason)
  os:marshalInt32(self.formation_id)
end
function SPetFightImproveFormationFail:unmarshal(os)
  self.reason = os:unmarshalInt32()
  self.formation_id = os:unmarshalInt32()
end
function SPetFightImproveFormationFail:sizepolicy(size)
  return size <= 65535
end
return SPetFightImproveFormationFail
