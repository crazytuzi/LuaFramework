local SSynHomelandRes = class("SSynHomelandRes")
SSynHomelandRes.TYPEID = 12605461
function SSynHomelandRes:ctor(homeLevel, cleanliness, fengShuiValue, petRoomLevel, dayTtrainPetCount, bedRoomLevel, dayRestoreVigorCount, dayRestoreSatiationCount, dayCleanCount, drugRoomLevel, kitchenLevel, maidRoomLevel, hasMaids, currentMaidUuid, my_display_room_furniture_uuid_set, isOwner, my_display_courtyard_furniture_uuid_set, courtyard_cleanliness, courtyard_beautiful_value, courtyard_level, courtyard_day_clean_count)
  self.id = 12605461
  self.homeLevel = homeLevel or nil
  self.cleanliness = cleanliness or nil
  self.fengShuiValue = fengShuiValue or nil
  self.petRoomLevel = petRoomLevel or nil
  self.dayTtrainPetCount = dayTtrainPetCount or nil
  self.bedRoomLevel = bedRoomLevel or nil
  self.dayRestoreVigorCount = dayRestoreVigorCount or nil
  self.dayRestoreSatiationCount = dayRestoreSatiationCount or nil
  self.dayCleanCount = dayCleanCount or nil
  self.drugRoomLevel = drugRoomLevel or nil
  self.kitchenLevel = kitchenLevel or nil
  self.maidRoomLevel = maidRoomLevel or nil
  self.hasMaids = hasMaids or {}
  self.currentMaidUuid = currentMaidUuid or nil
  self.my_display_room_furniture_uuid_set = my_display_room_furniture_uuid_set or {}
  self.isOwner = isOwner or nil
  self.my_display_courtyard_furniture_uuid_set = my_display_courtyard_furniture_uuid_set or {}
  self.courtyard_cleanliness = courtyard_cleanliness or nil
  self.courtyard_beautiful_value = courtyard_beautiful_value or nil
  self.courtyard_level = courtyard_level or nil
  self.courtyard_day_clean_count = courtyard_day_clean_count or nil
end
function SSynHomelandRes:marshal(os)
  os:marshalInt32(self.homeLevel)
  os:marshalInt32(self.cleanliness)
  os:marshalInt32(self.fengShuiValue)
  os:marshalInt32(self.petRoomLevel)
  os:marshalInt32(self.dayTtrainPetCount)
  os:marshalInt32(self.bedRoomLevel)
  os:marshalInt32(self.dayRestoreVigorCount)
  os:marshalInt32(self.dayRestoreSatiationCount)
  os:marshalInt32(self.dayCleanCount)
  os:marshalInt32(self.drugRoomLevel)
  os:marshalInt32(self.kitchenLevel)
  os:marshalInt32(self.maidRoomLevel)
  do
    local _size_ = 0
    for _, _ in pairs(self.hasMaids) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.hasMaids) do
      os:marshalInt64(k)
      v:marshal(os)
    end
  end
  os:marshalInt64(self.currentMaidUuid)
  do
    local _size_ = 0
    for _, _ in pairs(self.my_display_room_furniture_uuid_set) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.my_display_room_furniture_uuid_set) do
      os:marshalInt64(k)
    end
  end
  os:marshalInt32(self.isOwner)
  do
    local _size_ = 0
    for _, _ in pairs(self.my_display_courtyard_furniture_uuid_set) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.my_display_courtyard_furniture_uuid_set) do
      os:marshalInt64(k)
    end
  end
  os:marshalInt32(self.courtyard_cleanliness)
  os:marshalInt32(self.courtyard_beautiful_value)
  os:marshalInt32(self.courtyard_level)
  os:marshalInt32(self.courtyard_day_clean_count)
end
function SSynHomelandRes:unmarshal(os)
  self.homeLevel = os:unmarshalInt32()
  self.cleanliness = os:unmarshalInt32()
  self.fengShuiValue = os:unmarshalInt32()
  self.petRoomLevel = os:unmarshalInt32()
  self.dayTtrainPetCount = os:unmarshalInt32()
  self.bedRoomLevel = os:unmarshalInt32()
  self.dayRestoreVigorCount = os:unmarshalInt32()
  self.dayRestoreSatiationCount = os:unmarshalInt32()
  self.dayCleanCount = os:unmarshalInt32()
  self.drugRoomLevel = os:unmarshalInt32()
  self.kitchenLevel = os:unmarshalInt32()
  self.maidRoomLevel = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.homeland.MaidInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.hasMaids[k] = v
  end
  self.currentMaidUuid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    self.my_display_room_furniture_uuid_set[v] = v
  end
  self.isOwner = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    self.my_display_courtyard_furniture_uuid_set[v] = v
  end
  self.courtyard_cleanliness = os:unmarshalInt32()
  self.courtyard_beautiful_value = os:unmarshalInt32()
  self.courtyard_level = os:unmarshalInt32()
  self.courtyard_day_clean_count = os:unmarshalInt32()
end
function SSynHomelandRes:sizepolicy(size)
  return size <= 65535
end
return SSynHomelandRes
