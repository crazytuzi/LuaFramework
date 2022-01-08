--
-- Author: Zippo
-- Date: 2013-12-03 12:14:39
--
local battleRoleMgr  = require("lua.logic.battle.BattleRoleManager")

local BattleRoleLayer = class("BattleRoleLayer", function(...)
	local layer = TFPanel:create()
	return layer
end)

function BattleRoleLayer:ctor(data)
	battleRoleMgr:CreateAllRole(FightManager.fightBeginInfo.rolelist, self)
end

return BattleRoleLayer