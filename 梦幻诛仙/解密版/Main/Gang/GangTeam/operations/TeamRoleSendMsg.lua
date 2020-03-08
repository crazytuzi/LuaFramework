local Lplus = require("Lplus")
local TeamRoleOperateBase = require("Main.Gang.GangTeam.operations.TeamRoleOperateBase")
local TeamRoleSendMsg = Lplus.Extend(TeamRoleOperateBase, "TeamRoleSendMsg")
local def = TeamRoleSendMsg.define
local ChatModule = Lplus.ForwardDeclare("ChatModule")
def.override("table", "table", "=>", "boolean").CanDisplay = function(self, roleInfo, teamInfo)
  return true
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Gang.GangTeam[13]
end
def.override("table", "table", "=>", "boolean").Operate = function(self, roleInfo, teamInfo)
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.NotifyToPrivateChatFromPub, nil)
  ChatModule.Instance():ClearFriendNewCount(roleInfo.roleId)
  ChatModule.Instance():StartPrivateChat3(roleInfo.roleId, roleInfo.name, roleInfo.level, roleInfo.occupationId, roleInfo.gender, roleInfo.avatarId, roleInfo.avatarFrameId)
  return true
end
return TeamRoleSendMsg.Commit()
