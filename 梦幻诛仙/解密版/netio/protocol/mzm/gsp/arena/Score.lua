local OctetsStream = require("netio.OctetsStream")
local Score = class("Score")
function Score:ctor(roleid, name, level, menpai, score)
  self.roleid = roleid or nil
  self.name = name or nil
  self.level = level or nil
  self.menpai = menpai or nil
  self.score = score or nil
end
function Score:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.name)
  os:marshalInt32(self.level)
  os:marshalInt32(self.menpai)
  os:marshalInt32(self.score)
end
function Score:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.level = os:unmarshalInt32()
  self.menpai = os:unmarshalInt32()
  self.score = os:unmarshalInt32()
end
return Score
