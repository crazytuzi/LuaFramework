local OctetsStream = require("netio.OctetsStream")
local CrossFieldRankData = class("CrossFieldRankData")
function CrossFieldRankData:ctor(rank, roleid, name, occupation, star_num, timestamp)
  self.rank = rank or nil
  self.roleid = roleid or nil
  self.name = name or nil
  self.occupation = occupation or nil
  self.star_num = star_num or nil
  self.timestamp = timestamp or nil
end
function CrossFieldRankData:marshal(os)
  os:marshalInt32(self.rank)
  os:marshalInt64(self.roleid)
  os:marshalOctets(self.name)
  os:marshalInt32(self.occupation)
  os:marshalInt32(self.star_num)
  os:marshalInt32(self.timestamp)
end
function CrossFieldRankData:unmarshal(os)
  self.rank = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
  self.name = os:unmarshalOctets()
  self.occupation = os:unmarshalInt32()
  self.star_num = os:unmarshalInt32()
  self.timestamp = os:unmarshalInt32()
end
return CrossFieldRankData
