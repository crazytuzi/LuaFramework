local SConstellationRes = class("SConstellationRes")
SConstellationRes.TYPEID = 12612104
function SConstellationRes:ctor(constellation, set_times, sum_exp)
  self.id = 12612104
  self.constellation = constellation or nil
  self.set_times = set_times or nil
  self.sum_exp = sum_exp or nil
end
function SConstellationRes:marshal(os)
  os:marshalInt32(self.constellation)
  os:marshalInt32(self.set_times)
  os:marshalInt32(self.sum_exp)
end
function SConstellationRes:unmarshal(os)
  self.constellation = os:unmarshalInt32()
  self.set_times = os:unmarshalInt32()
  self.sum_exp = os:unmarshalInt32()
end
function SConstellationRes:sizepolicy(size)
  return size <= 65535
end
return SConstellationRes
