local MODULE_NAME = (...)
local Lplus = require("Lplus")
local GangDungeonPlayerData = Lplus.Class(MODULE_NAME)
local def = GangDungeonPlayerData.define
local instance
def.static("=>", GangDungeonPlayerData).Instance = function()
  if instance == nil then
    instance = GangDungeonPlayerData()
    instance:Init()
  end
  return instance
end
def.field("number").m_participateTimes = 0
def.field("number").m_lastParticipateTimestamp = 0
def.field("userdata").m_lastParticipateGangId = nil
def.method().Init = function(self)
end
def.method("=>", "number").GetParticipateTimes = function(self)
  return self.m_participateTimes
end
def.method("=>", "number").GetLastParticipateTimestamp = function(self)
  return self.m_lastParticipateTimestamp
end
def.method("=>", "userdata").GetLastParticipateGangId = function(self)
  return self.m_lastParticipateGangId
end
def.method("number").SetParticipateTimes = function(self, participateTimes)
  self.m_participateTimes = participateTimes
end
def.method("number").SetLastParticipateTimestamp = function(self, lastParticipateTimestamp)
  self.m_lastParticipateTimestamp = lastParticipateTimestamp
end
def.method("userdata").SetLastParticipateGangId = function(self, lastParticipateGangId)
  self.m_lastParticipateGangId = lastParticipateGangId
end
def.method().Clear = function(self)
  self.m_participateTimes = 0
  self.m_lastParticipateTimestamp = 0
  self.m_lastParticipateGangId = nil
end
return GangDungeonPlayerData.Commit()
