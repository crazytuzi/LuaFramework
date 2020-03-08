local SGetRecallRebateFailed = class("SGetRecallRebateFailed")
SGetRecallRebateFailed.TYPEID = 12600385
SGetRecallRebateFailed.ERROR_REDIS_LOCK = -1
SGetRecallRebateFailed.ERROR_RECALL_REBATE_NOT_ENOUGH = -2
SGetRecallRebateFailed.ERROR_RECALL_REBATE_MAX = -3
SGetRecallRebateFailed.ERROR_RECALL_LEVEL = -4
SGetRecallRebateFailed.ERROR_RECALL_NET = -5
function SGetRecallRebateFailed:ctor(num, retcode)
  self.id = 12600385
  self.num = num or nil
  self.retcode = retcode or nil
end
function SGetRecallRebateFailed:marshal(os)
  os:marshalInt32(self.num)
  os:marshalInt32(self.retcode)
end
function SGetRecallRebateFailed:unmarshal(os)
  self.num = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SGetRecallRebateFailed:sizepolicy(size)
  return size <= 65535
end
return SGetRecallRebateFailed
