local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIHandlerBase = Lplus.Class(MODULE_NAME)
local Cls = GUIHandlerBase
local def = Cls.define
def.field(ECPanelBase).m_ownerPanel = nil
def.field("userdata").m_rootGO = nil
def.field("table").m_eventHandlers = nil
def.virtual("table", "userdata").Init = function(self, ownerPanel, rootGO)
  self.m_ownerPanel = ownerPanel
  self.m_rootGO = rootGO
end
def.method("table", "table").SetEventHandlers = function(self, context, handlers)
  self.m_eventHandlers = handlers
  if handlers then
    for k, v in pairs(handlers) do
      handlers[k] = function(...)
        v(context, ...)
      end
    end
  end
end
def.method("string", "varlist").SendEvent = function(self, eventName, ...)
  local handler = self:GetEventHandler(eventName)
  if handler then
    handler(...)
  end
end
def.method("string", "=>", "function").GetEventHandler = function(self, eventName)
  if self.m_eventHandlers == nil then
    return nil
  end
  local handler = self.m_eventHandlers[eventName]
  return handler
end
return Cls.Commit()
