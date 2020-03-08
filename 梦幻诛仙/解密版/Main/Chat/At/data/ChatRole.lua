local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ChatConst = require("netio.protocol.mzm.gsp.chat.ChatConsts")
local ChatRole = Lplus.Class(CUR_CLASS_NAME)
local def = ChatRole.define
def.field("number").channel = 0
def.field("userdata").orgnizationId = nil
def.field("userdata").roleId = nil
def.field("string").name = ""
def.field("string").pinyinName = ""
def.field("number").level = 0
def.field("number").gender = 0
def.field("number").occupationId = 0
def.field("number").duty = 0
def.field("number").avatarId = 0
def.field("number").avatarFrameId = 0
def.final("userdata", "table", "=>", ChatRole).CreateFromGangMember = function(gangId, memberInfo)
  local chatRole = ChatRole()
  chatRole.channel = ChatConst.CHANNEL_FACTION
  chatRole.orgnizationId = gangId
  chatRole.roleId = memberInfo.roleId
  chatRole.name = memberInfo.name
  chatRole.pinyinName = memberInfo.pinyinName
  chatRole.level = memberInfo.level
  chatRole.gender = memberInfo.gender
  chatRole.occupationId = memberInfo.occupationId
  chatRole.duty = memberInfo.duty
  chatRole.avatarId = memberInfo.avatarId
  chatRole.avatarFrameId = memberInfo.avatar_frame
  return chatRole
end
def.final("userdata", "table", "number", "=>", ChatRole).CreateFromTeamMember = function(teamId, memberInfo, idx)
  local chatRole = ChatRole()
  chatRole.channel = ChatConst.CHANNEL_TEAM
  chatRole.orgnizationId = teamId
  chatRole.roleId = memberInfo.roleid
  chatRole.name = memberInfo.name
  chatRole.pinyinName = GameUtil.ConvertStringToPY(chatRole.name)
  chatRole.level = memberInfo.level
  chatRole.gender = memberInfo.gender
  chatRole.occupationId = memberInfo.menpai
  chatRole.duty = idx
  chatRole.avatarId = memberInfo.avatarId
  chatRole.avatarFrameId = memberInfo.avatarFrameid
  return chatRole
end
def.final("userdata", "table", "=>", ChatRole).CreateFromGroupMember = function(groupId, memberInfo)
  local chatRole = ChatRole()
  chatRole.channel = ChatConst.CHANNEL_GROUP
  chatRole.orgnizationId = groupId
  chatRole.roleId = memberInfo.roleId
  chatRole.name = memberInfo.roleName
  chatRole.pinyinName = GameUtil.ConvertStringToPY(chatRole.name)
  chatRole.level = memberInfo.roleLevel
  chatRole.gender = memberInfo.gender
  chatRole.occupationId = memberInfo.occupation
  chatRole.duty = 0
  chatRole.avatarId = memberInfo.avatarId
  chatRole.avatarFrameId = memberInfo.avatarFrameId
  return chatRole
end
def.final("number", "userdata", "table", "=>", ChatRole).CreateFromRoleInfo = function(channel, orgId, roleInfo)
  local chatRole = ChatRole()
  chatRole.channel = channel
  chatRole.orgnizationId = orgId
  chatRole.roleId = roleInfo.roleId
  chatRole.name = roleInfo.name
  chatRole.pinyinName = ""
  chatRole.level = roleInfo.level
  chatRole.gender = roleInfo.gender
  chatRole.occupationId = roleInfo.occupationId
  chatRole.duty = 0
  chatRole.avatarId = roleInfo.avatarId
  chatRole.avatarFrameId = roleInfo.avatarFrameId
  return chatRole
end
def.method().Release = function(self)
  self._petData = nil
  self._soulTable = nil
end
def.method("=>", "string").GetDutyName = function(self)
  local result = ""
  if ChatConst.CHANNEL_FACTION == self.channel then
    local GangData = require("Main.Gang.data.GangData")
    result = GangData.Instance():GetDutyName(self.duty)
  elseif ChatConst.CHANNEL_TEAM == self.channel then
    if self.duty == 1 then
      result = textRes.Chat.At.MEMBER_DUTY_TEAM_CAPTAIN
    else
      result = textRes.Chat.At.MEMBER_DUTY_TEAM_MATE
    end
  end
  return result
end
def.method("=>", "string").GetInfoPack = function(self)
  local AtUtils = require("Main.Chat.At.AtUtils")
  return AtUtils.GetInfoPack(self.channel, self.name, self.roleId, self.orgnizationId)
end
return ChatRole.Commit()
