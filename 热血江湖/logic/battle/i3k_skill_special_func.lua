----------------------------------------------------------------
--module(..., package.seeall)

local require = require

require("i3k_global");
require("logic/battle/i3k_skill_def");

function i3k_ss_func_damage_factor(hero, cfgs)
	local factor = 1.0;

	if cfgs then
		if cfgs.type == 1 then
			local odds = hero:GetPropertyValue(ePropID_hp) / hero:GetPropertyValue(ePropID_maxHP);
			if odds < (cfgs.arg1 / 100) then
				if cfgs.valueType == 1 then
					factor = (1.0 + cfgs.value)
				else
					factor = (1.0 + cfgs.value / 10000);
				end
			end
		elseif cfgs.type == 2 then
			local odds1 = 1.0 - hero:GetPropertyValue(ePropID_hp) / hero:GetPropertyValue(ePropID_maxHP);
			local odds2 = cfgs.arg1 / 100;

			local ratio = i3k_integer(odds1 / odds2);
			if ratio > 0 then
				if cfgs.valueType == 1 then
					factor = (1.0 + cfgs.value * ratio);
				else
					factor = (1.0 + (cfgs.value / 10000) * ratio);
				end
			end
		elseif cfgs.type == 3 then
		end
	end

	return factor;
end
