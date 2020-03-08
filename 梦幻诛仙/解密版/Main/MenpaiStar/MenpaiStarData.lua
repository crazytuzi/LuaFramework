local Lplus = require("Lplus")
local MenpaiStarData = Lplus.Class("MenpaiStarData")
local def = MenpaiStarData.define
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local MenpaiStarModule = Lplus.ForwardDeclare("MenpaiStarModule")
def.field("boolean").isCandidate = false
def.field("number").candidataChallengeTimes = 0
def.field("boolean").isVoter = false
def.field("number").voterChallengeTimes = 0
def.field("number").leftTimes = 0
def.field("table").worldCanvass = nil
def.field("table").gangCanvass = nil
def.field("table").commonDataCallbacks = nil
def.field("boolean").isCommonDataReady = false
def.method().Clear = function(self)
  self.isCommonDataReady = false
  self.worldCanvass = nil
  self.gangCanvass = nil
  self.commonDataCallbacks = nil
end
def.method("number", "number", "=>", "boolean").IsATimeNewDay = function(self, aTime, bTime)
  if aTime <= bTime then
    return false
  end
  local aTimeTbl = AbsoluteTimer.GetServerTimeTable(aTime)
  local bTimeTbl = AbsoluteTimer.GetServerTimeTable(bTime)
  if aTimeTbl.year == bTimeTbl.year and aTimeTbl.yday > bTimeTbl.yday then
    return true
  elseif aTimeTbl.year > bTimeTbl.year then
    return true
  else
    return false
  end
end
def.method("table").SetCommonData = function(self, p)
  self.isCandidate = p.campaign > 0
  local curTime = GetServerTime()
  if self:IsATimeNewDay(curTime, p.last_campaign_time) then
    self.candidataChallengeTimes = 0
  else
    self.candidataChallengeTimes = p.today_campaign_num
  end
  self.isVoter = 0 < p.vote
  if self:IsATimeNewDay(curTime, p.last_vote_time) then
    self.voterChallengeTimes = 0
  else
    self.voterChallengeTimes = p.today_vote_num
  end
  self.leftTimes = p.vote_num
  self.worldCanvass = {}
  for k, v in pairs(p.world_canvass) do
    self.worldCanvass[k:tostring()] = v
  end
  self.gangCanvass = {}
  for k, v in pairs(p.gang_canvass) do
    self.gangCanvass[k:tostring()] = v
  end
  if self.commonDataCallbacks then
    for _, v in ipairs(self.commonDataCallbacks) do
      warn("Do commonDataCallbacks")
      v()
    end
  end
  self.commonDataCallbacks = nil
  self.isCommonDataReady = true
end
def.method("function").RequestCommonData = function(self, cb)
  if self.commonDataCallbacks == nil then
    self.commonDataCallbacks = {}
  end
  table.insert(self.commonDataCallbacks, cb)
  MenpaiStarModule.Instance():RequestMenpaiStarInfo()
end
def.method("function").IsCandidate = function(self, cb)
  if self.isCommonDataReady then
    cb(self.isCandidate)
  else
    self:RequestCommonData(function()
      cb(self.isCandidate)
    end)
  end
end
def.method("function").GetCandidateChallengeTimes = function(self, cb)
  if self.isCommonDataReady then
    cb(self.candidataChallengeTimes)
  else
    self:RequestCommonData(function()
      cb(self.candidataChallengeTimes)
    end)
  end
end
def.method("function").IsVoter = function(self, cb)
  if self.isCommonDataReady then
    cb(self.isVoter)
  else
    self:RequestCommonData(function()
      cb(self.isVoter)
    end)
  end
end
def.method("function").GetVoterChallengeTimes = function(self, cb)
  if self.isCommonDataReady then
    cb(self.voterChallengeTimes)
  else
    self:RequestCommonData(function()
      cb(self.voterChallengeTimes)
    end)
  end
end
def.method("function").GetVoteTimes = function(self, cb)
  if self.isCommonDataReady then
    if self.isVoter then
      cb(self.leftTimes)
    else
      cb(-1)
    end
  else
    self:RequestCommonData(function()
      if self.isVoter then
        cb(self.leftTimes)
      else
        cb(-1)
      end
    end)
  end
end
def.method("userdata", "function").GetWorldCanvass = function(self, roleId, cb)
  if self.isCommonDataReady then
    if self.worldCanvass then
      cb(self.worldCanvass[roleId:tostring()])
    end
  else
    self:RequestCommonData(function()
      if self.worldCanvass then
        cb(self.worldCanvass[roleId:tostring()])
      end
    end)
  end
end
def.method("userdata", "function").GetGangCanvass = function(self, roleId, cb)
  if self.isCommonDataReady then
    if self.gangCanvass then
      cb(self.gangCanvass[roleId:tostring()])
    end
  else
    self:RequestCommonData(function()
      if self.gangCanvass then
        cb(self.gangCanvass[roleId:tostring()])
      end
    end)
  end
end
def.method("boolean").SetCandidate = function(self, isCandidate)
  if self.isCommonDataReady then
    self.isCandidate = isCandidate
  end
end
def.method("number").SetCandidateChallengeTimes = function(self, times)
  if self.isCommonDataReady then
    self.candidataChallengeTimes = times
  end
end
def.method().AddCandidateChallengeTimes = function(self)
  if self.isCommonDataReady then
    self.candidataChallengeTimes = self.candidataChallengeTimes + 1
  end
end
def.method("boolean").SetVoter = function(self, isVoter)
  if self.isCommonDataReady then
    self.isVoter = isVoter
  end
end
def.method("number").SetVoterChallengeTimes = function(self, times)
  if self.isCommonDataReady then
    self.voterChallengeTimes = times
  end
end
def.method().AddVoterChallengeTimes = function(self)
  if self.isCommonDataReady then
    self.voterChallengeTimes = self.voterChallengeTimes + 1
  end
end
def.method("number").SetVoteTimes = function(self, times)
  if self.isCommonDataReady then
    self.leftTimes = times
  end
end
def.method().AddVoteTimes = function(self)
  if self.isCommonDataReady then
    self.leftTimes = self.leftTimes + 1
  end
end
def.method("userdata", "number").SetWorldCanvass = function(self, roleId, time)
  if self.isCommonDataReady then
    if self.worldCanvass == nil then
      self.worldCanvass = {}
    end
    self.worldCanvass[roleId:tostring()] = time
  end
end
def.method("userdata", "number").SetGangCanvass = function(self, roleId, time)
  if self.isCommonDataReady then
    if self.gangCanvass == nil then
      self.gangCanvass = {}
    end
    self.gangCanvass[roleId:tostring()] = time
  end
end
MenpaiStarData.Commit()
return MenpaiStarData
