local Lplus = require("Lplus")
local pairs = pairs
local error = error
local type = type
local Object = Lplus.Object
local Lplus_typeof = Lplus.typeof
local Lplus_isTypeTable = Lplus.isTypeTable
local Lplus_is = Lplus.is
local GcCallbacks = require("Utility.GcCallbacks")
local _ENV
local AnonymousEventManager = Lplus.Class()
do
  local def = AnonymousEventManager.define
  local function clearTable(t)
    for k, _ in pairs(t) do
      t[k] = nil
    end
  end
  local function checkObject(obj, who, argIndex, errLevel)
    if not Lplus_is(obj, Object) then
      error(("bad argument #%d to %s in 'AnonymousEventManager' (Lplus Object expected, got %s)"):format(argIndex, who, type(obj)), errLevel + 1)
    end
  end
  local function checkTypeTable(typeTable, who, argIndex, errLevel)
    if not Lplus_isTypeTable(typeTable) then
      error(("bad argument #%d to %s in 'AnonymousEventManager' (type table expected, got %s)"):format(argIndex, who, type(typeTable)), errLevel + 1)
    end
  end
  local function checkSimpleType(value, who, argIndex, needType, errLevel)
    if type(value) ~= needType then
      error(("bad argument #%d to %s in 'AnonymousEventManager' (%s expected, got %s)"):format(argIndex, who, needType, type(value)), errLevel + 1)
    end
  end
  local REMOVED_HANDLER = function()
  end
  local addToChain = function(chain, handler)
    chain[#chain + 1] = handler
  end
  local function removeFromChain(chain, handler)
    for i = 1, #chain do
      if chain[i] == handler then
        chain[i] = REMOVED_HANDLER
        break
      end
    end
  end
  local remove = function(arr, value)
    local iRemained = 1
    for iCur = 1, #arr do
      local cur = arr[iCur]
      if cur == value then
      else
        arr[iRemained] = cur
        iRemained = iRemained + 1
      end
    end
    for i = #arr, iRemained, -1 do
      arr[i] = nil
    end
  end
  local function cleanupChain(chain)
    remove(chain, REMOVED_HANDLER)
  end
  local function raiseEvent_internal(self, sender, arg, argTypeTable)
    local handlerChain = self.m_handlerChainMap[argTypeTable]
    if handlerChain then
      local bHasRemovedHandler = false
      for i = 1, #handlerChain do
        local handler = handlerChain[i]
        if handler ~= REMOVED_HANDLER then
          handler(sender, arg)
        else
          bHasRemovedHandler = true
        end
      end
      if bHasRemovedHandler then
        cleanupChain(handlerChain)
      end
    end
  end
  local function raiseEventIncludingBase_internal(self, sender, arg, argTypeTable)
    local baseTypeTable = Lplus_typeof(argTypeTable):getBaseTypeTable()
    if baseTypeTable ~= Object then
      raiseEventIncludingBase_internal(self, sender, arg, baseTypeTable)
    end
    return raiseEvent_internal(self, sender, arg, argTypeTable)
  end
  def.method("dynamic", Object).raiseEvent = function(self, sender, arg)
    checkObject(arg, "raiseEvent", 3, 2)
    return raiseEvent_internal(self, sender, arg, arg:getTypeTable())
  end
  def.method("dynamic", Object).raiseEventIncludingBase = function(self, sender, arg)
    checkObject(arg, "raiseEventIncludingBase", 3, 2)
    return raiseEventIncludingBase_internal(self, sender, arg, arg:getTypeTable())
  end
  def.method("table", "function").addHandler = function(self, argTypeTable, handler)
    checkTypeTable(argTypeTable, "addHandler", 2, 2)
    checkSimpleType(handler, "addHandler", 3, "function", 2)
    local handlerChain = self:requireHandlerChain(argTypeTable)
    addToChain(handlerChain, handler)
  end
  def.method("table", "function", GcCallbacks).addHandlerWithCleaner = function(self, argTypeTable, handler, cleaner)
    self:addHandler(argTypeTable, handler)
    cleaner:add(function()
      self:removeHandler(argTypeTable, handler)
    end)
  end
  def.method("table", "function").addOneTimeHandler = function(self, argTypeTable, handler)
    checkTypeTable(argTypeTable, "addHandler", 2, 2)
    checkSimpleType(handler, "addHandler", 3, "function", 2)
    local function realHandler(sender, event)
      handler(sender, event)
      self:removeHandler(argTypeTable, realHandler)
    end
    self:addHandler(argTypeTable, realHandler)
  end
  def.method("table", "function").removeHandler = function(self, argTypeTable, handler)
    checkTypeTable(argTypeTable, "removeHandler", 2, 2)
    checkSimpleType(handler, "removeHandler", 3, "function", 2)
    local handlerChain = self.m_handlerChainMap[argTypeTable]
    if handlerChain then
      removeFromChain(handlerChain, handler)
    end
  end
  def.method("table").clear = function(self, argTypeTable)
    self.m_handlerChainMap[argTypeTable] = nil
  end
  def.method("table").clearAll = function(self, argTypeTable)
    clearTable(self.m_handlerChainMap)
  end
  def.method("table", "=>", "table").requireHandlerChain = function(self, argTypeTable)
    local handlerChain = self.m_handlerChainMap[argTypeTable]
    if handlerChain == nil then
      handlerChain = {}
      self.m_handlerChainMap[argTypeTable] = handlerChain
    end
    return handlerChain
  end
  def.field("table").m_handlerChainMap = function()
    return {}
  end
end
AnonymousEventManager.Commit()
return {AnonymousEventManager = AnonymousEventManager}
