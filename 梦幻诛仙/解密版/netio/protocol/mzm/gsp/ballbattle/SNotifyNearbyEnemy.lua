local SNotifyNearbyEnemy = class("SNotifyNearbyEnemy")
SNotifyNearbyEnemy.TYPEID = 12629258
function SNotifyNearbyEnemy:ctor(role_id, is_level_higher)
  self.id = 12629258
  self.role_id = role_id or nil
  self.is_level_higher = is_level_higher or nil
end
function SNotifyNearbyEnemy:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalInt32(self.is_level_higher)
end
function SNotifyNearbyEnemy:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.is_level_higher = os:unmarshalInt32()
end
function SNotifyNearbyEnemy:sizepolicy(size)
  return size <= 65535
end
return SNotifyNearbyEnemy
