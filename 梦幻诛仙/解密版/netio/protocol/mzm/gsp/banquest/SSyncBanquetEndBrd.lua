local SSyncBanquetEndBrd = class("SSyncBanquetEndBrd")
SSyncBanquetEndBrd.TYPEID = 12605961
function SSyncBanquetEndBrd:ctor(masterId)
  self.id = 12605961
  self.masterId = masterId or nil
end
function SSyncBanquetEndBrd:marshal(os)
  os:marshalInt64(self.masterId)
end
function SSyncBanquetEndBrd:unmarshal(os)
  self.masterId = os:unmarshalInt64()
end
function SSyncBanquetEndBrd:sizepolicy(size)
  return size <= 65535
end
return SSyncBanquetEndBrd
