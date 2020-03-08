local Lplus = require("Lplus")
local Event = Lplus.Class("Event.Event")
local bit = require("bit")
local def = Event.define
local instance
_G.Event = Event
local safeCall = _G.SafeCall
def.field("table").listeners = nil
def.static("=>", Event).Instance = function()
  if instance == nil then
    instance = Event()
    instance.listeners = {}
  end
  return instance
end
def.final("number", "number", "function").RegisterEvent = function(moduleId, notifyId, func)
  local eventId = instance:_GenEventId(moduleId, notifyId)
  instance:_AddEventListener(eventId, func, nil)
end
def.final("number", "number", "function", "table").RegisterEventWithContext = function(moduleId, notifyId, func, context)
  local eventId = instance:_GenEventId(moduleId, notifyId)
  instance:_AddEventListener(eventId, func, context)
end
def.final("number", "number", "function").UnregisterEvent = function(moduleId, notifyId, func)
  local eventId = instance:_GenEventId(moduleId, notifyId)
  instance:_RemoveEventListener(eventId, func)
end
def.final("number", "number", "table").DispatchEvent = function(moduleId, notifyId, param)
  local eventId = instance:_GenEventId(moduleId, notifyId)
  instance:_DispatchEvent(eventId, param)
end
def.final("number", "function", "table").AddEventListener = function(eventId, func, param)
  instance:_AddEventListener(eventId, func, param)
end
def.final("number", "function").RemoveEventListener = function(eventId, func)
  instance:_RemoveEventListener(eventId, func)
end
def.method("number", "number", "=>", "number")._GenEventId = function(self, moduleId, notifyId)
  return bit.lshift(moduleId, 16) + notifyId
end
def.method("number", "function", "table")._AddEventListener = function(self, eventId, func, param)
  local listeners = self.listeners[eventId]
  if listeners == nil then
    listeners = {}
    self.listeners[eventId] = listeners
  end
  for _, v in pairs(listeners) do
    if v.f == func then
      return
    end
  end
  table.insert(listeners, {f = func, p = param})
end
def.method("number", "function")._RemoveEventListener = function(self, eventId, func)
  local listeners = self.listeners[eventId]
  if listeners == nil then
    return
  end
  for k, v in pairs(listeners) do
    if v.f == func then
      listeners[k] = nil
      return
    end
  end
end
def.method("number", "table")._DispatchEvent = function(self, eventId, param)
  local listeners = instance.listeners[eventId]
  if listeners == nil then
    return
  end
  for k, v in pairs(listeners) do
    if _G.isDebugBuild then
      GameUtil.BeginSamp("Event " .. FormatFunctionInfo(v.f))
    end
    if v.p then
      safeCall(v.f, v.p, param)
    else
      safeCall(v.f, param, nil)
    end
    if _G.isDebugBuild then
      GameUtil.EndSamp()
    end
  end
end
return Event.Commit()
