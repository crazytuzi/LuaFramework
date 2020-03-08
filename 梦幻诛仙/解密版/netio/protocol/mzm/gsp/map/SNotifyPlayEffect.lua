local SNotifyPlayEffect = class("SNotifyPlayEffect")
SNotifyPlayEffect.TYPEID = 12590957
function SNotifyPlayEffect:ctor(effect_cfgid)
  self.id = 12590957
  self.effect_cfgid = effect_cfgid or nil
end
function SNotifyPlayEffect:marshal(os)
  os:marshalInt32(self.effect_cfgid)
end
function SNotifyPlayEffect:unmarshal(os)
  self.effect_cfgid = os:unmarshalInt32()
end
function SNotifyPlayEffect:sizepolicy(size)
  return size <= 65535
end
return SNotifyPlayEffect
