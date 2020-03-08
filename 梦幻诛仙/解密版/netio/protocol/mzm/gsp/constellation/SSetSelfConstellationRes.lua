local SSetSelfConstellationRes = class("SSetSelfConstellationRes")
SSetSelfConstellationRes.TYPEID = 12612102
function SSetSelfConstellationRes:ctor(constellation, set_times)
  self.id = 12612102
  self.constellation = constellation or nil
  self.set_times = set_times or nil
end
function SSetSelfConstellationRes:marshal(os)
  os:marshalInt32(self.constellation)
  os:marshalInt32(self.set_times)
end
function SSetSelfConstellationRes:unmarshal(os)
  self.constellation = os:unmarshalInt32()
  self.set_times = os:unmarshalInt32()
end
function SSetSelfConstellationRes:sizepolicy(size)
  return size <= 65535
end
return SSetSelfConstellationRes
