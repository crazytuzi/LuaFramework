local SQiuQianFail = class("SQiuQianFail")
SQiuQianFail.TYPEID = 12610820
SQiuQianFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SQiuQianFail.ROLE_STATUS_ERROR = -2
SQiuQianFail.PARAM_ERROR = -3
SQiuQianFail.OVERTIME = 1
SQiuQianFail.CONTEXT_NOT_MATCH = 2
function SQiuQianFail:ctor(res)
  self.id = 12610820
  self.res = res or nil
end
function SQiuQianFail:marshal(os)
  os:marshalInt32(self.res)
end
function SQiuQianFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SQiuQianFail:sizepolicy(size)
  return size <= 65535
end
return SQiuQianFail
