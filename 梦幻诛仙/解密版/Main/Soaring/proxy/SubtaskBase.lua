local Lplus = require("Lplus")
local SubtaskBase = Lplus.Class("SubtaskBase")
local def = SubtaskBase.define
def.field("number")._taskId = 0
def.field("boolean")._bIsCompleted = false
def.virtual().OnTodoTask = function(self)
end
def.virtual("number", "number", "=>", "boolean").OnDoTask = function(self, npcid, serviceId)
end
def.virtual().Release = function(self)
end
def.method("=>", "boolean").IsTaskCompleted = function(self)
  return self._bIsCompleted
end
def.method("boolean").SetTaskComplete = function(self, bCompleted)
  self._bIsCompleted = bCompleted
end
return SubtaskBase.Commit()
