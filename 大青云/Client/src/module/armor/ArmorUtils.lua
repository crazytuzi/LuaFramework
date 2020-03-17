--[[
宝甲:工具类
2015年1月28日16:17:35
haohu
]]

_G.ArmorUtils = {};


-- 获取mwLvl级宝甲, prfcncyLvl级熟练度的熟练度上限值
function ArmorUtils:GetProficiencyCeiling( mwLvl, prfcncyLvl )
	local cfg = t_newbaojia[mwLvl];
	local ceilingTab = cfg and split( cfg.proficiency, "#" );
	local tableRank = math.min( prfcncyLvl + 1, ArmorConsts.MaxLvlProficiency );
	return ceilingTab and tonumber( ceilingTab[tableRank] );
end


-- 获取宝甲战斗力
-- 增加属性丹,增加百分比属性加成,增加VIP属性加成
-- @param level: 宝甲等级
-- @param lvlPrfcncy:熟练度等阶
function ArmorUtils:GetFight( level, lvlPrfcncy )
	local attrList = {};
	if not lvlPrfcncy then lvlPrfcncy = 0; end
	local attrMap = ArmorUtils:GetMagicWeaponAttrMap(level, lvlPrfcncy);
	if not attrMap then return end
	for attrType, attrValue in pairs(attrMap) do
		local vo = {};
		vo.type = AttrParseUtil.AttMap[attrType];
		vo.val = attrValue;
		--百分比加成,VIP加成
		local addP = 0;
		if Attr_AttrPMap[vo.type] then
			addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[vo.type]];
		end
		local zzRate = ZiZhiUtil:GetZZTotalAddPercent(1);
		vo.val = vo.val * (1 + addP + zzRate)
--		local vipUPRate = VipController:GetShengbingLvUp()/100
--		vo.val = vo.val * (1+addP+vipUPRate);
		table.push(attrList, vo);
	end
	local attrSXDMap = AttrParseUtil:ParseAttrToMap(t_consts[331].param);--属性丹
	for _, type in pairs( ArmorConsts.Attrs ) do
		attrMap[type] = attrMap[type] + (attrSXDMap[type] or 0) * ArmorModel:GetPillNum();
	end
	return PublicUtil:GetFigthValue( attrList );
end

-- 获取宝甲属性增量(键: "att", "def", "cri", "hp", "crivalue" )
function ArmorUtils:GetAttrIncrementMap( level )
	if level == ArmorConsts:GetMaxLevel() then return; end
	local cfg = t_newbaojia[level];
	if not cfg then return; end
	local nextCfg = t_newbaojia[level + 1];
	if not nextCfg then return; end
	local attrPerPrfcncyLvlMap = AttrParseUtil:ParseAttrToMap(cfg.att1);
	local incrementMap = {};
	local attrPerPrfcncyLvl; -- 每熟练度级别增加的属性
	local attr; -- 宝甲等阶增加的属性
	local currentLvlMaxAttr; -- 当前宝甲等阶的最高增加属性
	local nextLvlAttr -- 下一级宝甲增加的属性
	for _, type in pairs( ArmorConsts.Attrs ) do
		attrPerPrfcncyLvl = attrPerPrfcncyLvlMap[type] or 0;
		attr = cfg[type] or 0;
--		currentLvlMaxAttr = attrPerPrfcncyLvl * ArmorConsts.MaxLvlProficiency + attr
		currentLvlMaxAttr = attr
		nextLvlAttr = nextCfg[type] or 0;
		incrementMap[type] = nextLvlAttr - currentLvlMaxAttr;
		--
		local attrType = AttrParseUtil.AttMap[type];
		local addP = 0;
		if Attr_AttrPMap[attrType] then
			addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[attrType]];
		end
--		local vipUPRate = VipController:GetShengbingLvUp()/100
--		incrementMap[type] = incrementMap[type] * (1+addP+vipUPRate);
	end
	return incrementMap;
