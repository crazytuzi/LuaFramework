local SShangGongFail = class("SShangGongFail")
SShangGongFail.TYPEID = 12610562
SShangGongFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SShangGongFail.ROLE_STATUS_ERROR = -2
SShangGongFail.PARAM_ERROR = -3
SShangGongFail.OVERTIME = 1
SShangGongFail.CONTEXT_NOT_MATCH = 2
SShangGongFail.MONEY_NOT_MATCH = 3
SShangGongFail.MONEY_NOT_ENOUGH = 4
SShangGongFail.COST_MONEY_FAIL = 5
function SShangGongFail:ctor(res)
  self.id = 12610562
  self.res = res or nil
end
function SShangGongFail:marshal(os)
  os:marshalInt32(self.res)
end
function SShangGongFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SShangGongFail:sizepolicy(size)
  return size <= 65535
end
return SShangGongFail
