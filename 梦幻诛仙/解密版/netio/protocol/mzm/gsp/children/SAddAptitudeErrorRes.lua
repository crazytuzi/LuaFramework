local SAddAptitudeErrorRes = class("SAddAptitudeErrorRes")
SAddAptitudeErrorRes.TYPEID = 12609374
SAddAptitudeErrorRes.ERROR_APTITUDE_FULL = 1
SAddAptitudeErrorRes.ERROR_ITEM_USE_TO_MAX = 2
SAddAptitudeErrorRes.ERROR_DO_NOT_HAS_OCCUPATION = 3
SAddAptitudeErrorRes.ERROR_DO_NOT_HAS_ITEM = 4
function SAddAptitudeErrorRes:ctor(ret)
  self.id = 12609374
  self.ret = ret or nil
end
function SAddAptitudeErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SAddAptitudeErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SAddAptitudeErrorRes:sizepolicy(size)
  return size <= 65535
end
return SAddAptitudeErrorRes
