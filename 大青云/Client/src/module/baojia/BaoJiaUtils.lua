--[[
宝甲:工具类
2015年4月28日17:12:38
zhangshuhui
]]

_G.BaoJiaUtils = {};


-- 获取宝甲战斗力
-- @param level: 宝甲等级
function BaoJiaUtils:GetFight( level )
	local attrList = {};
	local attrMap = self:GetBaoJiaAttrMap(level);
	if not attrMap then return end
	for attrType, attrValue in pairs(attrMap) do
		local vo = {};
		vo.type = AttrParseUtil.AttMap[attrType];
		vo.val = attrValue;
		table.push(attrList, vo);
	end
	return EquipUtil:GetFight( attrList );
end

-- 获取宝甲属性增量(键: "att", "def", "cri", "hp", "crivalue" )
function BaoJiaUtils:GetAttrIncrementMap( level )
	if level == BaoJiaConsts.MaxLvl then return; end
	local cfg = t_baojia[level];
	if not cfg then return; end
	local nextCfg = t_baojia[level + 1];
	if not nextCfg then return; end
	local incrementMap = {};
	local attrPerPrfcncyLvl; -- 每熟练度级别增加的属性
	local attr; -- 神兵等阶增加的属性
	local currentLvlMaxAttr; -- 当前神兵等阶的最高增加属性
	local nextLvlAttr -- 下一级神兵增加的属性
	for _, type in pairs( BaoJiaConsts.Attrs ) do
		currentLvlMaxAttr = cfg[type] or 0;
		nextLvlAttr = nextCfg[type] or 0;
		incrementMap[type] = nextLvlAttr - currentLvlMaxAttr;
	end
	return incrementMap;
end

--获取列表VO
function BaoJiaUtils:GetSkillListVO(skillId, lvl)
	local vo = {};
	vo.skillId = skillId;
	local cfg = t_passiveskill[skillId];
	if cfg then
		vo.name = cfg.name;
		vo.lvl = lvl;
		if lvl == 0 then
			vo.lvlStr = StrConfig['skill101'];
		else
			local maxLvl = SkillUtil:GetSkillMaxLvl(skillId);
			vo.lvlStr = string.format( StrConfig['skill102'], lvl, maxLvl );
			local skillVO = SkillModel:GetSkill(skillId);
			if skillVO and lvl < maxLvl then
				vo.showLvlUp = self:GetSkillCanLvlUp(skillId);
			else
				vo.showLvlUp = false;
			end
		end
		vo.iconUrl = ResUtil:GetSkillIconUrl(cfg.icon);
	end
	return vo;
end

--获取技能是否可升级
function BaoJiaUtils:GetSkillCanLvlUp(skillId)
	local conditionlist = SkillUtil:GetLvlUpCondition(skillId, false);
	for i, vo in ipairs(conditionlist) do
		if not vo.state then
			return false;
		end
	end
	return true;
end

-- 获取宝甲的属性表 map[attrType] = attrValue
-- @param level :宝甲等阶
function BaoJiaUtils:GetBaoJiaAttrMap(level)
	local cfg = t_baojia[level];
	if not cfg then
		Error("cannot find config of baojia in t_baojia.lua.  level:".. level);
		return;
	end
	local attrMap = {};
	local attr; -- 神兵等阶增加的属性
	for _, type in pairs( BaoJiaConsts.Attrs ) do
		attrMap[type] = cfg[type] or 0;
	end
	return attrMap;
end
	