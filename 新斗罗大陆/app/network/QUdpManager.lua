local QUdpManager = class("QUdpManager")

local QUdpSocket = import(".QUdpSocket")

function QUdpManager:ctor( ... )
    self._udp = QUdpSocket.new()
    self._udp:addEventListener(QUdpSocket.EVENT_RECIVE_DATA, handler(self, self._reciveData))
end

function QUdpManager:createServer()
    if self._udp then
        self._udp:createConnect(true)
        self._udp:start()
    end
end

function QUdpManager:createClient( ... )
    if self._udp then
        self._udp:createConnect(false)
        self._udp:start()
    end
end

function QUdpManager:scanServer( ... )
    if self._udp:isServer() == false then
        self._udp:scanServer()
    end
end

function QUdpManager:_reciveData(evt)
    print("recivedata", evt)
    if evt.data == "whoisdady" and evt.ip ~= nil and evt.port ~= nil then
        self._udp:sendto("jkisdady", evt.ip, evt.port)
    end
end

return QUdpManager