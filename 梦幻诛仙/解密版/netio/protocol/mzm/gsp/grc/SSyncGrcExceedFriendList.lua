local SSyncGrcExceedFriendList = class("SSyncGrcExceedFriendList")
SSyncGrcExceedFriendList.TYPEID = 12600332
function SSyncGrcExceedFriendList:ctor(retcode, level_type, friends)
  self.id = 12600332
  self.retcode = retcode or nil
  self.level_type = level_type or nil
  self.friends = friends or {}
end
function SSyncGrcExceedFriendList:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.level_type)
  os:marshalCompactUInt32(table.getn(self.friends))
  for _, v in ipairs(self.friends) do
    v:marshal(os)
  end
end
function SSyncGrcExceedFriendList:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.level_type = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.grc.GrcPassedFriendInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.friends, v)
  end
end
function SSyncGrcExceedFriendList:sizepolicy(size)
  return size <= 65535
end
return SSyncGrcExceedFriendList
