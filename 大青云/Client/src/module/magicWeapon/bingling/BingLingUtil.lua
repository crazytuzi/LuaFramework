--[[
兵灵:工具类

]]

_G.BingLingUtils = {};

-- 根据id得到level
function BingLingUtils:GetLevelByid(id)
	for i,vo in ipairs(BingLingModel:GetBingLingList()) do
		if toint(vo.id/1000) == id then
			return vo.id;
		end
	end
	return 0;
end

function BingLingUtils:GetBingLingVO(id)
	for i,vo in ipairs(BingLingModel:GetBingLingList()) do
		if toint(vo.id/1000) == id then
			return vo;
		end
	end
	return nil;
end

--是否达到当前激活上限
function BingLingUtils:GetIsCurActiveMax()
	local mwlevel = MagicWeaponModel:GetLevel()
	local shenbingcfg = t_shenbing[mwlevel];
	if shenbingcfg then
		if #BingLingModel:GetBingLingList() >= shenbingcfg.bingling_num then
			return true;
		end
	end
	return false;
end

--得到当前激活状态；返回 状态，神兵等阶，可激活数量
function BingLingUtils:GetActiveState()
	local mwlevel = MagicWeaponModel:GetLevel()
	for i=1,99 do
		local shenbingcfg = t_shenbing[i];
		if shenbingcfg then
			--神兵等阶不足
			if  mwlevel < i and shenbingcfg.bingling_num == 1 then
				return 1,i,shenbingcfg.bingling_num;
			elseif mwlevel == i and shenbingcfg.bingling_num == 1 then
				--达到条件，但还未激活兵灵
				if #BingLingModel:GetBingLingList() < shenbingcfg.bingling_num then
					return 2,i,shenbingcfg.bingling_num - #BingLingModel:GetBingLingList();
				else
					--不能继续激活,下一阶激活
					return 3,i+1,1;
				end
			else
				if shenbingcfg.bingling_num > 1 then
					--得到条件，但还未激活兵灵
					local sbcfg = t_shenbing[mwlevel];
					if sbcfg then
						if sbcfg.bingling_num > #BingLingModel:GetBingLingList() then
							return 2,mwlevel,sbcfg.bingling_num - #BingLingModel:GetBingLingList();
						elseif sbcfg.bingling_num == #BingLingModel:GetBingLingList() then
							--不能继续激活,下一阶激活
							return 3,mwlevel+1,1;
						end
					end
				end
			end
		else
			break;
		end
	end
end

-- 根据id得到道具信息
function BingLingUtils:GetBingLingToolByid(id)
	local level = self:GetLevelByid(id);
	if level == 0 then
		level = id * 1000;
	end
	local cfg = t_shenbingbingling[level];
	if not cfg then return; end
	return cfg.levelItem;
end

-- 获取兵灵战斗力
-- 包含属性丹
-- @param level: 兵灵等级
function BingLingUtils:GetFight( level )
	local attrList = {};
	local attrMap = self:GetBingLingAttrMap(level);
	if not attrMap then return end
	for attrType, attrValue in pairs(attrMap) do
		local vo = {};
		vo.type = AttrParseUtil.AttMap[attrType];
		vo.val = attrValue;
		table.push(attrList, vo);
	end
	return EquipUtil:GetFight( attrList );
end

-- 获取兵灵属性增量ly
function BingLingUtils:GetAttrIncrementMap( level, id )
	if level == BingLingModel:GetMaxLevel(id) then return; end
	local cfg = t_shenbingbingling[level];
	if not cfg then return; end
	local nextCfg = t_shenbingbingling[level + 1];
	if not nextCfg then return; end
	local attrMap = AttrParseUtil:ParseAttrToMap( cfg.attr );
	local attrMapNext = AttrParseUtil:ParseAttrToMap( nextCfg.attr );
	
	local incrementMap = {};	
	local currentLvlMaxAttr; -- 兵灵等阶增加的属性
	local nextLvlAttr -- 下一级兵灵增加的属性
	for _, type in pairs( BingLingConsts:GetAttrs(id) ) do
		currentLvlMaxAttr = attrMap[type] or 0;
		nextLvlAttr = attrMapNext[type] or 0;
		incrementMap[type] = nextLvlAttr - currentLvlMaxAttr;
		--百分比加成
		local attrType = AttrParseUtil.AttMap[type];
		local addP = 0;
		if Attr_AttrPMap[attrType] then
			addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[attrType]];
		end
		if type == "crivalue" then
			incrementMap[type] = incrementMap[type] * (1+addP);
		else
			incrementMap[type] = toint(incrementMap[type] * (1+addP));
		end
	end
	return incrementMap;
