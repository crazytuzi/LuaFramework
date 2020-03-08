local SSyncGangLevelUpDonate = class("SSyncGangLevelUpDonate")
SSyncGangLevelUpDonate.TYPEID = 12589899
function SSyncGangLevelUpDonate:ctor()
  self.id = 12589899
end
function SSyncGangLevelUpDonate:marshal(os)
end
function SSyncGangLevelUpDonate:unmarshal(os)
end
function SSyncGangLevelUpDonate:sizepolicy(size)
  return size <= 65535
end
return SSyncGangLevelUpDonate
