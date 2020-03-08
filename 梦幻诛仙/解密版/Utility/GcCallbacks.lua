local Lplus = require("Lplus")
local newproxy = newproxy
local getmetatable = getmetatable
local setmetatable = setmetatable
local error = error
local pairs = pairs
local tostring = tostring
local type = type
local _G = _G
local _VERSION = _VERSION
local is_5_1 = _VERSION == "Lua 5.1"
local _ENV
local GcCallbacks = Lplus.Class()
do
  local def = GcCallbacks.define
  local function clearTable(t)
    for k, _ in pairs(t) do
      t[k] = nil
    end
  end
  local createGcProxy
  if is_5_1 then
    function createGcProxy(callback)
      local proxy = newproxy(true)
      local meta = getmetatable(proxy)
      meta.__gc = callback
      return proxy
    end
  else
    function createGcProxy(callback)
      local proxy = {}
      local meta = {}
      meta.__gc = callback
      return setmetatable(proxy, meta)
    end
  end
  local function checkNonNil(obj, who, argIndex, errLevel)
    if obj == nil then
      error(("bad argument #%d to %s in 'GcCallbacks' (Non-nil expected, got nil)"):format(argIndex, who, type(obj)), errLevel + 1)
    end
  end
  def.method("function").add = function(self, callback)
    checkNonNil(callback, "add", 2, 2)
    self:checkGcProxy()
    local callbacks = self.m_callbacks
    callbacks[#callbacks + 1] = callback
  end
  def.method().dispose = function(self)
    self.m_needDisposeErrMsg = nil
    local proxyCallback = self.m_proxyCallback
    if proxyCallback then
      proxyCallback()
    end
  end
  def.method("string").setNeedDispose = function(self, errMsg)
    self.m_needDisposeErrMsg = errMsg or ""
  end
  def.field("dynamic").m_gcProxy = nil
  def.field("function").m_proxyCallback = nil
  def.field("table").m_callbacks = nil
  def.field("dynamic").m_needDisposeErrMsg = nil
  def.method().checkGcProxy = function(self)
    if self.m_gcProxy == nil then
      self.m_callbacks = {}
      local function proxyCallback()
        if self.m_needDisposeErrMsg then
          error("dispose need to be invoked: " .. tostring(self.m_needDisposeErrMsg), 2)
        end
        local callbacks = self.m_callbacks
        for i = 1, #callbacks do
          local f = callbacks[i]
          f()
        end
        clearTable(callbacks)
      end
      self.m_gcProxy = createGcProxy(proxyCallback)
      self.m_proxyCallback = proxyCallback
    end
  end
end
return GcCallbacks.Commit()
