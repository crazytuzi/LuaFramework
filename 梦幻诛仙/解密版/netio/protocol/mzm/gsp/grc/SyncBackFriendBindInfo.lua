local RebateInfo = require("netio.protocol.mzm.gsp.grc.RebateInfo")
local SyncBackFriendBindInfo = class("SyncBackFriendBindInfo")
SyncBackFriendBindInfo.TYPEID = 12600375
function SyncBackFriendBindInfo:ctor(back_friends, rebate_info)
  self.id = 12600375
  self.back_friends = back_friends or {}
  self.rebate_info = rebate_info or RebateInfo.new()
end
function SyncBackFriendBindInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.back_friends))
  for _, v in ipairs(self.back_friends) do
    v:marshal(os)
  end
  self.rebate_info:marshal(os)
end
function SyncBackFriendBindInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.grc.FriendBindInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.back_friends, v)
  end
  self.rebate_info = RebateInfo.new()
  self.rebate_info:unmarshal(os)
end
function SyncBackFriendBindInfo:sizepolicy(size)
  return size <= 65535
end
return SyncBackFriendBindInfo
