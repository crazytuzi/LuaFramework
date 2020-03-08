local SSyncFriendsCircleInfo = class("SSyncFriendsCircleInfo")
SSyncFriendsCircleInfo.TYPEID = 12625409
function SSyncFriendsCircleInfo:ctor(current_pendant_item_cfg_id, current_rahmen_item_cfg_id, own_pendant_item_cfg_id_set, own_rahmen_item_cfg_id_set, current_treasure_box_num, receive_gift_num, current_week_popularity_value, total_popularity_value, my_black_role_set)
  self.id = 12625409
  self.current_pendant_item_cfg_id = current_pendant_item_cfg_id or nil
  self.current_rahmen_item_cfg_id = current_rahmen_item_cfg_id or nil
  self.own_pendant_item_cfg_id_set = own_pendant_item_cfg_id_set or {}
  self.own_rahmen_item_cfg_id_set = own_rahmen_item_cfg_id_set or {}
  self.current_treasure_box_num = current_treasure_box_num or nil
  self.receive_gift_num = receive_gift_num or nil
  self.current_week_popularity_value = current_week_popularity_value or nil
  self.total_popularity_value = total_popularity_value or nil
  self.my_black_role_set = my_black_role_set or {}
end
function SSyncFriendsCircleInfo:marshal(os)
  os:marshalInt32(self.current_pendant_item_cfg_id)
  os:marshalInt32(self.current_rahmen_item_cfg_id)
  do
    local _size_ = 0
    for _, _ in pairs(self.own_pendant_item_cfg_id_set) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.own_pendant_item_cfg_id_set) do
      os:marshalInt32(k)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.own_rahmen_item_cfg_id_set) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.own_rahmen_item_cfg_id_set) do
      os:marshalInt32(k)
    end
  end
  os:marshalInt32(self.current_treasure_box_num)
  os:marshalInt32(self.receive_gift_num)
  os:marshalInt32(self.current_week_popularity_value)
  os:marshalInt32(self.total_popularity_value)
  local _size_ = 0
  for _, _ in pairs(self.my_black_role_set) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.my_black_role_set) do
    os:marshalInt64(k)
  end
end
function SSyncFriendsCircleInfo:unmarshal(os)
  self.current_pendant_item_cfg_id = os:unmarshalInt32()
  self.current_rahmen_item_cfg_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.own_pendant_item_cfg_id_set[v] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.own_rahmen_item_cfg_id_set[v] = v
  end
  self.current_treasure_box_num = os:unmarshalInt32()
  self.receive_gift_num = os:unmarshalInt32()
  self.current_week_popularity_value = os:unmarshalInt32()
  self.total_popularity_value = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    self.my_black_role_set[v] = v
  end
end
function SSyncFriendsCircleInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncFriendsCircleInfo
