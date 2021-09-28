local ChannelClassBase = class("ChannelClassBase")
function ChannelClassBase:__printInterNotImplement(interName)
  print("------------------------------------------------")
  print(string.format("[WARNNING-ChannelClassBase]Interface not implement: %s ", interName))
  print("------------------------------------------------")
end
function ChannelClassBase:Init(gameParam, listener)
  self:__printInterNotImplement("Init")
end
function ChannelClassBase:getRealChannelId()
  self:__printInterNotImplement("getRealChannelId")
end
function ChannelClassBase:isLogined()
  self:__printInterNotImplement("isLogined")
end
function ChannelClassBase:Login()
  self:__printInterNotImplement("Login")
end
function ChannelClassBase:getAccount()
  self:__printInterNotImplement("getAccount")
end
function ChannelClassBase:getUserInfo()
  self:__printInterNotImplement("getUserInfo")
end
function ChannelClassBase:setGameServer(serverParam)
  self:__printInterNotImplement("setGameServer")
end
function ChannelClassBase:Logout()
  self:__printInterNotImplement("Logout")
end
function ChannelClassBase:sendLoginProtocol(gameType, deveceType)
  self:__printInterNotImplement("showToolBar")
end
function ChannelClassBase:showToolBar(place)
  self:__printInterNotImplement("showToolBar")
end
function ChannelClassBase:hideToolBar()
  self:__printInterNotImplement("hideToolBar")
end
function ChannelClassBase:enterPersonCenter()
  self:__printInterNotImplement("enterPersonCenter")
end
function ChannelClassBase:startPay(payParam)
  self:__printInterNotImplement("startPay")
end
function ChannelClassBase:getDid()
  return 2
end
function ChannelClassBase:Clean()
  self:__printInterNotImplement("Clean")
end
function ChannelClassBase:requestExitGame(listener)
  self:__printInterNotImplement("requestExitGame")
end
function ChannelClassBase:showFAQView()
  self:__printInterNotImplement("showFAQView")
end
function ChannelClassBase:enterForumOrTieba()
  self:__printInterNotImplement("enterForumOrTieba")
end
function ChannelClassBase:getFriendList(listener)
  self:__printInterNotImplement("getFriendList")
end
function ChannelClassBase:addFriend(userId, listener, extParam)
  self:__printInterNotImplement("addFriend")
end
function ChannelClassBase:shareToUser(userId, listener, contend, extParam)
  self:__printInterNotImplement("shareToUser")
end
return ChannelClassBase
