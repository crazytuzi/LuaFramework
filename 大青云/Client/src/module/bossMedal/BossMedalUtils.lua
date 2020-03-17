--[[
boss 勋章 工具
haohu
2015-11-19 17:35:00
]]

_G.BossMedalUtils = {}

function BossMedalUtils:GetConsumePoints(level)
	if level <= 0 then
		return BossMedalConsts.ActivePoints
	end
	if level < BossMedalConsts:GetMaxLevel() then
		local cfg = t_bosshuizhang[level]
		return cfg.consum
	end
	Debug("wrong level")
	return nil
end

function BossMedalUtils:GetStarGrowValue(level)
	local cfg = t_bosshuizhang[level]
	return cfg and cfg.star
end

function BossMedalUtils:GetAttrMap(level, star)
	local index = (level * 100 + star)
	local cfg = t_bossMediaAttr[index]
	if not cfg then return end
	return AttrParseUtil:ParseAttrToMap(cfg.star_attr)
end

function BossMedalUtils:GetAttrIncrementMap( level, star )
	local levelA = BossMedalModel:GetLevel()
	if levelA <= 0 then
		Error("wrong bosshuizhang level, must > 0")
		return
	end
	local starA = BossMedalModel:GetStar()
	local attrMapA = BossMedalUtils:GetAttrMap(levelA, starA)
	local attrMapB = BossMedalUtils:GetAttrMap(level, star)
	for attrType, attr in pairs(attrMapB) do
		attrMapA[attrType] = attr - attrMapA[attrType]
	end
	return attrMapA
end