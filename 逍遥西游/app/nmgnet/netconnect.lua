cc.net = require("framework.cc.net.init")
local SOCKET_TICK_TIME = 0.1
local STATUS_CLOSED = "closed"
local STATUS_NOT_CONNECTED = "Socket is not connected"
local STATUS_ALREADY_CONNECTED = "already connected"
local STATUS_ALREADY_IN_PROGRESS = "Operation already in progress"
local STATUS_TIMEOUT = "timeout"
local SocketTCP_Sy = class("SocketTCP_Sy", cc.net.SocketTCP)
function SocketTCP_Sy:_onConnected(...)
  self.isConnected = true
  self:dispatchEvent({
    name = cc.net.SocketTCP.EVENT_CONNECTED
  })
  if self.connectTimeTickScheduler then
    scheduler.unscheduleGlobal(self.connectTimeTickScheduler)
  end
  print("-->>SocketTCP_Sy:_onConnected")
  local srcObj = {
    socket_read = handler(self, self.read_data_sy),
    sendrawdata = function(data)
      self:send(data)
    end,
    npconfig = {}
  }
  self.m_NetpackycObj = netpackyc.new(self.tcp:getfd(), srcObj)
  self.m_NetpackycObj:afterConnect()
  function self.m_NetpackycObj.handshaked()
    print("密钥交换完成!")
    if g_NetConnectMgr then
      g_NetConnectMgr:ProtocolEncryptFinish()
    else
      print("g_NetConnectMgr == nil")
    end
  end
  local function __tick()
    if self.m_NetpackycObj then
      local data = self.m_NetpackycObj:trystep()
      if data then
        for i, v in ipairs(data) do
          do
            local function funcObj()
              HadReciveData(v)
            end
            xpcall(funcObj, __G__TRACKBACK__)
          end
        end
      end
    end
  end
  self.tickScheduler = scheduler.scheduleGlobal(__tick, SOCKET_TICK_TIME)
end
function SocketTCP_Sy:close(...)
  SocketTCP_Sy.super.close(self, ...)
  self.m_NetpackycObj = nil
end
function SocketTCP_Sy:read_data_sy(...)
  local __body, __status, __partial = self.tcp:receive("*a")
  local data
  local dataLen = 0
  if __body and __partial then
    __body = __body .. __partial
  end
  data = __partial or __body
  if __status == STATUS_CLOSED or __status == STATUS_NOT_CONNECTED then
    scheduler.performWithDelayGlobal(function()
      self:close()
      if self.isConnected then
        self:_onDisconnect()
      else
        self:_connectFailure()
      end
    end, 1.0E-5)
  end
  if data == nil then
    return nil, 0
  end
  return data, string.len(data)
end
function SocketTCP_Sy:sendData(data, len)
  if self.m_NetpackycObj then
    self.m_NetpackycObj:socket_write(data, len)
  else
    printf("[ERROR] 发送消息出错，没有链接服务器")
  end
end
local netconnect = class("netconnect")
netconnect.SERVER_IP = "192.168.1.221"
netconnect.SERVER_PORT = 8001
NMGNET_STATUS_SUCCEED = "succeed"
NMGNET_STATUS_FAILED = "failed"
NMGNET_STATUS_LOST = "lost"
function netconnect:ctor(ip, port)
  self:_setIpNPort(ip, port)
  self.m_Socket = nil
  self.m_connResultListerner = nil
  self.m_LastSaveData = nil
end
function netconnect:connect(connResultListerner, ip, port)
  self.m_connResultListerner = nil
  if (self.m_Socket and ip and ip ~= self.m_IP or port and self.m_Port ~= port) and self.m_Socket then
    self.m_Socket:disconnect()
    self.m_Socket:close()
    self.m_Socket = nil
  end
  self:_setIpNPort(ip, port)
  self.m_connResultListerner = connResultListerner
  self.m_LastSaveData = nil
  if not self.m_Socket then
    printLog("netconnect", "开始链接 IP=%s,PORT=%s", self.m_IP, self.m_Port)
    self.m_Socket = SocketTCP_Sy.new(self.m_IP, self.m_Port, false)
    self.m_Socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECTED, handler(self, self._onStatus))
    self.m_Socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSE, handler(self, self._onStatus))
    self.m_Socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSED, handler(self, self._onStatus))
    self.m_Socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self, self._onStatus))
    self.m_Socket:addEventListener(cc.net.SocketTCP.EVENT_DATA, handler(self, self._onData))
  end
  self.m_Socket:connect()
end
function netconnect:send(data)
  if self.m_Socket then
    self.m_Socket:sendData(data, string.len(data))
  else
    printf("[ERROR] 发送消息出错，没有链接服务器")
  end
end
function netconnect:getIpNPort()
  return self.m_IP, self.m_Port
end
function netconnect:close()
  self.m_connResultListerner = nil
  self.m_IP = nil
  self.m_Port = nil
  if self.m_Socket then
    self.m_Socket:close()
    self.m_Socket:disconnect()
    self.m_Socket = nil
  end
end
function netconnect:_onData(event)
  local _data = event.data
  local _dataList = string.split(_data, "\n")
  local len = #_dataList
  if len > 0 then
    for i, _d in ipairs(_dataList) do
      if 0 < string.len(_d) then
        if i == 1 then
          if self.m_LastSaveData then
            HadReciveData(self.m_LastSaveData .. _d)
            self.m_LastSaveData = nil
          else
            HadReciveData(_d)
          end
        elseif i == len then
          local strLen = #_data
          if string.sub(_data, strLen, strLen) == "\n" then
            HadReciveData(_d)
          else
            self.m_LastSaveData = _d
          end
        else
          HadReciveData(_d)
        end
      end
    end
  end
end
function netconnect:_setIpNPort(ip, port)
  self.m_IP = ip or netconnect.SERVER_IP
  self.m_Port = port or netconnect.SERVER_PORT
end
function netconnect:_onStatus(event)
  printf("netconnect:_onStatus:%s", event.name)
  local e_name = event.name
  local retStatus
  if e_name == cc.net.SocketTCP.EVENT_CONNECT_FAILURE then
    retStatus = NMGNET_STATUS_FAILED
  elseif e_name == cc.net.SocketTCP.EVENT_CLOSED then
    retStatus = NMGNET_STATUS_LOST
  elseif e_name == cc.net.SocketTCP.EVENT_CONNECTED then
    retStatus = NMGNET_STATUS_SUCCEED
  end
  if retStatus ~= nil and self.m_connResultListerner then
    self.m_connResultListerner(retStatus)
  end
  if retStatus ~= nil then
    SendMessage(MsgID_TCP_Event, retStatus)
  end
end
return netconnect
