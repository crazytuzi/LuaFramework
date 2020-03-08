local SSyncBreedInfo = class("SSyncBreedInfo")
SSyncBreedInfo.TYPEID = 12609314
SSyncBreedInfo.COUPLE_BREED = 0
SSyncBreedInfo.SINGLE_BREED = 1
SSyncBreedInfo.NO_BREED = 2
function SSyncBreedInfo:ctor(breed_state, score, step, remain_give_birth_seconds)
  self.id = 12609314
  self.breed_state = breed_state or nil
  self.score = score or nil
  self.step = step or nil
  self.remain_give_birth_seconds = remain_give_birth_seconds or nil
end
function SSyncBreedInfo:marshal(os)
  os:marshalInt32(self.breed_state)
  os:marshalInt32(self.score)
  os:marshalInt32(self.step)
  os:marshalInt64(self.remain_give_birth_seconds)
end
function SSyncBreedInfo:unmarshal(os)
  self.breed_state = os:unmarshalInt32()
  self.score = os:unmarshalInt32()
  self.step = os:unmarshalInt32()
  self.remain_give_birth_seconds = os:unmarshalInt64()
end
function SSyncBreedInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncBreedInfo
