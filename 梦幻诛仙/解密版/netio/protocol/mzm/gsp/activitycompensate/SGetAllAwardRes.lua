local SGetAllAwardRes = class("SGetAllAwardRes")
SGetAllAwardRes.TYPEID = 12627462
function SGetAllAwardRes:ctor(get_type)
  self.id = 12627462
  self.get_type = get_type or nil
end
function SGetAllAwardRes:marshal(os)
  os:marshalInt32(self.get_type)
end
function SGetAllAwardRes:unmarshal(os)
  self.get_type = os:unmarshalInt32()
end
function SGetAllAwardRes:sizepolicy(size)
  return size <= 65535
end
return SGetAllAwardRes
