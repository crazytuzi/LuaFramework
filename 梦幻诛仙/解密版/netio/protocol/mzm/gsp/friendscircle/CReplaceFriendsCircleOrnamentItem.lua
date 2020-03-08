local CReplaceFriendsCircleOrnamentItem = class("CReplaceFriendsCircleOrnamentItem")
CReplaceFriendsCircleOrnamentItem.TYPEID = 12625420
function CReplaceFriendsCircleOrnamentItem:ctor(replace_ornament_map)
  self.id = 12625420
  self.replace_ornament_map = replace_ornament_map or {}
end
function CReplaceFriendsCircleOrnamentItem:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.replace_ornament_map) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.replace_ornament_map) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function CReplaceFriendsCircleOrnamentItem:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.replace_ornament_map[k] = v
  end
end
function CReplaceFriendsCircleOrnamentItem:sizepolicy(size)
  return size <= 65535
end
return CReplaceFriendsCircleOrnamentItem
