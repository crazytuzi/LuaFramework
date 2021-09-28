open_faction_co = nil

local function init()
  local p = require "protocoldef.knight.gsp.faction.copenfaction":new()
  require "manager.luaprotocolmanager".getInstance():send(p)

	local datamanager = require "ui.faction.factiondatamanager"
	local factionid, campid = datamanager.factionid, datamanager.campid
	
	if campid == 0 then
		-- Œ¥—°‘Ò’Û”™
		require "ui.faction.familyfound"
		local dlg = FamilyFound.getInstance()
		dlg:Show(1)
		return dlg
	else
		if factionid == 0 then
			require "ui.faction.familyfound"
			local dlg = FamilyFound.getInstance()
			dlg:Show(2)
			return dlg
		else
			require "ui.faction.factionmain"
			local dlg = FactionMain.getInstanceAndShowIt()
			return dlg
		end
	end
end

return init