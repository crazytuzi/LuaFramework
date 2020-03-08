local SSyncFightRobberTipRes = class("SSyncFightRobberTipRes")
SSyncFightRobberTipRes.TYPEID = 12587591
function SSyncFightRobberTipRes:ctor()
  self.id = 12587591
end
function SSyncFightRobberTipRes:marshal(os)
end
function SSyncFightRobberTipRes:unmarshal(os)
end
function SSyncFightRobberTipRes:sizepolicy(size)
  return size <= 65535
end
return SSyncFightRobberTipRes
