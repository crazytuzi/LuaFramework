local SActivityCompensateNormalResult = class("SActivityCompensateNormalResult")
SActivityCompensateNormalResult.TYPEID = 12627457
SActivityCompensateNormalResult.GET_AWARD__INVALID_LEFT_TIMES = 1
SActivityCompensateNormalResult.GET_AWARD__LACK_GOLD = 2
SActivityCompensateNormalResult.GET_AWARD__LACK_YUANBAO = 3
SActivityCompensateNormalResult.GET_AWARD__NO_LEFT_TIMES = 4
SActivityCompensateNormalResult.GET_AWARD__ACTIVITY_CLOSED = 5
SActivityCompensateNormalResult.GET_ALL_AWARD__LACK_GOLD = 21
SActivityCompensateNormalResult.GET_ALL_AWARD__LACK_YUANBAO = 22
SActivityCompensateNormalResult.GET_ALL_AWARD__NO_AWARD = 23
function SActivityCompensateNormalResult:ctor(result)
  self.id = 12627457
  self.result = result or nil
end
function SActivityCompensateNormalResult:marshal(os)
  os:marshalInt32(self.result)
end
function SActivityCompensateNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SActivityCompensateNormalResult:sizepolicy(size)
  return size <= 65535
end
return SActivityCompensateNormalResult
