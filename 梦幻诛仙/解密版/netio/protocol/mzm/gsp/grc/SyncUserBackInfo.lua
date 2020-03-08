local SyncUserBackInfo = class("SyncUserBackInfo")
SyncUserBackInfo.TYPEID = 12600371
function SyncUserBackInfo:ctor(first, back_time, recall_friends)
  self.id = 12600371
  self.first = first or nil
  self.back_time = back_time or nil
  self.recall_friends = recall_friends or {}
end
function SyncUserBackInfo:marshal(os)
  os:marshalInt32(self.first)
  os:marshalInt32(self.back_time)
  os:marshalCompactUInt32(table.getn(self.recall_friends))
  for _, v in ipairs(self.recall_friends) do
    v:marshal(os)
  end
end
function SyncUserBackInfo:unmarshal(os)
  self.first = os:unmarshalInt32()
  self.back_time = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.grc.FriendRecallInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.recall_friends, v)
  end
end
function SyncUserBackInfo:sizepolicy(size)
  return size <= 65535
end
return SyncUserBackInfo
