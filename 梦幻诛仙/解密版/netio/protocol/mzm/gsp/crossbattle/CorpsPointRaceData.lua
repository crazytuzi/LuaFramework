local OctetsStream = require("netio.OctetsStream")
local CorpsPointRaceData = class("CorpsPointRaceData")
function CorpsPointRaceData:ctor(win, lose, point, update_time)
  self.win = win or nil
  self.lose = lose or nil
  self.point = point or nil
  self.update_time = update_time or nil
end
function CorpsPointRaceData:marshal(os)
  os:marshalInt32(self.win)
  os:marshalInt32(self.lose)
  os:marshalInt32(self.point)
  os:marshalInt64(self.update_time)
end
function CorpsPointRaceData:unmarshal(os)
  self.win = os:unmarshalInt32()
  self.lose = os:unmarshalInt32()
  self.point = os:unmarshalInt32()
  self.update_time = os:unmarshalInt64()
end
return CorpsPointRaceData
