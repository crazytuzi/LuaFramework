local OctetsStream = require("netio.OctetsStream")
local PopularityRankData = class("PopularityRankData")
function PopularityRankData:ctor(rank, roleId, name, popularity_value, occupation_id)
  self.rank = rank or nil
  self.roleId = roleId or nil
  self.name = name or nil
  self.popularity_value = popularity_value or nil
  self.occupation_id = occupation_id or nil
end
function PopularityRankData:marshal(os)
  os:marshalInt32(self.rank)
  os:marshalInt64(self.roleId)
  os:marshalOctets(self.name)
  os:marshalInt32(self.popularity_value)
  os:marshalInt32(self.occupation_id)
end
function PopularityRankData:unmarshal(os)
  self.rank = os:unmarshalInt32()
  self.roleId = os:unmarshalInt64()
  self.name = os:unmarshalOctets()
  self.popularity_value = os:unmarshalInt32()
  self.occupation_id = os:unmarshalInt32()
end
return PopularityRankData
