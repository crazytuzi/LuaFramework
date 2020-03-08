local CGetFirstRechargeAward = class("CGetFirstRechargeAward")
CGetFirstRechargeAward.TYPEID = 12588806
function CGetFirstRechargeAward:ctor()
  self.id = 12588806
end
function CGetFirstRechargeAward:marshal(os)
end
function CGetFirstRechargeAward:unmarshal(os)
end
function CGetFirstRechargeAward:sizepolicy(size)
  return size <= 65535
end
return CGetFirstRechargeAward
