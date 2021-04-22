local QUdpSocket = class("QUdpSocket")

require("pack")
local socket = require("socket")
local _serverProt = 9991
local _clientProt = 9991

QUdpSocket.EVENT_RECIVE_DATA = "EVENT_RECIVE_DATA"

function QUdpSocket:ctor( ... )
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    self._isServer = false
    self._port = _clientProt
    self._udp = nil
end

function QUdpSocket:isServer( ... )
    return self._isServer
end

function QUdpSocket:createConnect(isServer)
    self:disConnect()
    self._udp = socket.udp()
    if self._udp == nil then
        return false
    end
    if isServer then
        self._port = _serverProt
    end
    if self._udp:setsockname("*", self._port) ~= 1 then
        return false
    end
    print("listen port ", self._port)
    self._udp:setoption('broadcast', true)
    self._udp:settimeout(0)
    self._isServer = isServer
    return true
end

function QUdpSocket:disConnect( ... )
    if self._udp then
        self._udp:close()
        self._udp = nil
    end
    if self._receiveHandler then
        scheduler.unscheduleGlobal(self._receiveHandler)
        self._receiveHandler = nil
    end
end

function QUdpSocket:sendto(data, ip, port)
    if self._udp then
        print("try send ",data, ip, port)
        self._udp:sendto(data, ip, port)
    end
end

function QUdpSocket:start( )
    if self._receiveHandler then
        scheduler.unscheduleGlobal(self._receiveHandler)
        self._receiveHandler = nil
    end
    self._receiveHandler = scheduler.scheduleGlobal(handler(self, self._recieverBack), 0)
end

function QUdpSocket:_recieverBack( ... )
    local _r,_ip,_port = self._udp:receivefrom()
    while _r do
        self:dispatchEvent({name = QUdpSocket.EVENT_RECIVE_DATA, package = {data = r, ip = ip, port = port}})
        _r,_ip,_port = self._udp:receivefrom()
    end  
end

function QUdpSocket:scanServer(callback)
    self:sendto("whoisdady", '255.255.255.255', _serverProt)
end

return QUdpSocket