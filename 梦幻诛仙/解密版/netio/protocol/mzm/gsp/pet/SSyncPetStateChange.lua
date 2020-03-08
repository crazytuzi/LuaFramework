local SSyncPetStateChange = class("SSyncPetStateChange")
SSyncPetStateChange.TYPEID = 12590610
SSyncPetStateChange.STATE_FIGHT = 0
SSyncPetStateChange.STATE_SHOW = 1
SSyncPetStateChange.STATE_DELETE = 2
SSyncPetStateChange.STATE_REST = 3
SSyncPetStateChange.STATE_HIDE = 4
function SSyncPetStateChange:ctor(petId, state)
  self.id = 12590610
  self.petId = petId or nil
  self.state = state or nil
end
function SSyncPetStateChange:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.state)
end
function SSyncPetStateChange:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.state = os:unmarshalInt32()
end
function SSyncPetStateChange:sizepolicy(size)
  return size <= 65535
end
return SSyncPetStateChange
