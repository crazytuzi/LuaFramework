SpecialGoToNpc = {}

-- Do special thing when handle goto by a special npc id
-- It is used in cpp
-- Please return 1 when get a sepcial
-- @param npcid : the npc id to go
-- @return : 1 when get a special, 0 when do default
function SpecialGoToNpc.LuaGoToNpc(npcid)
	LogInfo("Get SpecialGoToNpc ID: " .. tostring(npcid))

	-- Open My Xiake Dialog
	if npcid == 101 then
		LogInfo("Do SpecialGoToNpc LuaGoToNpc ID: " .. tostring(npcid) .. " Open My Xiake Dialog")
		local dlg = require "ui.xiake.mainframe".getInstance()
		dlg:ShowById(2)
		return 1
	end

	LogInfo("Not Lua SpecialGoToNpc ID: " .. tostring(npcid) .. " Do it in cpp")
	return 0
end

return SpecialGoToNpc