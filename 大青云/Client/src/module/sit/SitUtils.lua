--[[
打坐 工具类
郝户
2014年11月12日15:39:50
]]

_G.SitUtils = {};

-- 将秒转为00:00:00格式
function SitUtils:ParseTime(time)
	if not time then time = 0; end
	local hour, min, sec = CTimeFormat:sec2format(time);
	return string.format("%02d:%02d:%02d", hour, min, sec);
end

-- 根据人数获取阵法名称
function SitUtils:GetFormationName(roleNum)
	return SitConsts.FormationMap[roleNum];
end

-- 根据人数获取阵法加成
function SitUtils:GetFormationBonus( roleNum )
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	local cfg = t_zazen[level];
	return cfg and cfg[ 'num_'..roleNum ] or 0;
end

-- 获取主城打坐加成
function SitUtils:GetMajorCityBonus( inMajorCity )
	return inMajorCity and SitConsts:GetMajorCityBonus() or 0
end

-- 获取打坐副本打坐加成
function SitUtils:GetZazenDungeonBonus()
	local zazenDungeonBonus = RandomQuestController:GetZazenDungeonBonus()
	return 100 * zazenDungeonBonus
end

-- 获取帮派加持
function SitUtils:GetGuildBonus( guildAdditionLv )
	if not guildAdditionLv or guildAdditionLv == 0 then return 0 end
	local guildAdditionCfg = _G.t_guildwash[ guildAdditionLv ]
	if not guildAdditionCfg then
		Error( string.format( "cannot guild addition config in t_guildwash. lv:%s", guildAdditionLv ) )
		return
	end
	return guildAdditionCfg.zazenadd
end

function SitUtils:GetVipBonus()
	local vbonus = VipController:GetSupremeVipLevel() > 0 and 1 or 0
	return vbonus * 100
end

-- 获取总加成
function SitUtils:GetBonus()
	-- 根据人数获取阵法加成
	local roleNum          = SitModel:GetRoleNum();
	local formationBonus   = SitUtils:GetFormationBonus( roleNum )
	-- 获取主城打坐加成
	local isInSitArea      = SitController:IsInSitArea()
	local sitAreaBonus     = SitUtils:GetMajorCityBonus( isInSitArea )
	-- 获取帮派加持
	local guildAdditionLv  = UnionModel:GetAdditionLv() -- 帮派加持等级
	local guildBonus       = SitUtils:GetGuildBonus( guildAdditionLv )
	-- 获取打坐副本打坐加成
	local zazenDungeonBonus = SitUtils:GetZazenDungeonBonus()
	-- 获取vip打坐加成
	local vipBonus = SitUtils:GetVipBonus()
	-- 总计
	return formationBonus + sitAreaBonus + guildBonus + zazenDungeonBonus + vipBonus
end