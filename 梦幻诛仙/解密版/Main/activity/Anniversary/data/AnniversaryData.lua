local Lplus = require("Lplus")
local AnniversaryData = Lplus.Class("AnniversaryData")
local def = AnniversaryData.define
local _instance
def.field("number")._occupation = 0
def.field("userdata")._startTime = nil
def.field("table")._roles = nil
def.field("table")._question = nil
def.field("table")._answers = nil
def.static("=>", AnniversaryData).Instance = function()
  if _instance == nil then
    _instance = AnniversaryData()
  end
  return _instance
end
def.method().Init = function(self)
  self:Reset()
end
def.method().Reset = function(self)
  self:ClearParadeData()
  self:ClearMakeUpData()
end
def.method().ClearParadeData = function(self)
  self._occupation = 0
  self._startTime = nil
  self._roles = nil
end
def.method().ClearMakeUpData = function(self)
  self._question = nil
  self._answers = nil
end
def.method("number").SetOccupation = function(self, occp)
  self._occupation = occp
end
def.method("=>", "number").GetOccupation = function(self)
  return self._occupation
end
def.method("table").SetRoles = function(self, roles)
  self._roles = roles
end
def.method("=>", "table").GetRoles = function(self)
  return self._roles
end
def.method("userdata").SetStartTime = function(self, time)
  self._startTime = time
end
def.method("=>", "userdata").GetStartTime = function(self)
  return self._startTime
end
def.method("table").SetQuestion = function(self, question)
  self._question = question
end
def.method("=>", "table").GetQuestion = function(self)
  return self._question
end
def.method("number").SetAnswer = function(self, answer)
  if self._answers == nil then
    self._answers = {}
  end
  if self._question == nil then
    return
  end
  self._answers[self._question.curTurn] = answer
end
def.method("number", "=>", "number").GetAnswer = function(self, round)
  if self._answers == nil then
    return -1
  end
  return self._answers[round] or -1
end
def.method("table").SetAnswers = function(self, answers)
  self._answers = answers
end
AnniversaryData.Commit()
return AnniversaryData
