require("framework.init")
local ConnectHandler = class("ConnectHandler")
ConnectHandler.STARTUP_OK = 0
ConnectHandler.STARTUP_ERR = 1
ConnectHandler.CONNECT_OK = 0
ConnectHandler.CONNECT_WAIT = 1
ConnectHandler.CONNECT_LOST = 2
ConnectHandler.CONNECT_ERR = 3
function ConnectHandler:handleStartup(state)
  if state == ConnectHandler.STARTUP_OK then
    print("*LUA* ConnectHandler STARTUP_OK")
  elseif state == ConnectHandler.STARTUP_ERR then
    print("*LUA* ConnectHandler STARTUP_ERR")
  end
end
function ConnectHandler:handleConnect(state)
  local network = require("netio.Network")
  if state == ConnectHandler.CONNECT_OK then
    print("*LUA* ConnectHandler CONNECT_OK")
  elseif state == ConnectHandler.CONNECT_WAIT then
    print("*LUA* ConnectHandler CONNECT_WAIT")
  elseif state == ConnectHandler.CONNECT_LOST then
    print("*LUA* ConnectHandler CONNECT_LOST")
    network.onConnectLost()
  elseif state == ConnectHandler.CONNECT_ERR then
    print("*LUA* ConnectHandler CONNECT_ERR")
    network.onConnectError()
  end
end
return ConnectHandler
