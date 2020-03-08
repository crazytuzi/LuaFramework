local SSwitchPropSysRes = class("SSwitchPropSysRes")
SSwitchPropSysRes.TYPEID = 12586011
SSwitchPropSysRes.PROP_SYS_1 = 0
SSwitchPropSysRes.PROP_SYS_2 = 1
SSwitchPropSysRes.PROP_SYS_3 = 2
function SSwitchPropSysRes:ctor(propSys)
  self.id = 12586011
  self.propSys = propSys or nil
end
function SSwitchPropSysRes:marshal(os)
  os:marshalInt32(self.propSys)
end
function SSwitchPropSysRes:unmarshal(os)
  self.propSys = os:unmarshalInt32()
end
function SSwitchPropSysRes:sizepolicy(size)
  return size <= 65535
end
return SSwitchPropSysRes
