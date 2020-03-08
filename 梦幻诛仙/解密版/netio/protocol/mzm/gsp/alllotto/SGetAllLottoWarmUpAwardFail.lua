local SGetAllLottoWarmUpAwardFail = class("SGetAllLottoWarmUpAwardFail")
SGetAllLottoWarmUpAwardFail.TYPEID = 12626952
function SGetAllLottoWarmUpAwardFail:ctor(res)
  self.id = 12626952
  self.res = res or nil
end
function SGetAllLottoWarmUpAwardFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetAllLottoWarmUpAwardFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetAllLottoWarmUpAwardFail:sizepolicy(size)
  return size <= 65535
end
return SGetAllLottoWarmUpAwardFail
