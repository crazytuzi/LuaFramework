local Lplus = require("Lplus")
local WantedPlayer = Lplus.Class("WantedPlayer")
local def = WantedPlayer.define
def.field("userdata").playerId = nil
def.field("number").avatarId = 0
def.field("number").avatarFrameId = 0
def.field("string").name = ""
def.field("number").sex = 0
def.field("number").occupation = 0
def.field("number").level = 0
def.field("userdata").endTime = nil
def.method("table").RawSet = function(self, p)
  self.playerId = p.roleId
  self.avatarId = p.avatarId
  self.name = _G.GetStringFromOcts(p.name)
  self.sex = p.gender
  self.occupation = p.menpai
  self.level = p.level
  self.endTime = p.endTimeStamp
  self.avatarFrameId = p.avatarFrameId
end
def.method("=>", "userdata").GetPlayerId = function(self)
  return self.playerId
end
def.method("=>", "number").GetAvatarId = function(self)
  return self.avatarId
end
def.method("=>", "number").GetAvatarFrameId = function(self)
  return self.avatarFrameId
end
def.method("=>", "string").GetName = function(self)
  return self.name
end
def.method("=>", "number").GetSex = function(self)
  return self.sex
end
def.method("=>", "number").GetOccupation = function(self)
  return self.occupation
end
def.method("=>", "number").GetLevel = function(self)
  return self.level
end
def.method("=>", "boolean").IsOutOfTime = function(self)
  if self.endTime == nil then
    return true
  end
  local serverTime = _G.GetServerTime()
  return Int64.gt(serverTime * 1000, self.endTime)
end
WantedPlayer.Commit()
return WantedPlayer