end

--获取列表VO
function ArmorUtils:GetSkillListVO(skillId, lvl)
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
		local url = ResUtil:GetSkillIconUrl(cfg.icon);
		vo.iconUrl = lvl > 0 and url or ImgUtil:GetGrayImgUrl(url)
	end
	return vo;
end

--获取技能是否可升级
function ArmorUtils:GetSkillCanLvlUp(skillId)
	local conditionlist = SkillUtil:GetLvlUpConditionForSkill(skillId, false);
	for i, vo in ipairs(conditionlist) do
		if not vo.state then
			return false;
		end
	end
	return true;
end

-- 获取宝甲的属性表 map[attrType] = attrValue
-- 包含属性丹 addby lizhuangzhuang 2015年11月7日23:11:54
-- @param level :宝甲等阶
-- @param lvlPrfcncy:熟练度等阶
function ArmorUtils:GetMagicWeaponAttrMap(level, lvlPrfcncy)
	local cfg = t_newbaojia[level];
	if not cfg then
		-- Error( string.format( "cannot find config of shenbing in t_newbaojia.lua.  level:%s", level ) );
		-- Debug( debug.traceback() )
		return;
	end
	local attrPerPrfcncyLvlMap = AttrParseUtil:ParseAttrToMap(cfg.att1);
	local attrMap = {};
	local attrPerPrfcncyLvl; -- 每熟练度级别增加的属性
	local attr; -- 宝甲等阶增加的属性
	local attrSXDMap = AttrParseUtil:ParseAttrToMap(t_consts[331].param);--属性丹
	for _, type in pairs( ArmorConsts.Attrs ) do
		attrPerPrfcncyLvl = attrPerPrfcncyLvlMap[type] or 0;
		attr = cfg[type] or 0;
		attrMap[type] = attrPerPrfcncyLvl * lvlPrfcncy + attr;
--		attrMap[type] = attrMap[type] + (attrSXDMap[type] or 0) * ArmorModel:GetPillNum();
	end
	return attrMap;
end

function ArmorUtils:GetConsumeItem(level)
	local cfg = t_newbaojia[level]
	if not cfg then return end
	local itemConsume1 = cfg.proce_consume
	local itemConsume2 = cfg.proce_consume2
	local itemConsume3 = cfg.proce_consume3
	local hasEnoughItem = function( item, num )
		return BagModel:GetItemNumInBag( item ) >= num
	end
	local itemId, itemNum, isEnough
	if hasEnoughItem( itemConsume1[1], itemConsume1[2] ) then
		itemId = itemConsume1[1]
		itemNum = itemConsume1[2]
		isEnough = true
	elseif hasEnoughItem( itemConsume2[1], itemConsume2[2] ) then
		itemId = itemConsume2[1]
		itemNum = itemConsume2[2]
		isEnough = true
	elseif hasEnoughItem( itemConsume3[1], itemConsume3[2] ) then
		itemId = itemConsume3[1]
		itemNum = itemConsume3[2]
		isEnough = true
	else
		itemId = itemConsume1[1]
		itemNum = itemConsume1[2]
		isEnough = false
	end
	return itemId, itemNum, isEnough
end

-- function ArmorUtils:GetConsumeItem(level)
-- 	local cfg = t_newbaojia[level]
-- 	if not cfg then return end
-- 	local itemConsume = cfg.proce_consume
-- 	return itemConsume[1], itemConsume[2]
-- end

function ArmorUtils:GetConsumeMoney(level)
	local cfg = t_newbaojia[level]
	if not cfg then return end
	return cfg.proce_money
end

