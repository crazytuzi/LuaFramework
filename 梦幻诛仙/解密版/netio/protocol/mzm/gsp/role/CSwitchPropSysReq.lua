local CSwitchPropSysReq = class("CSwitchPropSysReq")
CSwitchPropSysReq.TYPEID = 12586001
CSwitchPropSysReq.PROP_SYS_1 = 0
CSwitchPropSysReq.PROP_SYS_2 = 1
CSwitchPropSysReq.PROP_SYS_3 = 2
function CSwitchPropSysReq:ctor(propSys, silverMoney)
  self.id = 12586001
  self.propSys = propSys or nil
  self.silverMoney = silverMoney or nil
end
function CSwitchPropSysReq:marshal(os)
  os:marshalInt32(self.propSys)
  os:marshalInt64(self.silverMoney)
end
function CSwitchPropSysReq:unmarshal(os)
  self.propSys = os:unmarshalInt32()
  self.silverMoney = os:unmarshalInt64()
end
function CSwitchPropSysReq:sizepolicy(size)
  return size <= 65535
end
return CSwitchPropSysReq