end

--获取列表VO
function BingLingUtils:GetSkillListVO(skillId, lvl)
	local vo = {};
	vo.skillId = skillId;
	local cfg = t_passiveskill[skillId];
	if not cfg then
		cfg = t_skill[skillId];
	end
	if cfg then
		vo.name = cfg.name;
		vo.lvl = lvl;
		if lvl == 0 then
			vo.lvlStr = StrConfig['skill101'];
			vo.iconUrl = ImgUtil:GetGrayImgUrl(ResUtil:GetSkillIconUrl(cfg.icon))
		else
			local maxLvl = SkillUtil:GetSkillMaxLvl(skillId);
			vo.lvlStr = string.format( StrConfig['skill102'], lvl, maxLvl );
			local skillVO = SkillModel:GetSkill(skillId);
			if skillVO and lvl < maxLvl then
				vo.showLvlUp = self:GetSkillCanLvlUp(skillId);
			else
				vo.showLvlUp = false;
			end
			vo.iconUrl = ResUtil:GetSkillIconUrl(cfg.icon);
		end
	end
	return vo;
end

--获取技能是否可升级
function BingLingUtils:GetSkillCanLvlUp(skillId)
	local conditionlist = SkillUtil:GetLvlUpConditionForSkill(skillId, false);
	for i, vo in ipairs(conditionlist) do
		if not vo.state then
			return false;
		end
	end
	return true;
end

-- 获取兵灵的属性表 map[attrType] = attrValue ly
-- @param level :兵灵等阶
function BingLingUtils:GetBingLingAttrMap(level)
	local cfg = t_shenbingbingling[level];
	if not cfg then
		Error("cannot find config of BingLing in t_shenbingbingling.lua.  level:".. level);
		return;
	end
	
	local map = {};
	for _, attrName in pairs(BingLingConsts:GetAttrs(toint(level/1000))) do
		map[attrName] = 0;
	end
	
	local attrMap = {};
	attrMap = AttrParseUtil:ParseAttrToMap( cfg.attr );
	for name, attrValue in pairs(attrMap) do
		if not map[name] then
			Debug( string.format('Requir attribute "%s" in BingLingConsts.Attrs.', name) );
		else
			map[name] = attrValue;
			--百分比加成
			local attrType = AttrParseUtil.AttMap[name];
			local addP = 0;
			if Attr_AttrPMap[attrType] then
				addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[attrType]];
			end
			if name == "crivalue" then
				map[name] = map[name] * (1+addP);
			else
				map[name] = toint(map[name] * (1+addP));
			end
		end
	end
	return map;
end

--获取列表VO
function BingLingUtils:GetSkillListVO(skillId, lvl)
	local vo = {};
	vo.skillId = skillId;
	local cfg = t_passiveskill[skillId];
	if not cfg then
		cfg = t_skill[skillId];
	end
	if cfg then
		vo.name = cfg.name;
		vo.lvl = lvl;
		if lvl == 0 then
			vo.lvlStr = StrConfig['skill101'];
			vo.iconUrl = ImgUtil:GetGrayImgUrl(ResUtil:GetSkillIconUrl(cfg.icon))
		else
			local maxLvl = SkillUtil:GetSkillMaxLvl(skillId);
			vo.lvlStr = string.format( StrConfig['skill102'], lvl, maxLvl );
			local skillVO = SkillModel:GetSkill(skillId);
			if skillVO and lvl < maxLvl then
				vo.showLvlUp = self:GetSkillCanLvlUp(skillId);
			else
				vo.showLvlUp = false;
			end
			vo.iconUrl = ResUtil:GetSkillIconUrl(cfg.icon);
		end
	end
	return vo;
end

--获得属性总加成
function BingLingUtils:GetAllAttrMap()
	local map = {};
	for i,vo in ipairs(BingLingModel:GetBingLingList()) do
		if vo.id > 0 then
			local cfg = t_shenbingbingling[vo.id];
			if cfg then
				local attrMap = AttrParseUtil:ParseAttrToMap(cfg.attr);
				for name, attrValue in pairs(attrMap) do
					if not map[name] then
						map[name] = attrValue;
					else
						map[name] = map[name] + attrValue;
					end
				end
			end
		end
	end
	return map;
end

--根据技能id得到等阶
function BingLingUtils:GetLevelBySkillId(skillId)
	for i,vo in ipairs(t_shenbingbingling) do
		if vo.skill == skillId then
			return self:GetLevelByid(toint(vo.level / 1000)) % 1000;
		end
	end
	return 0;
end 