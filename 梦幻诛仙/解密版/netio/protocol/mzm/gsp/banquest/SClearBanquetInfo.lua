local SClearBanquetInfo = class("SClearBanquetInfo")
SClearBanquetInfo.TYPEID = 12605962
function SClearBanquetInfo:ctor(masterId)
  self.id = 12605962
  self.masterId = masterId or nil
end
function SClearBanquetInfo:marshal(os)
  os:marshalInt64(self.masterId)
end
function SClearBanquetInfo:unmarshal(os)
  self.masterId = os:unmarshalInt64()
end
function SClearBanquetInfo:sizepolicy(size)
  return size <= 65535
end
return SClearBanquetInfo
