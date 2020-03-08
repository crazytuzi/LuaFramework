local SSyncGangMiFangTrigger = class("SSyncGangMiFangTrigger")
SSyncGangMiFangTrigger.TYPEID = 12589918
function SSyncGangMiFangTrigger:ctor(cfgId)
  self.id = 12589918
  self.cfgId = cfgId or nil
end
function SSyncGangMiFangTrigger:marshal(os)
  os:marshalInt32(self.cfgId)
end
function SSyncGangMiFangTrigger:unmarshal(os)
  self.cfgId = os:unmarshalInt32()
end
function SSyncGangMiFangTrigger:sizepolicy(size)
  return size <= 65535
end
return SSyncGangMiFangTrigger
