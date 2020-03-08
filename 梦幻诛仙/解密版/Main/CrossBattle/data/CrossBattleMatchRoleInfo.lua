local Lplus = require("Lplus")
local CrossBattleRoleInfo = Lplus.Class("CrossBattleRoleInfo")
local def = CrossBattleRoleInfo.define
def.field("userdata").roleId = nil
def.field("number").progress = 0
def.field("number").gender = 0
def.field("number").occupation = 0
def.field("string").roleName = ""
def.field("number").avatarId = 0
def.field("number").level = 0
def.method("table").RawSet = function(self, p)
  self.roleId = p.roleId
  self.progress = p.process
  self.gender = p.gender
  self.occupation = p.occupation
  self.roleName = _G.GetStringFromOcts(p.role_name)
  self.avatarId = p.avatar_id
  self.level = p.role_level
end
def.method("=>", "userdata").GetRoleId = function(self)
  return self.roleId
end
def.method("=>", "number").GetProgress = function(self)
  return self.progress
end
def.method("number").SetProgress = function(self, progress)
  self.progress = progress
end
def.method("=>", "number").GetGender = function(self)
  return self.gender
end
def.method("=>", "number").GetOccupation = function(self)
  return self.occupation
end
def.method("=>", "string").GetRoleName = function(self)
  return self.roleName
end
def.method("=>", "number").GetAvatarId = function(self)
  return self.avatarId
end
def.method("=>", "number").GetRoleLevel = function(self)
  return self.level
end
CrossBattleRoleInfo.Commit()
return CrossBattleRoleInfo
