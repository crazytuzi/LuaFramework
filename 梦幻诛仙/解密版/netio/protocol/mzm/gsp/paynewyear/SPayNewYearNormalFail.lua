local SPayNewYearNormalFail = class("SPayNewYearNormalFail")
SPayNewYearNormalFail.TYPEID = 12609028
SPayNewYearNormalFail.ACTIVITY_CAN_NOT_JOIN = 1
SPayNewYearNormalFail.LAST_AWARD_NOT_GET = 2
SPayNewYearNormalFail.CAN_NOT_PAY_NEW_YEAR_YOURSELF = 3
function SPayNewYearNormalFail:ctor(result)
  self.id = 12609028
  self.result = result or nil
end
function SPayNewYearNormalFail:marshal(os)
  os:marshalInt32(self.result)
end
function SPayNewYearNormalFail:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SPayNewYearNormalFail:sizepolicy(size)
  return size <= 65535
end
return SPayNewYearNormalFail
