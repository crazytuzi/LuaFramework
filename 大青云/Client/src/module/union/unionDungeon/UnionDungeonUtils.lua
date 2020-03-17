--[[
帮派副本-工具类
haohu
2015年3月6日16:48:03
]]

_G.UnionDungeonUtils = {};

-- id:帮派副本id
function UnionDungeonUtils:GetUnionDungeonIsOpen(id)
	local unionLevel = UnionModel:GetMyUnionLevel();
	if unionLevel == 0 then return false end
	local dungeonVO = UnionDungeonModel:GetDungeon(id);
	local needLevel = dungeonVO.guildlv;
	return unionLevel >= needLevel;
end
