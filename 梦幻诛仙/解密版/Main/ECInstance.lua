local Lplus = require("Lplus")
local ElementData = require("Data.ElementData")
local ECGame = Lplus.ForwardDeclare("ECGame")
local instance_end_panel = dofile("Configs/instance_end_panel.lua")
local ECInstance = Lplus.Class("ECInstance")
local def = ECInstance.define
local ARENA_SCENEID = 525
local TOWER_SCENEID = 839
def.field("number").m_showUIInstId = 0
def.field("number").m_curInstanceId = 0
def.field("boolean").m_isOnceAgain = false
def.field("table").InstancePassInfo = function()
  return {}
end
def.field("table").InstanceTotalInfo = function()
  return {}
end
def.field("table").HeroTrialInfo = function()
  local a = {}
  a.free_refresh_times = 0
  a.pay_refresh_times = 0
  a.hero = 0
  return a
end
def.field("number").m_KickoutTimer = 0
def.field("number").m_CountdownTimer = 0
def.final("=>", ECInstance).new = function()
  local obj = ECInstance()
  return obj
end
def.method().OnEnterInstance = function(self)
end
def.method().OnLeaveInstance = function(self)
  self:ClearTimers()
end
def.method().OnShowInstanceUI = function(self)
end
def.method("boolean").SetOnceAgain = function(self, flag)
  self.m_isOnceAgain = flag
end
def.method().ClearTimers = function(self)
end
def.method("number").OnCmdKickout = function(self, kickoutseconds)
end
def.method("table").OnCmdCountdown = function(self, cmd)
end
def.method("number", "=>", "number", "number", "number").GetChallengeInfo = function(self, tid)
end
ECInstance.Commit()
return ECInstance
