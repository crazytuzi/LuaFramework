local NetData = {}
NetData.LOGIN_TYPE_ERROR = -1
NetData.LOGIN_TYPE_NORMAL = 0
NetData.LOGIN_TYPE_SDK = 3
NetData.LOGIN_TYPE_TOKEN = 5
NetData.LOGIN_TYPE_CROSSSERVER = 6
NetData.LOGIN_TYPE_NO_AUTH = 7
NetData.GNET_STATUS_NORMAL = 0
NetData.GNET_STATUS_LOGIN = 1
NetData.GNET_STATUS_CHALLENGE = 2
NetData.GNET_STATUS_KEYEXCHANGE = 3
NetData.GNET_STATUS_SUCCESS = 4
NetData.GAME_STATUS_ROLEINFOOK = 5
NetData.GAME_STATUS_ENTERGAME = 6
local authcOk = false
local loginType = NetData.LOGIN_TYPE_ERROR
local gnetStatus = NetData.GNET_STATUS_NORMAL
local serverIP, serverPort, accountUser, accountPwd, tokenUser, tokenPwd
local protocolVer = -1
function NetData.reset()
  authcOk = false
  loginType = NetData.LOGIN_TYPE_ERROR
  gnetStatus = NetData.GNET_STATUS_NORMAL
  serverIP = nil
  serverPort = nil
  accountUser = nil
  accountPwd = nil
  tokenUser = nil
  tokenPwd = nil
  protocolVer = -1
end
function NetData.getLoginType()
  return loginType
end
function NetData.getProtocolVersion()
  return protocolVer
end
function NetData.haveToken()
  return tokenPwd ~= nil
end
function NetData.setServerInfo(ip, port)
  serverIP = ip
  serverPort = port
end
function NetData.setProtocolVersion(_ver)
  protocolVer = _ver
end
function NetData.setAccountInfo(_user, _pwd, _loginType)
  local Octets = require("netio.Octets")
  loginType = _loginType
  if loginType == NetData.LOGIN_TYPE_TOKEN then
    accountUser = _user or accountUser
    accountPwd = _pwd
  elseif loginType == NetData.LOGIN_TYPE_SDK then
    accountUser = Octets.rawFromString(_user)
    accountPwd = Octets.rawFromString(_pwd)
  else
    accountUser = Octets.rawFromString(_user .. "$zulong")
    accountPwd = Octets.rawFromString(_pwd .. "$nosdk")
  end
end
function NetData.setTokenInfo(_userid, _token)
  tokenUser = _userid
  tokenPwd = _token
end
function NetData.setTokenLogin()
  if tokenPwd then
    accountPwd = tokenPwd
    loginType = NetData.LOGIN_TYPE_TOKEN
  end
end
function NetData.setGameStatus(status)
  gnetStatus = status
  print(" ##### net status -------------------------------", status)
end
function NetData.isStatusNormal()
  return gnetStatus == NetData.GNET_STATUS_NORMAL
end
function NetData.isGNetOk()
  return gnetStatus >= NetData.GNET_STATUS_SUCCESS
end
function NetData.isRoleInfoOk()
  return gnetStatus >= NetData.GAME_STATUS_ROLEINFOOK
end
function NetData.isEnterGame()
  return gnetStatus >= NetData.GAME_STATUS_ENTERGAME
end
function NetData.getStatus()
  return gnetStatus
end
return NetData
