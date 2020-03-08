local SLeaveInstanceRes = class("SLeaveInstanceRes")
SLeaveInstanceRes.TYPEID = 12591380
function SLeaveInstanceRes:ctor(instanceType, instanceCfgid)
  self.id = 12591380
  self.instanceType = instanceType or nil
  self.instanceCfgid = instanceCfgid or nil
end
function SLeaveInstanceRes:marshal(os)
  os:marshalInt32(self.instanceType)
  os:marshalInt32(self.instanceCfgid)
end
function SLeaveInstanceRes:unmarshal(os)
  self.instanceType = os:unmarshalInt32()
  self.instanceCfgid = os:unmarshalInt32()
end
function SLeaveInstanceRes:sizepolicy(size)
  return size <= 65535
end
return SLeaveInstanceRes
