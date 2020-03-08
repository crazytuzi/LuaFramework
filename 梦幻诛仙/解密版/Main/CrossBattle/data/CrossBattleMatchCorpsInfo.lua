local Lplus = require("Lplus")
local CrossBattleMatchCorpsInfo = Lplus.Class("CrossBattleMatchCorpsInfo")
local def = CrossBattleMatchCorpsInfo.define
def.field("userdata").corpsId = nil
def.field("string").corpsName = ""
def.field("number").corpsIcon = 0
def.field("number").corpsZoneId = 0
def.field("table").roles = nil
def.method("table").RawSet = function(self, p)
  self.corpsId = p.corps_id
  self.corpsName = _G.GetStringFromOcts(p.corps_name)
  self.corpsIcon = p.corps_icon
  self.corpsZoneId = p.corps_zone_id
  self.roles = {}
  for i = 1, #p.match_role_list do
    local roleData = p.match_role_list[i]
    local CrossBattleMatchRoleInfo = require("Main.CrossBattle.data.CrossBattleMatchRoleInfo")
    local roleInfo = CrossBattleMatchRoleInfo()
    roleInfo:RawSet(roleData)
    table.insert(self.roles, roleInfo)
  end
end
def.method("=>", "userdata").GetCorpsId = function(self)
  return self.corpsId
end
def.method("=>", "string").GetCorpsName = function(self)
  return self.corpsName
end
def.method("=>", "number").GetCorpsIcon = function(self)
  return self.corpsIcon
end
def.method("=>", "number").GetCorpsZoneId = function(self)
  return self.corpsZoneId
end
def.method("=>", "table").GetRoles = function(self)
  return self.roles or {}
end
def.method("userdata", "=>", "table").GetRole = function(self, roleId)
  if roleId == nil then
    return nil
  end
  for i = 1, #self.roles do
    local roleInfo = self.roles[i]
    if Int64.eq(roleInfo:GetRoleId(), roleId) then
      return roleInfo
    end
  end
  return nil
end
CrossBattleMatchCorpsInfo.Commit()
return CrossBattleMatchCorpsInfo
