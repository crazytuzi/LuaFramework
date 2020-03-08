local SSyncFirstRechargeInfo = class("SSyncFirstRechargeInfo")
SSyncFirstRechargeInfo.TYPEID = 12588807
SSyncFirstRechargeInfo.INIT = 1
SSyncFirstRechargeInfo.AWARD = 2
SSyncFirstRechargeInfo.FINISH = 3
function SSyncFirstRechargeInfo:ctor(status)
  self.id = 12588807
  self.status = status or nil
end
function SSyncFirstRechargeInfo:marshal(os)
  os:marshalInt32(self.status)
end
function SSyncFirstRechargeInfo:unmarshal(os)
  self.status = os:unmarshalInt32()
end
function SSyncFirstRechargeInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncFirstRechargeInfo
