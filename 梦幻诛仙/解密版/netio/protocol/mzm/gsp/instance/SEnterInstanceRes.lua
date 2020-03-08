local SEnterInstanceRes = class("SEnterInstanceRes")
SEnterInstanceRes.TYPEID = 12591366
function SEnterInstanceRes:ctor(instanceType, instanceCfgid)
  self.id = 12591366
  self.instanceType = instanceType or nil
  self.instanceCfgid = instanceCfgid or nil
end
function SEnterInstanceRes:marshal(os)
  os:marshalInt32(self.instanceType)
  os:marshalInt32(self.instanceCfgid)
end
function SEnterInstanceRes:unmarshal(os)
  self.instanceType = os:unmarshalInt32()
  self.instanceCfgid = os:unmarshalInt32()
end
function SEnterInstanceRes:sizepolicy(size)
  return size <= 65535
end
return SEnterInstanceRes
