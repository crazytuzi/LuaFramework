local SSendCatToExploreFailed = class("SSendCatToExploreFailed")
SSendCatToExploreFailed.TYPEID = 12605707
SSendCatToExploreFailed.ERROR_VIGOR_NOT_ENOUGH = -1
SSendCatToExploreFailed.ERROR_EXPLORE_NUM_MAX = -2
SSendCatToExploreFailed.ERROR_AWARD_NOT_RECEIVED = -3
function SSendCatToExploreFailed:ctor(retcode)
  self.id = 12605707
  self.retcode = retcode or nil
end
function SSendCatToExploreFailed:marshal(os)
  os:marshalInt32(self.retcode)
end
function SSendCatToExploreFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SSendCatToExploreFailed:sizepolicy(size)
  return size <= 65535
end
return SSendCatToExploreFailed
