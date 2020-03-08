local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleSendPrivateMessage = Lplus.Extend(PubroleOperationBase, "PubroleSendPrivateMessage")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local def = PubroleSendPrivateMessage.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  if roleInfo.deleteState == RoleDeleteStatus.STATE_NORMAL then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Friend[20]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.NotifyToPrivateChatFromPub, nil)
  ChatModule.Instance():ClearFriendNewCount(roleInfo.roleId)
  ChatModule.Instance():StartPrivateChat3(roleInfo.roleId, roleInfo.name, roleInfo.level, roleInfo.occupationId, roleInfo.gender, roleInfo.avatarId, roleInfo.avatarFrameId)
  return true
end
PubroleSendPrivateMessage.Commit()
return PubroleSendPrivateMessage
