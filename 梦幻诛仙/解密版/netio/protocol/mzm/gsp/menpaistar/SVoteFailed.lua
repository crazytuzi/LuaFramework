local SVoteFailed = class("SVoteFailed")
SVoteFailed.TYPEID = 12612377
SVoteFailed.ERROR_VOTE_NUM_NOT_ENOUGH = -1
SVoteFailed.ERROR_VOTE_NUM_INCONSISTENT = -2
SVoteFailed.ERROR_SWITH_OCCUPATION = -3
SVoteFailed.ERROR_ACTIVITY_IN_AWARD = -4
function SVoteFailed:ctor(target_roleid, vote_num, retcode)
  self.id = 12612377
  self.target_roleid = target_roleid or nil
  self.vote_num = vote_num or nil
  self.retcode = retcode or nil
end
function SVoteFailed:marshal(os)
  os:marshalInt64(self.target_roleid)
  os:marshalInt32(self.vote_num)
  os:marshalInt32(self.retcode)
end
function SVoteFailed:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.vote_num = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SVoteFailed:sizepolicy(size)
  return size <= 65535
end
return SVoteFailed