-----------------------------bing hun-----------------------------
function ArmorUtils:GetHunAttrMap()
	local map = {};
	for _, attrName in pairs(ArmorConsts.HunAttrs) do
		map[attrName] = 0;
	end
	
	local equipAddAttr = {};
	local nfight = 0;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Hun);
	if bagVO then
		for i,bagItem in pairs(bagVO.itemlist) do
			local tipsVO = ItemTipsVO:new();
			ItemTipsUtil:CopyItemDataToTipsVO(bagItem,tipsVO);
			equipAddAttr = EquipUtil:AddUpAttr(equipAddAttr,tipsVO:GetOriginAttrList());
		end
	end
	
	for i,vo in ipairs(equipAddAttr) do
		if vo.type == enAttrType.eaGongJi then
			map["att"] = vo.val;
		elseif vo.type == enAttrType.eaFangYu then
			map["def"] = vo.val;
		elseif vo.type == enAttrType.eaMaxHp then
			map["hp"] = vo.val;
		elseif vo.type == enAttrType.eaMingZhong then
			map["hit"] = vo.val;
		elseif vo.type == enAttrType.eaShanBi then
			map["dodge"] = vo.val;
		elseif vo.type == enAttrType.eaBaoJi then
			map["cri"] = vo.val;
		elseif vo.type == enAttrType.eaRenXing then
			map["defcri"] = vo.val;
		end
	end
	
	local grouplist = ArmorUtils:GetGroupHunList();
	if grouplist then
		for i,vo in pairs(grouplist) do
			if vo then
				if vo.count >= 3 then
					local attrGroupMap = AttrParseUtil:ParseAttrToMap(t_equipgroup[vo.groupid].attr3);
					for _, type in pairs( ArmorConsts.GroupAttrs ) do
						map[type] = map[type] + attrGroupMap[type];
					end
				end
				if vo.count >= 6 then
					local attrGroupMap = AttrParseUtil:ParseAttrToMap(t_equipgroup[vo.groupid].attr6);
					for _, type in pairs( ArmorConsts.GroupAttrs ) do
						map[type] = map[type] + attrGroupMap[type];
					end
				end
				if vo.count >= 9 then
					local attrGroupMap = AttrParseUtil:ParseAttrToMap(t_equipgroup[vo.groupid].attr9);
					for _, type in pairs( ArmorConsts.GroupAttrs ) do
						map[type] = map[type] + attrGroupMap[type];
					end
				end
			end
		end
	end
	local attrList = {};
	for _, attrName in pairs(ArmorConsts.HunAttrs) do
		if map[attrName] and map[attrName] > 0 then
			local vo = {};
			vo.type = AttrParseUtil.AttMap[attrName];
			vo.val = map[attrName];
			table.push(attrList, vo);
		end
	end
	nfight = EquipUtil:GetFight(attrList);
	return nfight, map;
end

--返回是否开启，几阶开启
function ArmorUtils:GetHunStateByPos(pos)
	local level = ArmorModel:GetLevel();
	for i=1,99 do
		local cfg = t_newbaojia[i];
		if cfg then
			if cfg.binghun_num >= pos+1 then
				if level >= i then
					return true,level;
				else
					return false,i;
				end
			end
		else
			break;
		end
	end
	
	return false,0;
end

--得到套装list
function ArmorUtils:GetGroupHunList()
	local grouplist = {};
	local list = BagUtil:GetBagItemList(BagConsts.BagType_Hun, BagConsts.ShowType_All);
	for i, vo in ipairs(list) do
		if vo.hasItem then
			local equipvo = t_equip[vo.tid];
			if equipvo and equipvo.groupId > 0 then
				if not grouplist[equipvo.groupId] then
					if equipvo.pos >= BagConsts.Equip_SB_Hun0 and equipvo.pos <= BagConsts.Equip_SB_Hun8 then
						local groupvo = {};
						groupvo.taoid = 1;
						groupvo.count = 1;
						groupvo.groupid = equipvo.groupId;
						grouplist[equipvo.groupId] = groupvo;
					end
				else
					grouplist[equipvo.groupId].count = grouplist[equipvo.groupId].count + 1;
				end
			end
		end
	end
	
	return grouplist;
end