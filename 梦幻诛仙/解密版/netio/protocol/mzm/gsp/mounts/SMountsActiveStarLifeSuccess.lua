local SMountsActiveStarLifeSuccess = class("SMountsActiveStarLifeSuccess")
SMountsActiveStarLifeSuccess.TYPEID = 12606219
function SMountsActiveStarLifeSuccess:ctor(mounts_id, star_level, star_num)
  self.id = 12606219
  self.mounts_id = mounts_id or nil
  self.star_level = star_level or nil
  self.star_num = star_num or nil
end
function SMountsActiveStarLifeSuccess:marshal(os)
  os:marshalInt64(self.mounts_id)
  os:marshalInt32(self.star_level)
  os:marshalInt32(self.star_num)
end
function SMountsActiveStarLifeSuccess:unmarshal(os)
  self.mounts_id = os:unmarshalInt64()
  self.star_level = os:unmarshalInt32()
  self.star_num = os:unmarshalInt32()
end
function SMountsActiveStarLifeSuccess:sizepolicy(size)
  return size <= 65535
end
return SMountsActiveStarLifeSuccess
