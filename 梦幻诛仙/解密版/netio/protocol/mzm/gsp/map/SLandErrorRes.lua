local SLandErrorRes = class("SLandErrorRes")
SLandErrorRes.TYPEID = 12590926
SLandErrorRes.ERROR_POSITION = 1
SLandErrorRes.ERROR_NOT_LEADER = 2
SLandErrorRes.ERROR_STATUS = 3
SLandErrorRes.ERROR_LAND_POSTIION_TOO_FAR = 4
function SLandErrorRes:ctor(ret)
  self.id = 12590926
  self.ret = ret or nil
end
function SLandErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SLandErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SLandErrorRes:sizepolicy(size)
  return size <= 65535
end
return SLandErrorRes
