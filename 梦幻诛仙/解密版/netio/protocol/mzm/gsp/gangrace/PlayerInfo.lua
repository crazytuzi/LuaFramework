local OctetsStream = require("netio.OctetsStream")
local PlayerInfo = class("PlayerInfo")
function PlayerInfo:ctor(playerIdx, gender, menpai, avatarId, avatarFrameId, name)
  self.playerIdx = playerIdx or nil
  self.gender = gender or nil
  self.menpai = menpai or nil
  self.avatarId = avatarId or nil
  self.avatarFrameId = avatarFrameId or nil
  self.name = name or nil
end
function PlayerInfo:marshal(os)
  os:marshalInt32(self.playerIdx)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.menpai)
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.avatarFrameId)
  os:marshalString(self.name)
end
function PlayerInfo:unmarshal(os)
  self.playerIdx = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.menpai = os:unmarshalInt32()
  self.avatarId = os:unmarshalInt32()
  self.avatarFrameId = os:unmarshalInt32()
  self.name = os:unmarshalString()
end
return PlayerInfo
