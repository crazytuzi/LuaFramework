local SFillGridFailed = class("SFillGridFailed")
SFillGridFailed.TYPEID = 12608264
SFillGridFailed.ERROR_FILLED = -1
SFillGridFailed.ERROR_ORDER = -2
SFillGridFailed.ERROR_EXPIRED = -3
SFillGridFailed.ERROR_MONEY = -4
function SFillGridFailed:ctor(cur_index, retcode)
  self.id = 12608264
  self.cur_index = cur_index or nil
  self.retcode = retcode or nil
end
function SFillGridFailed:marshal(os)
  os:marshalInt32(self.cur_index)
  os:marshalInt32(self.retcode)
end
function SFillGridFailed:unmarshal(os)
  self.cur_index = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SFillGridFailed:sizepolicy(size)
  return size <= 65535
end
return SFillGridFailed
