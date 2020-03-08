local SSynFriendList = class("SSynFriendList")
SSynFriendList.TYPEID = 12587021
function SSynFriendList:ctor(friendList)
  self.id = 12587021
  self.friendList = friendList or {}
end
function SSynFriendList:marshal(os)
  os:marshalCompactUInt32(table.getn(self.friendList))
  for _, v in ipairs(self.friendList) do
    v:marshal(os)
  end
end
function SSynFriendList:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.friend.FriendInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.friendList, v)
  end
end
function SSynFriendList:sizepolicy(size)
  return size <= 65535
end
return SSynFriendList
