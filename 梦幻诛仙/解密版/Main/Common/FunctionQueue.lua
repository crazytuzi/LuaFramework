local Lplus = require("Lplus")
local FunctionQueue = Lplus.Class("FunctionQueue")
local def = FunctionQueue.define
local instance
def.static("=>", FunctionQueue).Instance = function()
  if instance == nil then
    instance = FunctionQueue()
    instance:Init()
  end
  return instance
end
def.field("table")._Queue = nil
def.field("function")._completeCallback = nil
def.method().Init = function(self)
  self:Reset()
end
def.method().Reset = function(self)
  self._Queue = {}
end
def.method("function").Push = function(self, fn)
  local count = #self._Queue
  table.insert(self._Queue, fn)
  if count == 0 then
    Timer:RegisterIrregularTimeListener(self.OnDelayProcess, self)
  end
end
def.method("number").OnDelayProcess = function(self, dt)
  self:_DoOne()
  if #self._Queue == 0 then
    Timer:RemoveIrregularTimeListener(self.OnDelayProcess)
    if self._completeCallback ~= nil then
      self._completeCallback()
      self._completeCallback = nil
    end
  end
end
def.method()._DoOne = function(self)
  local queue = {}
  local f = self._Queue[1]
  if f ~= nil then
    f()
  end
  for i = 2, #self._Queue do
    local f = self._Queue[i]
    if f ~= nil then
      table.insert(queue, f)
    end
  end
  self._Queue = queue
end
FunctionQueue.Commit()
return FunctionQueue
