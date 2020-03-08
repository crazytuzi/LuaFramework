local SJoinShoppingGroupFail = class("SJoinShoppingGroupFail")
SJoinShoppingGroupFail.TYPEID = 12623618
SJoinShoppingGroupFail.INSUFFICIENT_YUANBAO = 1
SJoinShoppingGroupFail.CLOSED = 2
SJoinShoppingGroupFail.PARTICIPATING = 3
SJoinShoppingGroupFail.REACH_BUY_LIMIT = 4
SJoinShoppingGroupFail.SYSTEM_BUSY = 5
function SJoinShoppingGroupFail:ctor(reason, group_id)
  self.id = 12623618
  self.reason = reason or nil
  self.group_id = group_id or nil
end
function SJoinShoppingGroupFail:marshal(os)
  os:marshalInt32(self.reason)
  os:marshalInt64(self.group_id)
end
function SJoinShoppingGroupFail:unmarshal(os)
  self.reason = os:unmarshalInt32()
  self.group_id = os:unmarshalInt64()
end
function SJoinShoppingGroupFail:sizepolicy(size)
  return size <= 65535
end
return SJoinShoppingGroupFail
