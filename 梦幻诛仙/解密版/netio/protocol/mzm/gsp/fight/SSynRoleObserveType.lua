local SSynRoleObserveType = class("SSynRoleObserveType")
SSynRoleObserveType.TYPEID = 12594212
function SSynRoleObserveType:ctor(fight_uuid, teamType)
  self.id = 12594212
  self.fight_uuid = fight_uuid or nil
  self.teamType = teamType or nil
end
function SSynRoleObserveType:marshal(os)
  os:marshalInt64(self.fight_uuid)
  os:marshalInt32(self.teamType)
end
function SSynRoleObserveType:unmarshal(os)
  self.fight_uuid = os:unmarshalInt64()
  self.teamType = os:unmarshalInt32()
end
function SSynRoleObserveType:sizepolicy(size)
  return size <= 65535
end
return SSynRoleObserveType
