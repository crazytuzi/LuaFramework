local CVote = class("CVote")
CVote.TYPEID = 12612374
function CVote:ctor(target_roleid, vote_num)
  self.id = 12612374
  self.target_roleid = target_roleid or nil
  self.vote_num = vote_num or nil
end
function CVote:marshal(os)
  os:marshalInt64(self.target_roleid)
  os:marshalInt32(self.vote_num)
end
function CVote:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.vote_num = os:unmarshalInt32()
end
function CVote:sizepolicy(size)
  return size <= 65535
end
return CVote
