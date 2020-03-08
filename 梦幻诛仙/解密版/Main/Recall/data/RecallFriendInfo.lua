local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local RecallFriendInfo = Lplus.Class(CUR_CLASS_NAME)
local def = RecallFriendInfo.define
def.field("table").userInfo = nil
def.field("table").roleInfo = nil
def.final("table", "=>", RecallFriendInfo).New = function(friendInfo)
  local recallFriendInfo = RecallFriendInfo()
  recallFriendInfo.userInfo = friendInfo.user_info
  recallFriendInfo.roleInfo = friendInfo.role_info
  return recallFriendInfo
end
def.virtual().Release = function(self)
  self.userInfo = nil
  self.roleInfo = nil
end
def.method("userdata", "=>", "boolean").IsOpenIdEq = function(self, openId)
  local result = false
  if openId and self.userInfo and self.userInfo.openid then
    local strOpenId = _G.GetStringFromOcts(openId)
    local selfStrOpenId = _G.GetStringFromOcts(self.userInfo.openid)
    result = strOpenId == selfStrOpenId
  end
  return result
end
def.method("=>", "userdata").GetOpenId = function(self)
  return self.userInfo and self.userInfo.openid or nil
end
def.method("=>", "string").GetOpenIdString = function(self)
  local openId = self:GetOpenId()
  return openId and _G.GetStringFromOcts(openId) or ""
end
def.method("=>", "string").GetNickName = function(self)
  return self.userInfo and _G.GetStringFromOcts(self.userInfo.nickname) or ""
end
def.method("=>", "userdata").GetFigureUrl = function(self)
  return self.userInfo and self.userInfo.figure_url or nil
end
def.method("=>", "number").GetLastLoginTime = function(self)
  return self.userInfo and self.userInfo.last_login or 0
end
def.method("=>", "number").GetLoginPrivilege = function(self)
  return self.userInfo and self.userInfo.login_privilege or 0
end
def.method("=>", "table").GetQQVipInfos = function(self)
  return self.userInfo and self.userInfo.qq_vip_infos or {}
end
def.method("=>", "userdata").GetRoleId = function(self)
  return self.roleInfo and self.roleInfo.roleid or 0
end
def.method("=>", "string").GetRoleName = function(self)
  return self.roleInfo and _G.GetStringFromOcts(self.roleInfo.rolename) or ""
end
def.method("=>", "number").GetGender = function(self)
  return self.roleInfo and self.roleInfo.gender or 0
end
def.method("=>", "number").GetLevel = function(self)
  return self.roleInfo and self.roleInfo.level or 0
end
def.method("=>", "number").GetOccpId = function(self)
  return self.roleInfo and self.roleInfo.occupation or 0
end
def.method("=>", "number").GetZoneId = function(self)
  return self.roleInfo and self.roleInfo.zoneid or 0
end
def.method("=>", "number").GetFightPower = function(self)
  return self.roleInfo and self.roleInfo.fight or 0
end
return RecallFriendInfo.Commit()
