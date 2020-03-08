local SSwitchOccupationRes = class("SSwitchOccupationRes")
SSwitchOccupationRes.TYPEID = 12606982
function SSwitchOccupationRes:ctor(new_occupation)
  self.id = 12606982
  self.new_occupation = new_occupation or nil
end
function SSwitchOccupationRes:marshal(os)
  os:marshalInt32(self.new_occupation)
end
function SSwitchOccupationRes:unmarshal(os)
  self.new_occupation = os:unmarshalInt32()
end
function SSwitchOccupationRes:sizepolicy(size)
  return size <= 65535
end
return SSwitchOccupationRes
