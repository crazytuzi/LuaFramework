--[[
杀戮值Consts
2015年1月23日16:50:26
haohu
]]
_G.classlist['KillValueConsts'] = 'KillValueConsts'
_G.KillValueConsts = {};
KillValueConsts.objName = 'KillValueConsts'
local maxKillValue;
function KillValueConsts:GetMaxKillValue()
	if not maxKillValue then
		local maxKillValue = 0;
		for id, cfg in pairs(t_killtask) do
			maxKillValue = math.max( maxKillValue, id );
		end
	end
	return maxKillValue;
end

local maxLevel;
function KillValueConsts:GetMaxLevel()
	if not maxLevel then
		maxLevel = 0;
		for id, cfg in pairs(t_killtask) do
			maxLevel = math.max( cfg.level, maxLevel );
		end
	end
	return maxLevel;
end