local SGetFirstRechargeAwardResp = class("SGetFirstRechargeAwardResp")
SGetFirstRechargeAwardResp.TYPEID = 12588808
SGetFirstRechargeAwardResp.SUCCESS = 0
SGetFirstRechargeAwardResp.ERROR_NOT_RECHARGE = -1
SGetFirstRechargeAwardResp.ERROR_ALREADY_GET = -3
function SGetFirstRechargeAwardResp:ctor(retcode)
  self.id = 12588808
  self.retcode = retcode or nil
end
function SGetFirstRechargeAwardResp:marshal(os)
  os:marshalInt32(self.retcode)
end
function SGetFirstRechargeAwardResp:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SGetFirstRechargeAwardResp:sizepolicy(size)
  return size <= 65535
end
return SGetFirstRechargeAwardResp
