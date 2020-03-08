local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local GUIUtils = require("GUI.GUIUtils")
local PubroleTipsMgr = Lplus.Class("PubroleTipsMgr")
local PubroleTip = require("Main.Pubrole.ui.PubroleTip")
local def = PubroleTipsMgr.define
local _instance
def.static("=>", PubroleTipsMgr).Instance = function()
  if _instance == nil then
    _instance = PubroleTipsMgr()
    _instance:InitOperations()
  end
  return _instance
end
def.field("table")._operations = nil
def.method().InitOperations = function(self)
  self._operations = {
    require("Main.Pubrole.Operations.PubroleLookOverEquip"),
    require("Main.Pubrole.Operations.PubroleEnterSpace"),
    require("Main.Pubrole.Operations.PubroleInviteCoupleFly"),
    require("Main.Pubrole.Operations.PubroleAddFriend"),
    require("Main.Pubrole.Operations.PubroleRemoveFriend"),
    require("Main.Pubrole.Operations.PubroleSendPrivateMessage"),
    require("Main.Pubrole.Operations.PubroleInviteJoinTeam"),
    require("Main.Pubrole.Operations.PubroleApplyToJoinTeam"),
    require("Main.Pubrole.Operations.PubroleGivePresent"),
    require("Main.Pubrole.Operations.PubroleAddFriendToQQ"),
    require("Main.Pubrole.Operations.PubroleInviteJoinGang"),
    require("Main.Pubrole.Operations.PubroleApplyToJoinGang"),
    require("Main.Pubrole.Operations.PubrolePK"),
    require("Main.Pubrole.Operations.PubroleNoTalkInGang"),
    require("Main.Pubrole.Operations.PubroleCanTalkInGang"),
    require("Main.Pubrole.Operations.PubroleObserveFight"),
    require("Main.Pubrole.Operations.PubrolePersonalInfo"),
    require("Main.Pubrole.Operations.PubroleAddShield"),
    require("Main.Pubrole.Operations.PubroleRemoveShield"),
    require("Main.Pubrole.Operations.PubroleInviteWatchMoon"),
    require("Main.Pubrole.Operations.PubroleGangOperation"),
    require("Main.Pubrole.Operations.PubroleVisitHomeland"),
    require("Main.Pubrole.Operations.PubroleReport"),
    require("Main.Pubrole.Operations.PubroleJoinBanquet"),
    require("Main.Pubrole.Operations.PubroleInviteCorps"),
    require("Main.Pubrole.Operations.PubrolePlayerPK"),
    require("Main.Pubrole.Operations.PubroleAt"),
    require("Main.Pubrole.Operations.PubroleInteraction")
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
    if ope:CanDispaly(roleInfo) then
      table.insert(opes, ope)
    end
  end
  return opes
end
PubroleTipsMgr.Commit()
return PubroleTipsMgr
