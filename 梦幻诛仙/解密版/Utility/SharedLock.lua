local Lplus = require("Lplus")
local Callbacks = require("Utility.Callbacks")
local SharedLock = Lplus.Class()
do
  local def = SharedLock.define
  local l_last_lock_id = 0
  local function genLockId()
    local id = l_last_lock_id + 1
    l_last_lock_id = id
    return id
  end
  def.method("number", "boolean", "number", "boolean", "function", "=>", "dynamic").lock = function(self, accessLevel, isAccessLevelStrict, shareLevel, isShareLevelStrict, onGetLock)
    if onGetLock == nil then
      error("onGetLock can not be nil")
    end
    local id = genLockId()
    local info = {
      id = id,
      accessLevel = accessLevel,
      isAccessLevelStrict = isAccessLevelStrict,
      shareLevel = shareLevel,
      isShareLevelStrict = isShareLevelStrict,
      onGetLock = onGetLock
    }
    if self:canLock(accessLevel, isAccessLevelStrict) then
      self.m_accessMap[id] = info
      onGetLock(id)
    else
      table.insert(self.m_waitList, info)
    end
    return id
  end
  def.method("dynamic").unlock = function(self, id)
    local bNeedRecheck = self.m_accessMap[id] ~= nil
    self.m_accessMap[id] = nil
    local waitList = self.m_waitList
    for iWait = 1, #waitList do
      if waitList[iWait].id == id then
        table.remove(waitList, iWait)
      end
    end
    if bNeedRecheck then
      self:reCheckWaitList()
    end
  end
  def.method("number", "boolean", "=>", "boolean").canLock = function(self, accessLevel, isAccessLevelStrict)
    for id, other in pairs(self.m_accessMap) do
      local shareLevel, isShareLevelStrict = other.shareLevel, other.isShareLevelStrict
      if accessLevel < shareLevel or accessLevel == shareLevel and isAccessLevelStrict and isShareLevelStrict then
        return false
      end
    end
    return true
  end
  def.method("number", "boolean", "number", "boolean", "function", "=>", "dynamic").tryLock = function(self, accessLevel, isAccessLevelStrict, shareLevel, isShareLevelStrict, onGetLock)
    if self:canLock(accessLevel, isAccessLevelStrict) then
      return self:lock(accessLevel, isAccessLevelStrict, shareLevel, isShareLevelStrict, onGetLock)
    else
      return nil
    end
  end
  local AccessState = Lplus.Class()
  do
    local def = AccessState.define
    def.final(SharedLock, "number", "boolean", "number", "boolean", "=>", AccessState).new = function(lock, accessLevel, isAccessLevelStrict, shareLevel, isShareLevelStrict)
      local obj = AccessState()
      obj.m_lock = lock
      obj.m_accessLevel = accessLevel
      obj.m_isAccessLevelStrict = isAccessLevelStrict
      obj.m_shareLevel = shareLevel
      obj.m_isShareLevelStrict = isShareLevelStrict
      return obj
    end
    def.method("function").lock = function(self, onGetLock)
      if self.m_gotLock then
        onGetLock()
        return
      end
      self.m_callbacks:add(onGetLock)
      if self.m_currentId then
        return
      end
      self.m_currentId = self.m_lock:lock(self.m_accessLevel, self.m_isAccessLevelStrict, self.m_shareLevel, self.m_isShareLevelStrict, function(id)
        self.m_gotLock = true
        self.m_callbacks:invoke()
        self.m_callbacks:clear()
      end)
    end
    def.method().unlock = function(self)
      local id = self.m_currentId
      if not id then
        return
      end
      self.m_currentId = nil
      self.m_gotLock = false
      self.m_callbacks:clear()
      self.m_lock:unlock(id)
    end
    def.method("=>", "string").state = function(self)
      if self.m_currentId then
        if self.m_gotLock then
          return "locked"
        else
          return "locking"
        end
      else
        return "none"
      end
    end
    def.field(SharedLock).m_lock = nil
    def.field("number").m_accessLevel = 0
    def.field("boolean").m_isAccessLevelStrict = false
    def.field("number").m_shareLevel = 0
    def.field("boolean").m_isShareLevelStrict = false
    def.field("dynamic").m_currentId = nil
    def.field("boolean").m_gotLock = false
    def.field(Callbacks).m_callbacks = function()
      return Callbacks()
    end
  end
  def.const("table").AccessState = AccessState.Commit()
  def.method("number", "boolean", "number", "boolean", "=>", AccessState).makeAccessState = function(self, accessLevel, isAccessLevelStrict, shareLevel, isShareLevelStrict)
    return AccessState.new(self, accessLevel, isAccessLevelStrict, shareLevel, isShareLevelStrict)
  end
  def.method().reCheckWaitList = function(self)
    for iWait, info in ipairs(self.m_waitList) do
      local accessLevel = info.accessLevel
      local isAccessLevelStrict = info.isAccessLevelStrict
      if self:canLock(accessLevel, isAccessLevelStrict) then
        table.remove(self.m_waitList, iWait)
        self.m_accessMap[info.id] = info
        info.onGetLock(info.id)
        return self:reCheckWaitList()
      end
    end
  end
  def.field("table").m_accessMap = function()
    return {}
  end
  def.field("table").m_waitList = function()
    return {}
  end
end
return SharedLock.Commit()
