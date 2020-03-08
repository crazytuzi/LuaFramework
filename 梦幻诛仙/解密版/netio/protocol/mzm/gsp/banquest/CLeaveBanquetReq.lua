local CLeaveBanquetReq = class("CLeaveBanquetReq")
CLeaveBanquetReq.TYPEID = 12605958
function CLeaveBanquetReq:ctor(masterId)
  self.id = 12605958
  self.masterId = masterId or nil
end
function CLeaveBanquetReq:marshal(os)
  os:marshalInt64(self.masterId)
end
function CLeaveBanquetReq:unmarshal(os)
  self.masterId = os:unmarshalInt64()
end
function CLeaveBanquetReq:sizepolicy(size)
  return size <= 65535
end
return CLeaveBanquetReq
