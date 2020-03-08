local Lplus = require("Lplus")
local TeamRoleTipsMgr = Lplus.Class("TeamRoleTipsMgr")
local GUIUtils = require("GUI.GUIUtils")
local TeamRoleOperateBase = require("Main.Gang.GangTeam.operations.TeamRoleOperateBase")
local PubroleTip = require("Main.Pubrole.ui.PubroleTip")
local def = TeamRoleTipsMgr.define
local instance
def.field("table")._operations = nil
def.static("=>", TeamRoleTipsMgr).Instance = function()
  if instance == nil then
    instance = TeamRoleTipsMgr()
    instance:InitOperations()
  end
  return instance
end
def.method().InitOperations = function(self)
  self._operations = {
    require("Main.Gang.GangTeam.operations.TeamRoleInvite"),
    require("Main.Gang.GangTeam.operations.TeamRoleSendMsg"),
    require("Main.Gang.GangTeam.operations.TeamRoleKickOutMember"),
    require("Main.Gang.GangTeam.operations.TeamRoleTransformLeadership"),
    require("Main.Gang.GangTeam.operations.TeamRoleMore")
  }
end
def.method("table", "number", "number", "number", "number", "number", "table", "=>", "table").ShowTip = function(self, roleInfo, sourceX, sourceY, sourceW, sourceH, prefer, tag)
  local pos = {
    auto = true,
    sourceX = sourceX,
    sourceY = sourceY,
    sourceW = sourceW,
    sourceH = sourceH,
    prefer = prefer
  }
  return self:_showTip(pos, roleInfo, tag)
end
def.method("table", "number", "number", "table", "=>", "table").ShowTipXY = function(self, roleInfo, x, y, tag)
  local pos = {
    auto = false,
    x = x,
    y = y
  }
  return self:_showTip(pos, roleInfo, tag)
end
def.method("table", "table", "table", "=>", "table")._showTip = function(self, pos, roleInfo, tag)
  local myRoleId = _G.GetHeroProp().id
  if myRoleId == roleInfo.roleId then
    return nil
  end
  local operations = self:GetOperations(roleInfo, tag)
  return PubroleTip.ShowTip(pos, roleInfo, operations)
end
def.method("table", "table", "=>", "table").GetOperations = function(self, roleInfo, tag)
  local opes = {}
  for k, v in ipairs(self._operations) do
    local ope = v()
    ope.tag = tag
    if ope:CanDisplay(roleInfo, tag) then
      table.insert(opes, ope)
    end
  end
  return opes
end
return TeamRoleTipsMgr.Commit()
