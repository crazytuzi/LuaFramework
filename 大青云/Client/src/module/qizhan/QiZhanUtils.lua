--[[
骑战:工具类

]]

_G.QiZhanUtils = {};
QiZhanUtils.PreFix = 1001000
-- 获取骑战战斗力
-- 包含属性丹
-- @param level: 骑战等级
function QiZhanUtils:GetFight( level )
	local attrList = {};
	local attrMap = self:GetQiZhanAttrMap(level);
	if not attrMap then return end
	local attrSXDMap = AttrParseUtil:ParseAttrToMap(t_consts[146].param);
	for attrType, attrValue in pairs(attrMap) do
		local vo = {};
		vo.type = AttrParseUtil.AttMap[attrType];
		vo.val = attrValue;
		--属性丹
		vo.val = vo.val + (attrSXDMap[attrType] or 0) * QiZhanModel:GetPillNum();
		table.push(attrList, vo);
	end
	return EquipUtil:GetFight( attrList );
end

-- 获取骑战属性增量ly
function QiZhanUtils:GetAttrIncrementMap( level )
	if level == QiZhanModel:GetMaxLevel() then return; end
	local cfg = t_ridewar[level];
	if not cfg then return; end
	local nextCfg = t_ridewar[level + 1];
	if not nextCfg then return; end
	local attrMap = AttrParseUtil:ParseAttrToMap( cfg.add_attr );
	local attrMapNext = AttrParseUtil:ParseAttrToMap( nextCfg.add_attr );
	
	local incrementMap = {};	
	local currentLvlMaxAttr; -- 骑战等阶增加的属性
	local nextLvlAttr -- 下一级骑战增加的属性
	for _, type in pairs( QiZhanConsts.Attrs ) do
		currentLvlMaxAttr = attrMap[type] or 0;
		nextLvlAttr = attrMapNext[type] or 0;
		incrementMap[type] = nextLvlAttr - currentLvlMaxAttr;
		--百分比加成
		local attrType = AttrParseUtil.AttMap[type];
		local addP = 0;
		if Attr_AttrPMap[attrType] then
			addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[attrType]];
		end
		incrementMap[type] = toint(incrementMap[type] * (1+addP));
	end
	return incrementMap;
end

--获取列表VO
function QiZhanUtils:GetSkillListVO(skillId, lvl)
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
function QiZhanUtils:GetSkillCanLvlUp(skillId)
	local conditionlist = SkillUtil:GetLvlUpConditionForSkill(skillId, false);
	for i, vo in ipairs(conditionlist) do
		if not vo.state then
			return false;
		end
	end
	return true;
end

-- 获取骑战的属性表 map[attrType] = attrValue ly
-- @param level :骑战等阶
function QiZhanUtils:GetQiZhanAttrMap(level)
	local cfg = t_ridewar[level];
	if not cfg then
		Error("cannot find config of QiZhan in t_ridewar.lua.  level:".. level);
		return;
	end
	local map = {};
	for _, attrName in pairs(QiZhanConsts.Attrs) do
		map[attrName] = 0;
	end
	
	local attrMap = {};
	attrMap = AttrParseUtil:ParseAttrToMap( cfg.add_attr );
	for name, attrValue in pairs(attrMap) do
		if not map[name] then
			Debug( string.format('Requir attribute "%s" in QiZhanConsts.Attrs.', name) );
		else
			map[name] = attrValue;
		end
	end
	return map;
end

--骑战是否激活
function QiZhanUtils:GetIsQiZhanActive()
	local level = QiZhanModel:GetLevel();
	if level > 0 then
		return true;
	end
	return false;
end

-- 骑战属性丹
function QiZhanUtils:GetQiZhanSXDAttrMap()
	local map = {};
	for _, attrName in pairs(QiZhanConsts.Attrs) do
		map[attrName] = 0;
	end
	local attrSXDMap = AttrParseUtil:ParseAttrToMap(t_consts[146].param);
	for _, type in pairs( QiZhanConsts.Attrs ) do
		map[type] = (attrSXDMap[type] or 0) * QiZhanModel:GetPillNum();
	end
	return map;
