local OctetsStream = require("netio.OctetsStream")
local PointRaceData = class("PointRaceData")
function PointRaceData:ctor(cur_win, cur_lose, cur_point, cur_rank, wins, loses, points, rank, victories)
  self.cur_win = cur_win or nil
  self.cur_lose = cur_lose or nil
  self.cur_point = cur_point or nil
  self.cur_rank = cur_rank or nil
  self.wins = wins or nil
  self.loses = loses or nil
  self.points = points or nil
  self.rank = rank or nil
  self.victories = victories or nil
end
function PointRaceData:marshal(os)
  os:marshalInt32(self.cur_win)
  os:marshalInt32(self.cur_lose)
  os:marshalInt32(self.cur_point)
  os:marshalInt32(self.cur_rank)
  os:marshalInt32(self.wins)
  os:marshalInt32(self.loses)
  os:marshalInt32(self.points)
  os:marshalInt32(self.rank)
  os:marshalInt32(self.victories)
end
function PointRaceData:unmarshal(os)
  self.cur_win = os:unmarshalInt32()
  self.cur_lose = os:unmarshalInt32()
  self.cur_point = os:unmarshalInt32()
  self.cur_rank = os:unmarshalInt32()
  self.wins = os:unmarshalInt32()
  self.loses = os:unmarshalInt32()
  self.points = os:unmarshalInt32()
  self.rank = os:unmarshalInt32()
  self.victories = os:unmarshalInt32()
end
return PointRaceData
