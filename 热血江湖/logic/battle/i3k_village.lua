----------------------------------------------------------------
module(..., package.seeall)

local require = require;

local BASE = require("logic/battle/i3k_world").i3k_world;


------------------------------------------------------
i3k_village = i3k_class("i3k_village", BASE)
function i3k_village:ctor(sync)
end

function i3k_village:Create(id)
	if not self:CreateFromCfg(i3k_db_village[id]) then
		return false;
	end

	return true;
end

