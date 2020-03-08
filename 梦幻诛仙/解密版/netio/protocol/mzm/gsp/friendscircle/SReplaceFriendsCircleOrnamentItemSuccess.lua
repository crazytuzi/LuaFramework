local SReplaceFriendsCircleOrnamentItemSuccess = class("SReplaceFriendsCircleOrnamentItemSuccess")
SReplaceFriendsCircleOrnamentItemSuccess.TYPEID = 12625418
function SReplaceFriendsCircleOrnamentItemSuccess:ctor(change_ornament_map)
  self.id = 12625418
  self.change_ornament_map = change_ornament_map or {}
end
function SReplaceFriendsCircleOrnamentItemSuccess:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.change_ornament_map) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.change_ornament_map) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SReplaceFriendsCircleOrnamentItemSuccess:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.friendscircle.ChangeOrnament")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.change_ornament_map[k] = v
  end
end
function SReplaceFriendsCircleOrnamentItemSuccess:sizepolicy(size)
  return size <= 65535
end
return SReplaceFriendsCircleOrnamentItemSuccess
