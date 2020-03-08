local Lplus = require("Lplus")
local MemoryQuestionData = Lplus.Class("MemoryQuestionData")
local def = MemoryQuestionData.define
def.field("number").questionId = 0
def.field("table").options = nil
def.method("table").RawSet = function(self, question)
  self.questionId = question.question_id
  self.options = question.option_list
end
def.method("=>", "number").GetQuestionId = function(self)
  return self.questionId
end
def.method("=>", "table").GetQuestionOptions = function(self)
  return self.options or {}
end
MemoryQuestionData.Commit()
return MemoryQuestionData
