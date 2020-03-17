--[[
boss 勋章 常量
haohu
2015-11-19 17:35:00
]]

_G.BossMedalConsts = {}

BossMedalConsts.Type_World  = 0 -- 世界
BossMedalConsts.Type_Person = 1 -- 个人
BossMedalConsts.Type_Digong = 2 -- 秘境
BossMedalConsts.Type_Yewai  = 3 -- 野外

BossMedalConsts.ActivePoints = 50
BossMedalConsts.MaxStar = 5

BossMedalConsts.Attrs = {"att", "def", "hp", "cri", "defcri", "dodge", "hit", "adddamagebossx", "adddamagemonx"};

BossMedalConsts.AttrNames = {
	["att"]            = StrConfig['bosshuizhang030'],
	["def"]            = StrConfig['bosshuizhang031'],
	["hp"]             = StrConfig['bosshuizhang032'],
	["cri"]            = StrConfig['bosshuizhang033'],
	["defcri"]         = StrConfig['bosshuizhang034'],
	["dodge"]          = StrConfig['bosshuizhang035'],
	["hit"]            = StrConfig['bosshuizhang036'],
	["adddamagebossx"] = StrConfig['bosshuizhang037'],
	["adddamagemonx"]  = StrConfig['bosshuizhang038'],
}

local maxLevel
function BossMedalConsts:GetMaxLevel()
	if not maxLevel then
		maxLevel = 0
		for level, _ in pairs(t_bosshuizhang) do
			maxLevel = math.max(maxLevel, level)
		end
	end
	return maxLevel
end

local pointsMap
function BossMedalConsts:GetPointsMap()
	if not pointsMap then
		pointsMap = {}
		local map = split( t_consts[149].param, "#" )
		pointsMap[ BossMedalConsts.Type_World ]  = tonumber( map[1] )
		pointsMap[ BossMedalConsts.Type_Person ] = tonumber( map[3] )
		pointsMap[ BossMedalConsts.Type_Digong ] = tonumber( map[4] )
		pointsMap[ BossMedalConsts.Type_Yewai ]  = tonumber( map[2] )
	end
	return pointsMap
end

local activeConsume
function BossMedalConsts:GetActiveConsume()
	if not activeConsume then
		activeConsume = t_consts[149].val1
	end
	return activeConsume
end

function BossMedalConsts:GetActiveItem()
	local cfg = t_consts[149];
	if not cfg then return end
	local item = t_item[cfg.val2];
	if not item then return end
	return item.id,cfg.val3;
end