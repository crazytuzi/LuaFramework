local OctetsStream = require("netio.OctetsStream")
local CrossBattleBetRankData = class("CrossBattleBetRankData")
function CrossBattleBetRankData:ctor(rank, roleid, name, occupation, profit, timestamp)
  self.rank = rank or nil
  self.roleid = roleid or nil
  self.name = name or nil
  self.occupation = occupation or nil
  self.profit = profit or nil
  self.timestamp = timestamp or nil
end
function CrossBattleBetRankData:marshal(os)
  os:marshalInt32(self.rank)
  os:marshalInt64(self.roleid)
  os:marshalOctets(self.name)
  os:marshalInt32(self.occupation)
  os:marshalInt64(self.profit)
  os:marshalInt32(self.timestamp)
end
function CrossBattleBetRankData:unmarshal(os)
  self.rank = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
  self.name = os:unmarshalOctets()
  self.occupation = os:unmarshalInt32()
  self.profit = os:unmarshalInt64()
  self.timestamp = os:unmarshalInt32()
end
return CrossBattleBetRankData
