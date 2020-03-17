--[[
打宝活力值常量
2015年1月22日16:44:15
haohu
]]

_G.DropValueConsts = {};

-- 普通掉宝&超级掉宝价格临界值
DropValueConsts.SuperDropPrice = 50;

-- 基础掉宝率 100 表示 100%
DropValueConsts.BasicDropRate = 100;

-- 活力值上限度
local DropValueCeiling;
function DropValueConsts:GetDVCeiling()
	if not DropValueCeiling then
		DropValueCeiling = t_consts[34].val2;
	end
	return DropValueCeiling;
end

-- 活力值每日增加量
local DropValueDailyGain;
function DropValueConsts:GetDVDailyGain()
	if not DropValueDailyGain then
		DropValueDailyGain = t_consts[34].val1;
	end
	return DropValueDailyGain;
end

-- 打宝活力值
-- 消耗速率等级-> VIP等级、增加的掉宝倍率 对应表
-- 结构：
--{  [level] = {level, vipLvl, multiple}  }
local dropValueMap;
function DropValueConsts:GetDropValueMap()
	if not dropValueMap then
		local map = {};
		local mapStr = t_consts[34].param;
		local mapStrTab = split(mapStr, "#");
		for i, str in pairs(mapStrTab) do
			local vo = {};
			local level = i;
			local vipLvl, multiple = unpack( split(str, ",") );
			vo.level    = level;
			vo.vipLvl   = vipLvl;
			vo.multiple = multiple;
			map[level]  = vo;
		end
		if not map[0] then
			local _vo = {};
			_vo.level    = 0;
			_vo.vipLvl   = 0;
			_vo.multiple = 0;
			map[0] = _vo;
		end
		dropValueMap = map;
	end
	return dropValueMap;
end

function DropValueConsts:GetDropValueInfo( level )
	local dropValueMap = self:GetDropValueMap();
	local info = dropValueMap[level];
	if not info then return end
	return info.vipLvl, info.multiple;
end

function DropValueConsts:GetSuperDrop()
	return 0;
end

function  DropValueConsts:GetVipDrop()
	return 0;
end
