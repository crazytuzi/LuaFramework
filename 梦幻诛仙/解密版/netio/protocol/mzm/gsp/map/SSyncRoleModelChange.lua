local SSyncRoleModelChange = class("SSyncRoleModelChange")
SSyncRoleModelChange.TYPEID = 12590859
SSyncRoleModelChange.PET_MODEL_ID = 0
SSyncRoleModelChange.WEAPON_MODEL_ID = 1
SSyncRoleModelChange.WEAPON_EFFECT_ID = 2
SSyncRoleModelChange.WING_ID = 3
SSyncRoleModelChange.ROLE_MODEL_ID = 4
SSyncRoleModelChange.ROLE_COLOR_ID = 5
SSyncRoleModelChange.MOUNTS_ID = 6
SSyncRoleModelChange.ROLE_VELOCITY = 7
SSyncRoleModelChange.FABAO_MODEL_ID = 8
SSyncRoleModelChange.TITLEID = 9
SSyncRoleModelChange.APPELLATIONID = 10
SSyncRoleModelChange.QILING_LEVEL = 11
SSyncRoleModelChange.PET_COLOR_ID = 12
SSyncRoleModelChange.MOUNTS_COLOR_ID = 13
SSyncRoleModelChange.HUSONG_FOLLOW_MONSTER_ID = 14
SSyncRoleModelChange.MAP_APP_COLOR_ID = 15
SSyncRoleModelChange.ROLE_HAIR_COLOR_ID = 16
SSyncRoleModelChange.ROLE_CLOTH_COLOR_ID = 17
SSyncRoleModelChange.PET_SHIPIN = 18
SSyncRoleModelChange.WING_COLOR_ID = 19
SSyncRoleModelChange.AIRCRAFT_ID = 20
SSyncRoleModelChange.EXTERIOR_ID = 21
SSyncRoleModelChange.HUSONG_COUPLE_FLY_NPC_CFG_ID = 22
SSyncRoleModelChange.GENDER = 23
SSyncRoleModelChange.FASHION_DRESS_ID = 24
SSyncRoleModelChange.QILING_EFFECT_LEVEL = 25
SSyncRoleModelChange.PET_STAGE_LEVEL = 26
SSyncRoleModelChange.MOUNTS_RANK = 27
SSyncRoleModelChange.PET_EXTERIOR_ID = 28
SSyncRoleModelChange.PET_EXTERIOR_COLOR_ID = 29
SSyncRoleModelChange.MAGIC_MARK = 30
SSyncRoleModelChange.CHILDREN_PHASE = 31
SSyncRoleModelChange.CHILDREN_GENDER = 32
SSyncRoleModelChange.CHILDREN_FASHION = 33
SSyncRoleModelChange.CHILDREN_MODEL_ID = 34
SSyncRoleModelChange.CHILDREN_WEAPON_ID = 35
SSyncRoleModelChange.FABAO_LINGQI_MODEL_ID = 36
SSyncRoleModelChange.WUSHI_ID = 37
SSyncRoleModelChange.MORAL_VALUE = 38
SSyncRoleModelChange.CHANGE_MODEL_CARD_CFGID = 39
SSyncRoleModelChange.CHANGE_MODEL_CARD_LEVEL = 40
SSyncRoleModelChange.CHANGE_MODEL_CARD_MINI = 41
SSyncRoleModelChange.AIRCRAFT_COLOR_ID = 42
SSyncRoleModelChange.OUTLOOK_ID = 43
SSyncRoleModelChange.PET_MARK_CFG_ID = 44
SSyncRoleModelChange.PET_NAME = 0
SSyncRoleModelChange.APPELLATION = 1
SSyncRoleModelChange.MAP_APP_TEXT = 2
SSyncRoleModelChange.CHILDREN_NAME = 3
SSyncRoleModelChange.PET_ID = 0
SSyncRoleModelChange.CHILDREN_ID = 1
function SSyncRoleModelChange:ctor(roleId, intPropMap, stringPropMap, longPropMap)
  self.id = 12590859
  self.roleId = roleId or nil
  self.intPropMap = intPropMap or {}
  self.stringPropMap = stringPropMap or {}
  self.longPropMap = longPropMap or {}
end
function SSyncRoleModelChange:marshal(os)
  os:marshalInt64(self.roleId)
  do
    local _size_ = 0
    for _, _ in pairs(self.intPropMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.intPropMap) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.stringPropMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.stringPropMap) do
      os:marshalInt32(k)
      os:marshalString(v)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.longPropMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.longPropMap) do
    os:marshalInt32(k)
    os:marshalInt64(v)
  end
end
function SSyncRoleModelChange:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.intPropMap[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalString()
    self.stringPropMap[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt64()
    self.longPropMap[k] = v
  end
end
function SSyncRoleModelChange:sizepolicy(size)
  return size <= 65535
end
return SSyncRoleModelChange