end

function QiZhanUtils:GetConsumeItem(level)
	local cfg = t_ridewar[level]
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

-----------------------------骑印-----------------------------
function QiZhanUtils:GetQiYinAttrMap()
	local map = {};
	for _, attrName in pairs(QiZhanConsts.QiZhanAttrs) do 
		map[attrName] = 0;
	end
	
	local equipAddAttr = {};
	local nfight = 0;
	local bagVO = BagModel:GetBag(BagConsts.BagType_QiZhan);
	if bagVO then
		for i,bagItem in pairs(bagVO.itemlist) do
			local tipsVO = ItemTipsVO:new();
			ItemTipsUtil:CopyItemDataToTipsVO(bagItem,tipsVO);
			equipAddAttr = EquipUtil:AddUpAttr(equipAddAttr,tipsVO:GetOriginAttrList());
			
			nfight = nfight + EquipUtil:GetFight(tipsVO:GetOriginAttrList());
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
	
	local grouplist = QiZhanUtils:GetGroupZhenYanList();
	if grouplist then
		for i,vo in pairs(grouplist) do
			if vo then
				if vo.count == 3 then
					local attrGroupMap = AttrParseUtil:ParseAttrToMap(t_equipgroup[vo.groupid].attr3);
					for _, type in pairs( QiZhanConsts.GroupAttrs ) do
						if map[type] and attrGroupMap[type] then
							map[type] = map[type] + attrGroupMap[type];
						end
					end
				end
			end
		end
	end
	
	local attrList = {};
	if map then 
		for attrType, attrValue in pairs(map) do
			local vo = {};
			vo.type = AttrParseUtil.AttMap[attrType];
			vo.val = attrValue;			
			table.push(attrList, vo);
		end		
		nfight = EquipUtil:GetFight( attrList ) or 0		
	end		
	return nfight, map;
end
--返回是否开启，几阶开启
function QiZhanUtils:GetQiYinStateByPos(pos)
	local minValue = 100
	for k, v in pairs (_G.t_ridewar) do		
		if not v.moling then v.moling = 0 end
		if v.moling >= (pos+1) then				
			if v.qzlevel < minValue then
				minValue = v.qzlevel				
			end
		end
	end
	
	local level = QiZhanModel:GetLevel();
	local cfg = t_ridewar[level]
	local lv = 0
	if cfg then lv = cfg.qzlevel end
	-- FPrint('孔'..(pos+1)..'开启等级'..minValue..','..lv)
	if lv >= minValue then
		return true, minValue	
	end
	
	return false, minValue	
end
--得到套装list
function QiZhanUtils:GetGroupZhenYanList()
	local grouplist = {};
	local list = BagUtil:GetBagItemList(BagConsts.BagType_QiZhan,BagConsts.ShowType_All);
	
	for i, vo in ipairs(list) do
		if vo.hasItem then
			local equipvo = t_equip[vo.tid];
			if equipvo and equipvo.groupId > 0 then
				if not grouplist[equipvo.groupId] then
					if equipvo.pos >= BagConsts.Equip_QZ_ZhenYan0 and equipvo.pos <= BagConsts.Equip_QZ_ZhenYan2 then
						local groupvo = {};
						groupvo.taoid = 1;
						groupvo.count = 1;
						groupvo.groupid = equipvo.groupId;
						grouplist[equipvo.groupId] = groupvo;
					elseif equipvo.pos >= BagConsts.Equip_QZ_ZhenYan3 and equipvo.pos <= BagConsts.Equip_QZ_ZhenYan5 then
						local groupvo = {};
						groupvo.taoid = 2;
						groupvo.count = 1;
						groupvo.groupid = equipvo.groupId;
						grouplist[equipvo.groupId] = groupvo;
					elseif equipvo.pos >= BagConsts.Equip_QZ_ZhenYan6 and equipvo.pos <= BagConsts.Equip_QZ_ZhenYan8 then
						local groupvo = {};
						groupvo.taoid = 3;
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
	-- FTrace(grouplist, '套装属性')
	return grouplist;
end