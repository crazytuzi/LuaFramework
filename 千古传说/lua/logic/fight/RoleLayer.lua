--
-- Author: Zippo
-- Date: 2013-12-03 12:14:39
--
local fightRoleMgr  = require("lua.logic.fight.FightRoleManager")

local RoleLayer = class("RoleLayer", function(...)
	local layer = TFPanel:create()
	return layer
end)

function RoleLayer:ctor(data)
	fightRoleMgr:CreateAllRole(FightManager.fightBeginInfo.rolelist, self)
end

return RoleLayer