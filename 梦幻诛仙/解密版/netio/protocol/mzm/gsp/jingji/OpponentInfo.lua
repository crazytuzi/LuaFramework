local OctetsStream = require("netio.OctetsStream")
local OpponentInfo = class("OpponentInfo")
OpponentInfo.TYPE_ROLE = 1
OpponentInfo.TYPE_ROBOT = 2
OpponentInfo.TYPE_TOP_ROLE = 3
function OpponentInfo:ctor(opponenttype, roleid, sex, level, phase, occupation, rank)
  self.opponenttype = opponenttype or nil
  self.roleid = roleid or nil
  self.sex = sex or nil
  self.level = level or nil
  self.phase = phase or nil
  self.occupation = occupation or nil
  self.rank = rank or nil
end
function OpponentInfo:marshal(os)
  os:marshalInt32(self.opponenttype)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.sex)
  os:marshalInt32(self.level)
  os:marshalInt32(self.phase)
  os:marshalInt32(self.occupation)
  os:marshalInt32(self.rank)
end
function OpponentInfo:unmarshal(os)
  self.opponenttype = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
  self.sex = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.phase = os:unmarshalInt32()
  self.occupation = os:unmarshalInt32()
  self.rank = os:unmarshalInt32()
end
return OpponentInfo
