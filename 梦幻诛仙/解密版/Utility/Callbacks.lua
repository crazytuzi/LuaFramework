local Lplus = require("Lplus")
local error = error
local pairs = pairs
local type = type
local _G = _G
local _ENV
local Callbacks = Lplus.Class()
do
  local def = Callbacks.define
  local function clearTable(t)
    for k, _ in pairs(t) do
      t[k] = nil
    end
  end
  local function checkNonNil(obj, who, argIndex, errLevel)
    if obj == nil then
      error(("bad argument #%d to %s in 'Callbacks' (Non-nil expected, got nil)"):format(argIndex, who, type(obj)), errLevel + 1)
    end
  end
  def.method("function").add = function(self, callback)
    checkNonNil(callback, "add", 2, 2)
    local callbacks = self.m_callbacks
    if callbacks == nil then
      callbacks = {}
      self.m_callbacks = callbacks
    end
    callbacks[#callbacks + 1] = callback
  end
  def.method().clear = function(self)
    local callbacks = self.m_callbacks
    if callbacks then
      clearTable(callbacks)
    end
  end
  def.method().invoke = function(self)
    local callbacks = self.m_callbacks
    if callbacks then
      for i = 1, #callbacks do
        local f = callbacks[i]
        f()
      end
    end
  end
  def.method("=>", "boolean").isEmpty = function(self)
    local callbacks = self.m_callbacks
    return not callbacks or #callbacks == 0
  end
  def.method().invokeAndPopFront = function(self)
    local callbacks = self.m_callbacks
    if callbacks and #callbacks > 0 then
      local callback = callbacks[1]
      table.remove(callbacks, 1)
      callback()
    else
      error("bad calling to 'invokeAndPopFront' (queue is empty)", 2)
    end
  end
  def.field("table").m_callbacks = nil
end
return Callbacks.Commit()
