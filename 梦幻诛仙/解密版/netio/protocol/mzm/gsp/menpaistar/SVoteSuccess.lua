local SVoteSuccess = class("SVoteSuccess")
SVoteSuccess.TYPEID = 12612370
function SVoteSuccess:ctor(target_roleid, vote_num, gold, point)
  self.id = 12612370
  self.target_roleid = target_roleid or nil
  self.vote_num = vote_num or nil
  self.gold = gold or nil
  self.point = point or nil
end
function SVoteSuccess:marshal(os)
  os:marshalInt64(self.target_roleid)
  os:marshalInt32(self.vote_num)
  os:marshalInt32(self.gold)
  os:marshalInt32(self.point)
end
function SVoteSuccess:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.vote_num = os:unmarshalInt32()
  self.gold = os:unmarshalInt32()
  self.point = os:unmarshalInt32()
end
function SVoteSuccess:sizepolicy(size)
  return size <= 65535
end
return SVoteSuccess
