local SCourtYardLevelUpRes = class("SCourtYardLevelUpRes")
SCourtYardLevelUpRes.TYPEID = 12605512
function SCourtYardLevelUpRes:ctor(court_yard_level)
  self.id = 12605512
  self.court_yard_level = court_yard_level or nil
end
function SCourtYardLevelUpRes:marshal(os)
  os:marshalInt32(self.court_yard_level)
end
function SCourtYardLevelUpRes:unmarshal(os)
  self.court_yard_level = os:unmarshalInt32()
end
function SCourtYardLevelUpRes:sizepolicy(size)
  return size <= 65535
end
return SCourtYardLevelUpRes
