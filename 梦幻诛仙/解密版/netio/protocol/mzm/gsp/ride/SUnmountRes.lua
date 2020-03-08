local SUnmountRes = class("SUnmountRes")
SUnmountRes.TYPEID = 797954
function SUnmountRes:ctor(rideCfgId)
  self.id = 797954
  self.rideCfgId = rideCfgId or nil
end
function SUnmountRes:marshal(os)
  os:marshalInt32(self.rideCfgId)
end
function SUnmountRes:unmarshal(os)
  self.rideCfgId = os:unmarshalInt32()
end
function SUnmountRes:sizepolicy(size)
  return size <= 65535
end
return SUnmountRes
