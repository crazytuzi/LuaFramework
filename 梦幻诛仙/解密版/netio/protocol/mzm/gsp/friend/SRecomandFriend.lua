local SRecomandFriend = class("SRecomandFriend")
SRecomandFriend.TYPEID = 12587034
function SRecomandFriend:ctor(recomandFriends)
  self.id = 12587034
  self.recomandFriends = recomandFriends or {}
end
function SRecomandFriend:marshal(os)
  os:marshalCompactUInt32(table.getn(self.recomandFriends))
  for _, v in ipairs(self.recomandFriends) do
    v:marshal(os)
  end
end
function SRecomandFriend:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.friend.RecomandFriendInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.recomandFriends, v)
  end
end
function SRecomandFriend:sizepolicy(size)
  return size <= 65535
end
return SRecomandFriend
