local OctetsStream = require("netio.OctetsStream")
local Score = class("Score")
function Score:ctor(roleid, name, score, win_times)
  self.roleid = roleid or nil
  self.name = name or nil
  self.score = score or nil
  self.win_times = win_times or nil
end
function Score:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.name)
  os:marshalInt32(self.score)
  os:marshalInt32(self.win_times)
end
function Score:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.score = os:unmarshalInt32()
  self.win_times = os:unmarshalInt32()
end
return Score
