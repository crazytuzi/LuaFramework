local SSynInstanceLeaveTimer = class("SSynInstanceLeaveTimer")
SSynInstanceLeaveTimer.TYPEID = 12591383
function SSynInstanceLeaveTimer:ctor(instanceCfgid)
  self.id = 12591383
  self.instanceCfgid = instanceCfgid or nil
end
function SSynInstanceLeaveTimer:marshal(os)
  os:marshalInt32(self.instanceCfgid)
end
function SSynInstanceLeaveTimer:unmarshal(os)
  self.instanceCfgid = os:unmarshalInt32()
end
function SSynInstanceLeaveTimer:sizepolicy(size)
  return size <= 65535
end
return SSynInstanceLeaveTimer
