local OctetsStream = require("netio.OctetsStream")
local PlayerScoreInfo = class("PlayerScoreInfo")
function PlayerScoreInfo:ctor(score, kill, death, in_game_scene, update_time)
  self.score = score or nil
  self.kill = kill or nil
  self.death = death or nil
  self.in_game_scene = in_game_scene or nil
  self.update_time = update_time or nil
end
function PlayerScoreInfo:marshal(os)
  os:marshalInt32(self.score)
  os:marshalInt32(self.kill)
  os:marshalInt32(self.death)
  os:marshalInt32(self.in_game_scene)
  os:marshalInt32(self.update_time)
end
function PlayerScoreInfo:unmarshal(os)
  self.score = os:unmarshalInt32()
  self.kill = os:unmarshalInt32()
  self.death = os:unmarshalInt32()
  self.in_game_scene = os:unmarshalInt32()
  self.update_time = os:unmarshalInt32()
end
return PlayerScoreInfo
