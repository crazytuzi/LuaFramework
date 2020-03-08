local SSyncGrcGetFriendList = class("SSyncGrcGetFriendList")
SSyncGrcGetFriendList.TYPEID = 12600327
function SSyncGrcGetFriendList:ctor(total_friend_count, page_index, friends)
  self.id = 12600327
  self.total_friend_count = total_friend_count or nil
  self.page_index = page_index or nil
  self.friends = friends or {}
end
function SSyncGrcGetFriendList:marshal(os)
  os:marshalInt32(self.total_friend_count)
  os:marshalInt32(self.page_index)
  os:marshalCompactUInt32(table.getn(self.friends))
  for _, v in ipairs(self.friends) do
    v:marshal(os)
  end
end
function SSyncGrcGetFriendList:unmarshal(os)
  self.total_friend_count = os:unmarshalInt32()
  self.page_index = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.grc.GrcFriendInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.friends, v)
  end
end
function SSyncGrcGetFriendList:sizepolicy(size)
  return size <= 65535
end
return SSyncGrcGetFriendList
