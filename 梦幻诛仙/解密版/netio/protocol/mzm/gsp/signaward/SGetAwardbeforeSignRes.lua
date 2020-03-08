local SGetAwardbeforeSignRes = class("SGetAwardbeforeSignRes")
SGetAwardbeforeSignRes.TYPEID = 12593422
function SGetAwardbeforeSignRes:ctor(day)
  self.id = 12593422
  self.day = day or nil
end
function SGetAwardbeforeSignRes:marshal(os)
  os:marshalInt32(self.day)
end
function SGetAwardbeforeSignRes:unmarshal(os)
  self.day = os:unmarshalInt32()
end
function SGetAwardbeforeSignRes:sizepolicy(size)
  return size <= 65535
end
return SGetAwardbeforeSignRes
