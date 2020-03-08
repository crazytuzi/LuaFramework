local SOCKET_TICK_TIME = 0.1
local SOCKET_RECONNECT_TIME = 5
local SOCKET_CONNECT_FAIL_TIMEOUT = 3
local STATUS_CLOSED = "closed"
local STATUS_NOT_CONNECTED = "Socket is not connected"
local STATUS_ALREADY_CONNECTED = "already connected"
local STATUS_ALREADY_IN_PROGRESS = "Operation already in progress"
local STATUS_TIMEOUT = "timeout"
local scheduler = require("framework.scheduler")
local socket = require("socket")
local SocketTCP = class("SocketTCP")
SocketTCP.EVENT_DATA = "SOCKET_TCP_DATA"
SocketTCP.EVENT_CLOSE = "SOCKET_TCP_CLOSE"
SocketTCP.EVENT_CLOSED = "SOCKET_TCP_CLOSED"
SocketTCP.EVENT_CONNECTED = "SOCKET_TCP_CONNECTED"
SocketTCP.EVENT_CONNECT_FAILURE = "SOCKET_TCP_CONNECT_FAILURE"
SocketTCP._VERSION = socket._VERSION
SocketTCP._DEBUG = socket._DEBUG
function SocketTCP.getTime()
  return socket.gettime()
end
function SocketTCP:ctor(__host, __port, __retryConnectWhenFailure)
  cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
  self.host = __host
  self.port = __port
  self.tickScheduler = nil
  self.reconnectScheduler = nil
  self.connectTimeTickScheduler = nil
  self.name = "SocketTCP"
  self.tcp = nil
  self.isRetryConnect = __retryConnectWhenFailure
  self.isConnected = false
end
function SocketTCP:setName(__name)
  self.name = __name
  return self
end
function SocketTCP:setTickTime(__time)
  SOCKET_TICK_TIME = __time
  return self
end
function SocketTCP:setReconnTime(__time)
  SOCKET_RECONNECT_TIME = __time
  return self
end
function SocketTCP:setConnFailTime(__time)
  SOCKET_CONNECT_FAIL_TIMEOUT = __time
  return self
end
function SocketTCP:connect(__host, __port, __retryConnectWhenFailure)
  if __host then
    self.host = __host
  end
  if __port then
    self.port = __port
  end
  if __retryConnectWhenFailure ~= nil then
    self.isRetryConnect = __retryConnectWhenFailure
  end
  assert(self.host or self.port, "Host and port are necessary!")
  self.tcp = socket.tcp()
  self.tcp:settimeout(0)
  local function __checkConnect()
    local __succ = self:_connect()
    if __succ then
      self:_onConnected()
    end
    return __succ
  end
  if not __checkConnect() then
    local function __connectTimeTick()
      if self.isConnected then
        return
      end
      self.waitConnect = self.waitConnect or 0
      self.waitConnect = self.waitConnect + SOCKET_TICK_TIME
      if self.waitConnect >= SOCKET_CONNECT_FAIL_TIMEOUT then
        self.waitConnect = nil
        self:close()
        self:_connectFailure()
      end
      __checkConnect()
    end
    self.connectTimeTickScheduler = scheduler.scheduleGlobal(__connectTimeTick, SOCKET_TICK_TIME)
  end
end
function SocketTCP:send(__data)
  assert(self.isConnected, self.name .. " is not connected.")
  self.tcp:send(__data)
end
function SocketTCP:close(...)
  self.tcp:close()
  if self.connectTimeTickScheduler then
    scheduler.unscheduleGlobal(self.connectTimeTickScheduler)
  end
  if self.tickScheduler then
    scheduler.unscheduleGlobal(self.tickScheduler)
  end
  self:dispatchEvent({
    name = SocketTCP.EVENT_CLOSE
  })
end
function SocketTCP:disconnect()
  self:_disconnect()
  self.isRetryConnect = false
end
function SocketTCP:_connect()
  local __succ, __status = self.tcp:connect(self.host, self.port)
  return __succ == 1 or __status == STATUS_ALREADY_CONNECTED
end
function SocketTCP:_disconnect()
  self.isConnected = false
  self.tcp:shutdown()
  self:dispatchEvent({
    name = SocketTCP.EVENT_CLOSED
  })
end
function SocketTCP:_onDisconnect()
  self.isConnected = false
  self:dispatchEvent({
    name = SocketTCP.EVENT_CLOSED
  })
  self:_reconnect()
end
function SocketTCP:_onConnected()
  self.isConnected = true
  self:dispatchEvent({
    name = SocketTCP.EVENT_CONNECTED
  })
  if self.connectTimeTickScheduler then
    scheduler.unscheduleGlobal(self.connectTimeTickScheduler)
  end
  local function __tick()
    while true do
      local __body, __status, __partial = self.tcp:receive("*a")
      if __status == STATUS_CLOSED or __status == STATUS_NOT_CONNECTED then
        self:close()
        if self.isConnected then
          self:_onDisconnect()
        else
          self:_connectFailure()
        end
        return
      end
      if __body and string.len(__body) == 0 or __partial and string.len(__partial) == 0 then
        return
      end
      if __body and __partial then
        __body = __body .. __partial
      end
      self:dispatchEvent({
        name = SocketTCP.EVENT_DATA,
        data = __partial or __body,
        partial = __partial,
        body = __body
      })
    end
  end
  self.tickScheduler = scheduler.scheduleGlobal(__tick, SOCKET_TICK_TIME)
end
function SocketTCP:_connectFailure(status)
  self:dispatchEvent({
    name = SocketTCP.EVENT_CONNECT_FAILURE
  })
  self:_reconnect()
end
function SocketTCP:_reconnect(__immediately)
  if not self.isRetryConnect then
    return
  end
  printInfo("%s._reconnect", self.name)
  if __immediately then
    self:connect()
    return
  end
  if self.reconnectScheduler then
    scheduler.unscheduleGlobal(self.reconnectScheduler)
  end
  local function __doReConnect()
    self:connect()
  end
  self.reconnectScheduler = scheduler.performWithDelayGlobal(__doReConnect, SOCKET_RECONNECT_TIME)
end
return SocketTCP
