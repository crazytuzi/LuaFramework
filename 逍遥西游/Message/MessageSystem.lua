local MsgSystem = class("MsgSystem", function()
  return CCNode:create()
end)
function MsgSystem:ctor(oldIns)
  self:retain()
  self.m_Listeners = {}
  if oldIns ~= nil then
    self.m_Listeners = clone(oldIns.m_Listeners)
    oldIns:Release()
  end
  local sharedNotifacation = CCNotificationCenter:sharedNotificationCenter()
  sharedNotifacation:registerScriptObserver(self, handler(self, self.Nodification), "APP_ENTER_BACKGROUND")
  sharedNotifacation:registerScriptObserver(self, handler(self, self.Nodification), "APP_ENTER_FOREGROUND")
  sharedNotifacation:registerScriptObserver(self, handler(self, self.Nodification), "APP_MEMORY_WARNING")
  sharedNotifacation:registerScriptObserver(self, handler(self, self.Nodification), "kReachabilityChangedNotification")
  SyNative.startListenMemoryWarning(function()
    SendMessage(MsgID_MemoryWarning)
    g_MemoryDetect:MemoryShortage()
  end)
end
function MsgSystem:RegisterMessageEvent(msgFID, listener)
  local msgIDKey = tostring(msgFID)
  if self.m_Listeners[msgIDKey] == nil then
    self.m_Listeners[msgIDKey] = {}
  end
  local handle = "_LISTENER_HANDLE_" .. tostring(listener)
  self.m_Listeners[msgIDKey][handle] = listener
  return handle
end
function MsgSystem:UnRegisterMessageEvent(msgFID, key)
  local msgIDKey = tostring(msgFID)
  if self.m_Listeners[msgIDKey] ~= nil then
    self.m_Listeners[msgIDKey][key] = nil
  end
end
function MsgSystem:GetFID(msgSID)
  local fid = msgSID
  while fid >= 100 do
    fid = fid * 0.1
  end
  return math.floor(fid)
end
function MsgSystem:SendMessage(msgSID, ...)
  local msgFID = self:GetFID(msgSID)
  local msgIDKey = tostring(msgFID)
  local listenerTable = self.m_Listeners[msgIDKey]
  if listenerTable == nil then
    return
  end
  local listeners = {}
  for _, listener in pairs(listenerTable) do
    listeners[#listeners + 1] = listener
  end
  for i, listener in ipairs(listeners) do
    listener(msgSID, ...)
  end
end
function MsgSystem:Nodification(name)
  print("MsgSystem.Nodification = ", name, tostring(self))
  if name == "APP_ENTER_BACKGROUND" then
    self:SendMessage(MsgID_EnterBackground)
  elseif name == "APP_ENTER_FOREGROUND" then
    self:SendMessage(MsgID_EnterForeground)
  elseif name == "APP_MEMORY_WARNING" then
  elseif name == "kReachabilityChangedNotification" then
  end
end
function MsgSystem:Release()
  CCNotificationCenter:sharedNotificationCenter():removeAllObservers(self)
  self:release()
end
local oldIns = g_MsgSystem
g_MsgSystem = MsgSystem.new(oldIns)
function SendMessage(msgSID, ...)
  g_MsgSystem:SendMessage(msgSID, ...)
end
MessageEventExtend = {}
function MessageEventExtend.extend(object)
  object.msgevent_msgid_hanlder_table = {}
  function object:GetFIDWithSID(msgSID)
    return g_MsgSystem:GetFID(msgSID)
  end
  function object:ListenMessage(msgFID)
    local handler = g_MsgSystem:RegisterMessageEvent(msgFID, function(msgSID, ...)
      if object.OnMessage then
        object:OnMessage(msgSID, ...)
      end
    end)
    if object.msgevent_msgid_hanlder_table[msgFID] ~= nil then
      return
    end
    object.msgevent_msgid_hanlder_table[msgFID] = handler
  end
  function object:RemoveMessageListener(msgFID)
    g_MsgSystem:UnRegisterMessageEvent(msgFID, object.msgevent_msgid_hanlder_table[msgFID])
  end
  function object:RemoveAllMessageListener()
    for k, v in pairs(object.msgevent_msgid_hanlder_table) do
      g_MsgSystem:UnRegisterMessageEvent(k, v)
    end
  end
end
