local SActiveNewOccupationRes = class("SActiveNewOccupationRes")
SActiveNewOccupationRes.TYPEID = 12606981
function SActiveNewOccupationRes:ctor(new_occupation)
  self.id = 12606981
  self.new_occupation = new_occupation or nil
end
function SActiveNewOccupationRes:marshal(os)
  os:marshalInt32(self.new_occupation)
end
function SActiveNewOccupationRes:unmarshal(os)
  self.new_occupation = os:unmarshalInt32()
end
function SActiveNewOccupationRes:sizepolicy(size)
  return size <= 65535
end
return SActiveNewOccupationRes
