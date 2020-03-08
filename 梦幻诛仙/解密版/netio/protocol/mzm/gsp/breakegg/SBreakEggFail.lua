local SBreakEggFail = class("SBreakEggFail")
SBreakEggFail.TYPEID = 12623362
SBreakEggFail.ERROR_SYSTEM = 1
SBreakEggFail.ERROR_USERID = 2
SBreakEggFail.ERROR_CFG = 3
SBreakEggFail.ERROR_PARAM = 4
SBreakEggFail.ERROR_NO_TIMES = 5
SBreakEggFail.ERROR_ALREADY_BREAKED = 6
SBreakEggFail.ERROR_NOT_IN_GAME = 7
function SBreakEggFail:ctor(activity_id, index, error_code)
  self.id = 12623362
  self.activity_id = activity_id or nil
  self.index = index or nil
  self.error_code = error_code or nil
end
function SBreakEggFail:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.index)
  os:marshalInt32(self.error_code)
end
function SBreakEggFail:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
  self.error_code = os:unmarshalInt32()
end
function SBreakEggFail:sizepolicy(size)
  return size <= 65535
end
return SBreakEggFail
