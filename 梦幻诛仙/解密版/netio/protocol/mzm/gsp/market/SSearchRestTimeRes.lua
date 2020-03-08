local SSearchRestTimeRes = class("SSearchRestTimeRes")
SSearchRestTimeRes.TYPEID = 12601431
function SSearchRestTimeRes:ctor(restTime)
  self.id = 12601431
  self.restTime = restTime or nil
end
function SSearchRestTimeRes:marshal(os)
  os:marshalInt32(self.restTime)
end
function SSearchRestTimeRes:unmarshal(os)
  self.restTime = os:unmarshalInt32()
end
function SSearchRestTimeRes:sizepolicy(size)
  return size <= 65535
end
return SSearchRestTimeRes
