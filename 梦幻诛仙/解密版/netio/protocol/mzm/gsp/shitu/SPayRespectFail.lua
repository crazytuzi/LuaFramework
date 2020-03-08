local SPayRespectFail = class("SPayRespectFail")
SPayRespectFail.TYPEID = 12601630
SPayRespectFail.NO_RESPECT_TIMES_LEFT = 1
SPayRespectFail.WAIT_FOR_MASTER = 2
SPayRespectFail.MASTER_NOT_ONLINE = 3
SPayRespectFail.MASTER_IS_IN_PAY_RESPECT = 4
SPayRespectFail.APPRENTICE_NOT_ONLINE = 5
function SPayRespectFail:ctor(result)
  self.id = 12601630
  self.result = result or nil
end
function SPayRespectFail:marshal(os)
  os:marshalInt32(self.result)
end
function SPayRespectFail:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SPayRespectFail:sizepolicy(size)
  return size <= 65535
end
return SPayRespectFail
