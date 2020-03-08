local OctetsStream = require("netio.OctetsStream")
local GetChatGiftInfo = class("GetChatGiftInfo")
function GetChatGiftInfo:ctor(roleId, roleName, moneyNum)
  self.roleId = roleId or nil
  self.roleName = roleName or nil
  self.moneyNum = moneyNum or nil
end
function GetChatGiftInfo:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.roleName)
  os:marshalInt32(self.moneyNum)
end
function GetChatGiftInfo:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  self.moneyNum = os:unmarshalInt32()
end
return GetChatGiftInfo
