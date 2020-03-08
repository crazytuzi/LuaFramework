local Lplus = require("Lplus")
local Timer = Lplus.Class(ModuleBase, "Timer")
local ECGame = Lplus.ForwardDeclare("ECGame")
local def = Timer.define
local instance
local TICK = 1
def.field("number").timeElapsed = 0
def.field("table").listeners = nil
def.field("table").irregularListeners = nil
def.static("=>", Timer).Instance = function()
  if instance == nil then
    instance = Timer()
    instance.listeners = {}
    instance.irregularListeners = {}
    _G.Timer = instance
  end
  return instance
end
def.method("function", "table").RegisterListener = function(self, func, param)
  for _, v in pairs(self.listeners) do
    if v.f == func then
      return
    end
  end
  table.insert(self.listeners, {f = func, p = param})
end
def.method("function").RemoveListener = function(self, func)
  for k, v in pairs(self.listeners) do
    if v.f == func then
      self.listeners[k] = nil
      return
    end
  end
end
def.method("function", "table").RegisterIrregularTimeListener = function(self, func, param)
  for _, v in pairs(self.irregularListeners) do
    if v.f == func then
      return
    end
  end
  table.insert(self.irregularListeners, {f = func, p = param})
end
def.method("function").RemoveIrregularTimeListener = function(self, func)
  for k, v in pairs(self.irregularListeners) do
    if v.f == func then
      self.irregularListeners[k] = nil
      return
    end
  end
end
def.method("number").Update = function(self, time)
  self.timeElapsed = self.timeElapsed + time
  for _, v in pairs(self.irregularListeners) do
    _G.SafeCall(v.f, v.p, time)
  end
  if self.timeElapsed >= TICK then
    self.timeElapsed = self.timeElapsed - TICK
    for _, v in pairs(self.listeners) do
      _G.SafeCall(v.f, v.p, 1)
    end
  end
end
return Timer.Commit()
