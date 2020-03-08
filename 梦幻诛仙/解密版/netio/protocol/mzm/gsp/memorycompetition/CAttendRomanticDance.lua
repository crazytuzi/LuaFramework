local CAttendRomanticDance = class("CAttendRomanticDance")
CAttendRomanticDance.TYPEID = 12613125
function CAttendRomanticDance:ctor(hard_rank)
  self.id = 12613125
  self.hard_rank = hard_rank or nil
end
function CAttendRomanticDance:marshal(os)
  os:marshalInt32(self.hard_rank)
end
function CAttendRomanticDance:unmarshal(os)
  self.hard_rank = os:unmarshalInt32()
end
function CAttendRomanticDance:sizepolicy(size)
  return size <= 65535
end
return CAttendRomanticDance
