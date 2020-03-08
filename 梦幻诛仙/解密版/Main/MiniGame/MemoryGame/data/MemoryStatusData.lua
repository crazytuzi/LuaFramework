local Lplus = require("Lplus")
local MemoryStatusData = Lplus.Class("MemoryStatusData")
local MemoryQuestionData = require("Main.MiniGame.MemoryGame.data.MemoryQuestionData")
local def = MemoryStatusData.define
def.field("number").score = 0
def.field("number").curRound = 0
def.field("number").totalRound = 0
def.field("number").leftSeconds = 0
def.field("number").leftSeekHelpTimes = 0
def.field("table").roleRightAnswerNumMap = nil
def.field("table").roleQuestionMap = nil
def.method("table").RawSet = function(self, data)
  self.score = data.score
  self.curRound = data.now_round_num
  self.totalRound = data.total_round_num
  self.leftSeconds = data.left_seconds
  self.leftSeekHelpTimes = data.left_seek_help_times
  self.roleRightAnswerNumMap = {}
  self.roleQuestionMap = {}
  for k, v in pairs(data.roles_right_num_map or {}) do
    self.roleRightAnswerNumMap[k:tostring()] = v
  end
  for k, v in pairs(data.roles_question_map or {}) do
    local question = MemoryQuestionData()
    question:RawSet(v)
    self.roleQuestionMap[k:tostring()] = question
  end
end
def.method("=>", "number").GetMemoryCompetitionScore = function(self)
  return self.score
end
def.method("=>", "number").GetCurRound = function(self)
  return self.curRound
end
def.method("=>", "number").GetTotalRound = function(self)
  return self.totalRound
end
def.method("=>", "number").GetLeftTime = function(self)
  return self.leftSeconds
end
def.method("=>", "number").GetLeftSeekHelpTimes = function(self)
  return self.leftSeekHelpTimes
end
def.method("number").SetLeftSeekHelpTimes = function(self, leftTimes)
  self.leftSeekHelpTimes = leftTimes
end
def.method("userdata", "=>", "number").GetRightAnswerNumByRoleId = function(self, roleId)
  return self.roleRightAnswerNumMap[roleId:tostring()] or 0
end
def.method("userdata", "=>", MemoryQuestionData).GetQuestionInfoByRoleId = function(self, roleId)
  return self.roleQuestionMap[roleId:tostring()]
end
def.method("table").SetPlayerRoundResult = function(self, result)
  for k, v in pairs(result or {}) do
    if v ~= 0 then
      local curRightNum = self:GetRightAnswerNumByRoleId(k)
      self.roleRightAnswerNumMap[k:tostring()] = curRightNum + 1
    end
  end
end
MemoryStatusData.Commit()
return MemoryStatusData
