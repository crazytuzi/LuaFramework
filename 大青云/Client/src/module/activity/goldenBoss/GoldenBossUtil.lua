--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/7/15
    Time: 20:42
   ]]

_G.GoldenBossUtil = {};

function GoldenBossUtil:GetAreaAGuaJiPosition(mapid)
	local posID;
	for k, v in pairs(t_goldbosspar) do
		if v.mapid == mapid then
			posID = v.hook_A;
		end
	end
	if not posID then return nil; end
	return t_position[posID].pos;
end

function GoldenBossUtil:GetAreaBGuaJiPosition(mapid)
	local posID;
	for k, v in pairs(t_goldbosspar) do
		if v.mapid == mapid then
			posID = v.hook_B;
		end
	end
	if not posID then return nil; end
	return t_position[posID].pos;
end

function GoldenBossUtil:GetAreaASkillPosition(mapid)
	local posID;
	for k, v in pairs(t_goldbosspar) do
		if v.mapid == mapid then
			posID = v.mark_A;
		end
	end
	if not posID then return nil; end
	return t_position[posID].pos;
end
function GoldenBossUtil:GetAreaBSkillPosition(mapid)
	local posID;
	for k, v in pairs(t_goldbosspar) do
		if v.mapid == mapid then
			posID = v.mark_B;
		end
	end
	if not posID then return nil; end
	return t_position[posID].pos;
end