local SSyncGangMiFangOutOfUse = class("SSyncGangMiFangOutOfUse")
SSyncGangMiFangOutOfUse.TYPEID = 12589922
function SSyncGangMiFangOutOfUse:ctor()
  self.id = 12589922
end
function SSyncGangMiFangOutOfUse:marshal(os)
end
function SSyncGangMiFangOutOfUse:unmarshal(os)
end
function SSyncGangMiFangOutOfUse:sizepolicy(size)
  return size <= 65535
end
return SSyncGangMiFangOutOfUse
