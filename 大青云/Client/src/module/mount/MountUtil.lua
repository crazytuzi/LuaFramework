--[[
坐骑Util
zhangshuhui
2014年11月17日16:12:24
]]

_G.MountUtil = {};
--根据阶级和职业得到坐骑id
function MountUtil:GetModelIdByLevel(level,prof)
	if level == 0 then
		return 0
	end
	
	-- 一般坐骑
	if level < MountConsts.SpecailDownid then
		local modelinfo = t_horse[level]
		if modelinfo == nil then
			print("Waring:Error mount level.Level="..level);
			return 0;
		end
		return modelinfo["model"..prof]
	--特殊坐骑
	elseif level < MountConsts.LingShouSpecailDownid then
		local modelinfo = t_horseskn[level]
		if modelinfo == nil then
			print("Waring:Error mount level.Level="..level);
			return 0;
		end
		return modelinfo["model"..prof]
	--灵兽坐骑
	 else
	-- 	local modelinfo = t_horselingshou[level]
	 	if modelinfo == nil then
	 		print("Waring:Error mount level.Level="..level);
			return 0;
	 	end
	-- 	return modelinfo.model
	end
end

--得到坐骑nameIcon
function MountUtil:GetMountinfo(mountId)
	--普通坐骑
	if mountId < MountConsts.SpecailDownid then
		local mountInfo = t_horse[mountId]
		if mountInfo == nil then
			return
		end
		
		return mountInfo
	--特殊坐骑
	elseif mountId < MountConsts.LingShouSpecailDownid then
		local mountInfo = t_horseskn[mountId]
		if mountInfo == nil then
			return
		end
		
		return mountInfo
	--灵兽坐骑
	 else
	-- 	local mountInfo = t_horselingshou[mountId]
	 	if mountInfo == nil then
	 		Error("Cannot find config of mountutil. mountId:"..mountId);
	 		return
	 	end
		
	-- 	return mountInfo
	end
end

--是否有足够银两进阶
function MountUtil:GetIsJinJieByYinLiang(level)
	local info = t_horse[level]
	 if info == nil then
	-- 	info = t_horselingshou[level]
     Error("Cannot find config of mountutil. level:"..level);
     return 
	 end
	
	--金币不够
	local playerinfo = MainPlayerModel.humanDetailInfo;
	if playerinfo.eaBindGold + playerinfo.eaUnBindGold < info.consume_money then
		return 0
	end
	
	return 1
end

--是否有足够道具进阶
function MountUtil:GetIsJinJieBytool(level)
	local itemId, itemNum, isEnough = self:GetConsumeItem(level);
	-- 材料充足
	if isEnough then
		return 1
	else
		return 0
	end
end

--是否有足够灵力进阶
function MountUtil:GetIsJinJieByLingLi(level)
	local info = t_horse[level]
	if info == nil then
	--	info = t_horselingshou[level]
	Error("Cannot find config of mountutil. level:"..level);
		if not info then
			return 0;
		end
	end
	local num = info.consume_item2[2];
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	if playerinfo.eaZhenQi >= num then
		return 1
	else
		return 0
	end
end

--还需要多少道具进阶
function MountUtil:GetNeedToolCount()
	local info = t_horse[MountModel.ridedMount.mountLevel]
	if info == nil then
		return 0;
	end
	local itemId = info.consume_item[1]
	
	local intemNum = BagModel:GetItemNumInBag(itemId)
	-- 材料充足
	if intemNum >= info.consume_item[2] then
		return 0
	else
		return info.consume_item[2] - intemNum;
	end
end

--是否有足够材料进阶
function MountUtil:GetIsJinJieByBagItem(level)
	local info = t_horse[MountModel.ridedMount.mountLevel]
	if info == nil then
	--	info = t_horselingshou[level]
		if not info then
			return 0;
		end
	end
	local itemId = info.consume_item[1]
	
	--金币不够
	local playerinfo = MainPlayerModel.humanDetailInfo;
	if self:GetIsJinJieByYinLiang(level) == 0 then
		return 0
	end
	
	-- 材料充足
	if self:GetIsJinJieBytool(level) == 1 then
		return 1
	else
		return 0
	end
end

--是否有足够元宝进阶
function MountUtil:GetIsJinJieByMoney(level)
	local info = t_horse[level]
	if info == nil then
		--info = t_horselingshou[level]
		if not info then
			return 0;
		end
	end
	local itemId = info.consume_item[1]
	
	local intemNum = BagModel:GetItemNumInBag(itemId)
	
	local buymax = MallUtils:GetMoneyShopMaxNum(itemId)
	if buymax == nil then
		return 0
	end
	
	-- 材料充足
	if buymax + intemNum >= info.consume_item[2] then
		return 1
	else
		return 0
	end
end

--得到进阶丹itemid
function MountUtil:GetCurJieJieItemId(level)
	local info = t_horse[MountModel.ridedMount.mountLevel]
	if info == nil then
		--info = t_horselingshou[level]
		if not info then
			return 0;
		end
	end
	return info.consume_item[1]
end

--得到属性丹数量
function MountUtil:GetJieJieItemNum(type)
	local sXDItemid = 0;
	if type == 1 then
		sXDItemid = t_consts[8].val1
	elseif type == 2 then
		sXDItemid = t_consts[117].val1
	elseif type == 3 then
		sXDItemid = t_consts[118].val1
	elseif type == 4 then
		sXDItemid = t_consts[119].val1
	elseif type == 5 then
		sXDItemid = t_consts[146].val1
	elseif type == 6 then
		sXDItemid = t_consts[169].val1
	elseif type == 7 then
		sXDItemid = t_consts[192].val1
	elseif type == 8 then
		sXDItemid = t_consts[196].val1
	elseif type == 9 then
		sXDItemid = t_consts[204].val1
	elseif type == 10 then 
		sXDItemid = t_consts[205].val1
	elseif type == 11 then
		sXDItemid = t_consts[317].val1
	elseif type == 12 then
		sXDItemid = t_consts[329].val1
	elseif type == 13 then
		sXDItemid = t_consts[331].val1
	elseif type == 14 then
		sXDItemid = t_consts[341].val1
	end
	if sXDItemid == nil then
		return
	end
	
	local intemNum = BagModel:GetItemNumInBag(sXDItemid)
	return intemNum
end

--得到坐骑名称图标
function MountUtil:GetMountIconName(mountId, name, prof)
	local info = self:GetMountinfo(mountId)
	if info == nil then
		return "";
	end
	
	--普通坐骑
	if mountId < MountConsts.SpecailDownid then
		return info[name..prof]
	--特殊坐骑
	elseif mountId < MountConsts.LingShouSpecailDownid then
		return info[name..prof]
	-- --灵兽坐骑
	-- else 
	-- 	return info[name]
	end
end

--得到坐骑剩余时间
function MountUtil:GetMountTime(mountId)
	local info = MountModel:GetMountVO(mountId)
	if info == nil then
		return 0
	end
	
	if info.time <= 0 then
		return info.time;
	end
	
	return info.time - GetServerTime();
end

--获取物品品质
function MountUtil:GetQualityUrl(itemId,isSmall)
    local cfg = t_equip[itemId] or t_item[itemId];
    local qURL = cfg and ResUtil:GetSlotQuality( cfg.quality, isSmall and nil or 54 ) or "";   --UIXinfaSkillBasic
    return qURL;
end

--坐骑皮肤属性
function MountUtil:GetMountSkinAttribute(mountId)
	local horseSpecaillist = {};
	--普通坐骑没有属性加成
	if mountId < MountConsts.SpecailDownid or mountId > MountConsts.LingShouSpecailDownid then
		return nil;
	end
	
	local str = t_horseskn[mountId].skin_attr;
	local formulaList = AttrParseUtil:Parse(str)
	for i,cfg in pairs(formulaList) do
		local vo = {};
		vo.type = cfg.type;
		vo.val = cfg.val; 
		table.push(horseSpecaillist,vo);
	end
	
	return horseSpecaillist;
end

--坐骑装备战斗力
function MountUtil:GetMountEquipAttribute()
	local equipAddAttr = {};
	local equipAddFight = {};
	local nfight = 0;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Horse);
	if bagVO then
		for i,bagItem in pairs(bagVO.itemlist) do
			local tipsVO = ItemTipsVO:new();
			ItemTipsUtil:CopyItemDataToTipsVO(bagItem,tipsVO);
			equipAddAttr = EquipUtil:AddUpAttr(equipAddAttr,tipsVO:GetOriginAttrList());
			
			nfight = nfight + bagItem:GetFight();
		end
	end
	
	local vo = {};
	vo.type = enAttrType.eaFight;
	vo.val = nfight;
	table.push(equipAddFight,vo);
	
	return EquipUtil:AddUpAttr(equipAddFight,equipAddAttr);
end

--加上个判断 是否为空
function MountUtil:AddUpAttrIsNil(list1,list2)
	if list1 == nil then
		return list2;
	end
	
	if list2 == nil then
		return list1;
	end

	
	return EquipUtil:AddUpAttr(list1,list2);
end

--坐骑基础属性
function MountUtil:GetMountBaseAttrList(mountlevel,star)
	local horselist = {};
	local horsestarlist = {};
	local horsesxdlist = {};
	local keyMap = {"att","def","hp","cri","defcri","dodge","hit","movespeed"};
	--坐骑等阶属性
	local horseCfg = t_horse[mountlevel];
	if not horseCfg then 
		Error("Cannot find config of MountUtil.[t_horse]mountlevel:"..mountlevel);
	end
	if horseCfg then
		local vo = {};
		vo.type = AttrParseUtil.AttMap["movespeed"];
		vo.val = horseCfg["speed"]
		table.push(horselist,vo);
	end
	-- local horselsCfg = t_horselingshou[mountlevel];
	-- if horselsCfg then
	-- 	local vo = {};
	-- 	vo.type = AttrParseUtil.AttMap["movespeed"];
	-- 	vo.val = horselsCfg["speed"]
	-- 	table.push(horselist,vo);
	-- end
	
	--坐骑星属性
	local horsestarindex = mountlevel * 100 + star;

	local starCfg = t_horsestar[horsestarindex];
	
	if not starCfg then 
		Error("Cannot find config of MountUtil t_horsestar[horsestarindex]:"..horsestarindex);
		return
	end
	local starAttrs = AttrParseUtil:Parse(starCfg.attr);
	if starCfg ~= nil then
		for index,attr in ipairs(keyMap) do
			for i,k in ipairs(starAttrs) do
				if attr == k.name then
					local vo = {};
					vo.type = k.type;
					vo.name = k.name;
					vo.val = k.val;
					table.push(horsestarlist,vo);
				end
			end
		end
	end

	local list = {};
	
	list = self:AddUpAttrIsNil(horselist,horsestarlist);
	
	-- 战斗力计算
	-- local equipAddFight = {};
	-- local vo = {};
	-- vo.type = enAttrType.eaFight;
	-- vo.val = EquipUtil:GetFight(list);
	-- table.push(equipAddFight,vo);
	return list
end

--坐骑其他属性
function MountUtil:GetMountOtherAttribute(mountlevel,star,isvip)
	if mountlevel < MountConsts.SpecailDownid then
		return self:GetPTMountOtherAttribute(mountlevel,star,isvip);
	else
		return self:GetLSMountOtherAttribute(mountlevel,star,isvip);
	end
end

--坐骑其他属性
function MountUtil:GetPTMountOtherAttribute(mountlevel,star,isvip)
	local attrlist = self:GetMountBaseAttrList(mountlevel,star);
	FTrace(attrlist,'基础属性')

    local zizhi=ZiZhiUtil:GetZZTotalAddPercent(6)
	local vipUp = VipController:GetMountLvUp()/100
	FPrint(vipUp)
	for k,attVO in ipairs(attrlist) do		
		--百分比加成,VIP加成
		local addP = 0;
		if Attr_AttrPMap[attVO.type] then
			addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[attVO.type]];
		end
		FPrint(addP)
		if attVO.type ~= enAttrType.eaMoveSpeed then
			attVO.val = toint(attVO.val * (1+addP+vipUp+zizhi))
		end
	end
	

    --坐骑属性丹
    local horsesxdlist={};
	if MountModel.ridedMount.pillNum > 0 then
		local str = t_consts[8].param;
		local formulaList = AttrParseUtil:Parse(str)
		for i,cfg in pairs(formulaList) do
			local cfgvo = {};
			cfgvo.type = cfg.type;
			cfgvo.val = cfg.val*MountModel.ridedMount.pillNum;
			table.push(horsesxdlist,cfgvo);
		end
	end
	local horselist = self:AddUpAttrIsNil(attrlist,horsesxdlist);
	local vo = {};
	vo.type = enAttrType.eaFight;
	vo.val = PublicUtil:GetFigthValue(horselist);
	table.push(attrlist,vo);	
	FTrace(attrlist,'显示加成')
	return attrlist
end

--灵兽坐骑其他属性
function MountUtil:GetLSMountOtherAttribute(mountlevel,star,isvip)
	local horselist = {};
	local horsestarlist = {};
	local horsesxdlist = {};
	local keyMap = {"att","def","hp","hit","dodge","cri","defcri","movespeed"};
	-- --坐骑等阶属性
	-- local horseCfg = t_horselingshou[mountlevel];
	-- if horseCfg then
	-- 	local vo = {};
	-- 	vo.type = AttrParseUtil.AttMap["movespeed"];
	-- 	vo.val = horseCfg["speed"];
	-- 	table.push(horselist,vo);
	-- end
	--坐骑星属性
	local horsestarindex = mountlevel * 100 + star;
	local starCfg = t_horselsstar[horsestarindex];
	local starAttrs = AttrParseUtil:Parse(starCfg.attr);
	if starCfg ~= nil then
		for i,k in ipairs(keyMap) do
			for index,attr in ipairs(starAttrs) do
				if k == attr.name then
					local vo = {};
					vo.type = attr.type;
					vo.name = attr.name;
					vo.val = attr.val;
					table.push(horsestarlist,vo);
				end
			end
			
			--属性丹
			if MountLingShouModel:GetZZPillNum() > 0 then
				local sxdvo = {};
				sxdvo.type = AttrParseUtil.AttMap[k];
				sxdvo.val = math.ceil(vo.val*t_consts[196].val2/100) *MountLingShouModel:GetZZPillNum();
				table.push(horsesxdlist,sxdvo);
			end
		end
	end
	local list = {};
	list = self:AddUpAttrIsNil(horselist,horsestarlist);
	--百分比加成
	for i,vo in ipairs(list) do
		local addP = 0;
		if Attr_AttrPMap[vo.type] then
			addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[vo.type]];
	end
		vo.val = toint(vo.val * (1+addP));
	end
	list = self:AddUpAttrIsNil(list,horsesxdlist);
	local vo = {};
	vo.type = enAttrType.eaFight;
	vo.val = PublicUtil:GetFigthValue(list);
	table.push(list,vo);
	return list;
end

--坐骑总属性
function MountUtil:GetMountAttribute(mountlevel,star)
	local otherattrlist = self:GetMountOtherAttribute(mountlevel,star,true)
	return otherattrlist;
end

--坐骑星级差属性
function MountUtil:GetStarLessAttribute(mountlevel,star)
	local horselist = self:GetMountOtherAttribute(mountlevel,star)
	local horsenextlist = {};
	if star == 4 then
		horsenextlist = self:GetMountOtherAttribute(mountlevel + 1,0)
	else
		horsenextlist = self:GetMountOtherAttribute(mountlevel,star + 1)
	end
	
	if horselist == nil or horsenextlist == nil then
		return nil
	end
	
	for i,voi in ipairs(horselist) do
		for j,voj in ipairs(horsenextlist) do
			if voi.type == voj.type then
				voi.val = voj.val - voi.val;
				break;
			end
		end
	end
	
	return horselist;
end

--坐骑等阶差属性
function MountUtil:GetLevelLessAttribute(mountlevel,star)
	local horselist = self:GetMountOtherAttribute(mountlevel,star)
	local horsenextlist = self:GetMountOtherAttribute(mountlevel + 1,0);
	
	if horselist == nil or horsenextlist == nil then
		return nil
	end
	
	for i,voi in ipairs(horselist) do
		for j,voj in ipairs(horsenextlist) do
			if voi.type == voj.type then
				voi.val = voj.val - voi.val;
				break;
			end
		end
	end
	
	return horselist;
end

function MountUtil:GetVipLessPower(mountlevel,star)
	local horselist = self:GetMountBaseAttrList(mountlevel,star)
	local horsenextlist = self:GetMountBaseAttrList(mountlevel + 1,0);
	
	if horselist == nil or horsenextlist == nil then
		return 0

	end
	
	local upRate = VipController:GetMountLvUp()/100
	if upRate <= 0 then
		upRate = VipController:GetMountLvUp(VipConsts:GetMaxVipLevel())/100
	end
	
	for i,voi in ipairs(horselist) do
		for j,voj in ipairs(horsenextlist) do
			if voi.type == voj.type then
				voi.val = voj.val - voi.val;
				if voi.type ~= enAttrType.eaMoveSpeed then
					voi.val = voi.val * upRate
				end
				break;
			end
		end
	end
	
	return PublicUtil:GetFigthValue(horselist)
end

--坐骑星级差属性
function MountUtil:GetVipStarLessPower(mountlevel,star)
	local horselist = self:GetMountOtherAttribute(mountlevel,star)
	local horsenextlist = {};
	if star == 4 then
		horsenextlist = self:GetMountOtherAttribute(mountlevel + 1,0)
	else
		horsenextlist = self:GetMountOtherAttribute(mountlevel,star + 1)
	end
	
	if horselist == nil or horsenextlist == nil then
		return 0
	end
	
	local upRate = VipController:GetMountLvUp()/100
	if upRate <= 0 then
		upRate = VipController:GetMountLvUp(VipConsts:GetMaxVipLevel())/100
	end
	
	for i,voi in ipairs(horselist) do
		for j,voj in ipairs(horsenextlist) do
			if voi.type == voj.type then
				voi.val = voj.val - voi.val;
				voi.val = voi.val * upRate
				break;
			end
		end
	end
	
	return PublicUtil:GetFigthValue(horselist)
end

--获取玩家坐骑模型Id
function MountUtil:GetPlayerMountModelId(mountlevel)
	return self:GetModelIdByLevel(mountlevel,MainPlayerModel.humanDetailInfo.eaProf)
end

--坐骑技能排序
function MountUtil:GetMountSortSkill()
	local list = {};
	local skilllist = SkillUtil:GetPassiveSkillListShowDzz(SkillConsts.ShowType_Horse);

	for i,skillgp in pairs(t_horseskill) do
		if skillgp then
			for j,vo in pairs(skilllist) do
				if skillgp.skillGroup == t_passiveskill[vo.skillId].group_id then
					local showlevel = t_passiveskill[vo.skillId].showlevel;
					if showlevel == 0 or showlevel <= MountModel.ridedMount.mountLevel then
    
						list[i] = vo;
					end
				end
			end
		end
	end
	
	return list;
end

--解析坐骑技能升级消耗道具
function MountUtil:Parse(str)
	local t1 = split(str,',');
	local vo = {};
	vo.itemid = tonumber(t1[1]);
	vo.num = tonumber(t1[2]);
	return vo
end

--获取列表VO
function MountUtil:GetSkillListVO(skillId,lvl)
	local vo = {};
	vo.skillId = skillId;
	local cfg = t_passiveskill[skillId];
	
	if cfg then
		vo.name = cfg.name;
		vo.lvl = lvl
		vo.needItem = cfg.needItem;
		vo.needSpecail = cfg.needSpecail
		vo.effectStr = cfg.effectStr
		vo.icon = cfg.icon;
		vo.iconUrl = ResUtil:GetSkillIconUrl(cfg.icon,"");
		vo.group_id = cfg.group_id;
		
		vo.maxLvl = 0
		if t_skillgroup[cfg.group_id] then
			vo.maxLvl = t_skillgroup[cfg.group_id].maxLvl;
		end
	end

	return vo;
end

--能否学习或者升级技能
function MountUtil:GetCanLvlUp(skillId,learn,lvl,isPassSkill)   --- addNew lvl isPassSkill
	local list = SkillUtil:GetLvlUpCondition(skillId,learn,lvl,isPassSkill);

	local iscan = false;
	local isCanTopo = false;
	for i,vo in ipairs(list) do
		if vo.state == false then
			return false;
		else
			iscan = true;
		end
		if vo.breach then     -----突破消耗
			if vo.breach == false then 
				return false;
			else
				isCanTopo = true;
			end
		end
	end
	
	return iscan,isCanTopo;
end

--能否学习或者升级技能(大主宰)
function MountUtil:GetCanLvlUpDzz(skillId,learn)
	local list = SkillUtil:GetLvlUpConditionForSkill(skillId,learn);
	
	local iscan = false;
	for i,vo in ipairs(list) do
		if vo.state == false then
			return false;
		else
			iscan = true;
		end
	end
	return iscan;
end

--获取下一个技能id
function MountUtil:GetNextMountLvlSkillId(vo)
	for k,cfg in pairs(t_passiveskill) do
		if vo.group_id == cfg.group_id and vo.lvl + 1 == cfg.level then
			--超过组内个数
			if t_skillgroup[cfg.group_id].maxLvl < cfg.level then
				return nil;
			end
			return self:GetSkillListVO(cfg.id,cfg.level);
		end
	end
	
	return nil;
end

function MountUtil:GetCurMapIsMount()
	local mapId = CPlayerMap:GetCurMapID()
	if not t_map[mapId] then
		return false
	end
	if t_map[mapId].can_ride == false then
		return false
	end
	return true
end

function MountUtil:IsCanMount()
	local selfPlayer = MainPlayerController:GetPlayer()
	if not selfPlayer then
		return
	end
	-- if selfPlayer:IsSitState() then
	-- 	FloatManager:AddCenter( StrConfig['mount15'] );
	-- 	return
	-- end
	if MountUtil:GetCurMapIsMount() == false then
		FloatManager:AddCenter( StrConfig['mount16'] );
		return
	end
	
	return true
end

function MountUtil:GetMountUpToolNum()
	if not t_horse[MountModel:GetMountLvl() + 1] then
		return 0;
	end
	
	if MountModel:GetMountLvl() >= MountConsts.MountLevelMax then
		return 0;
	end
	
	local horseCfg = t_horse[MountModel:GetMountLvl()];
	if horseCfg then
		if horseCfg.consume_item and horseCfg.consume_item[2] then
			return horseCfg.consume_item[2] * horseCfg.wish_max / horseCfg.wish_interval[1];
		end		
	end
	
	return 0;
end

function MountUtil:GetMountSen(senstr,prof)
	if senstr and senstr ~= "" then
		local list = split(senstr, "#")
		
		--只有一个
		if #list == 1 then
			return senstr;
		end
		
		for i = 1, #list do
			local sen = list[i]
			local senTable = split(sen, ",")
			
			if prof == tonumber(senTable[1]) then 
				return senTable[2];
			end
		end
	end
	
	return "";
end

--根据进度得到当前星
function MountUtil:GetStarByProgress(order, progress)
	local info = t_horse[order];
	if info == nil then
		--info = t_horselingshou[order]
		if not info then
			return 0;
		end
	end
	
	local star = progress / (info.wish_max / MountConsts.MountStarMax);
	star = math.modf(star);
	return star;
end

--根据进度得到当前星进度
function MountUtil:GetCurXingProgress(order, progress)
	local info = t_horse[order];
	if info == nil then
		--info = t_horselingshou[order]
		if not info then
			return 0;
		end
	end
	
	local star = progress / (info.wish_max / MountConsts.MountStarMax);
	star = math.modf(star);
	return progress - (info.wish_max / MountConsts.MountStarMax) * star;
end

--当前消耗类型 0进阶石，1灵力，2，都可以
function MountUtil:GetMountConstomType(level)
	local info = t_horse[level]
	if info == nil then
		--info = t_horselingshou[order]
		if not info then
			return -1;
		end
	end
	
	--都可以
	if info.consume_item[1] > 0 and (info.consume_item2[1] and info.consume_item2[1] > 0) then
		return 2;
	--进阶石
	elseif info.consume_item[1] > 0 then
		return 0;
	--灵力
	elseif info.consume_item2[1] > 0 then
		return 1;
	end
	
	return -1;
end

--是否灵力足够可以升星
function MountUtil:GetIsMountUpLingLi()
	if not t_horse[MountModel:GetMountLvl() + 1] then
		return false;
	end
	
	if MountModel:GetMountLvl() >= MountConsts.MountLevelMax then
		return false;
	end
	
	--因为坐骑引导任务做完后为1阶1星，所以通过1阶1星来判断是否显示升星提示
	if MountModel:GetMountLvl() == 1 and MountModel.ridedMount.mountStar < 1 then
		return false;
	end
	
	local mountcfg = t_horse[MountModel:GetMountLvl()];
	if mountcfg == nil then
		return false;
	end
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	
	if mountcfg.consume_item2[2] <= 0 then
		return false;
	end
	
	--进阶次数
	local count = ((mountcfg.wish_max / 5) - (MountModel.ridedMount.starProgress % (mountcfg.wish_max / 5))) / mountcfg.wish_interval2[1];
	if playerinfo.eaZhenQi >= mountcfg.consume_item2[2] * count and 
	   playerinfo.eaBindGold + playerinfo.eaUnBindGold >= mountcfg.consume_money * count then
		return true;
	else
		return false;
	end
end

--是否达到升阶的条件
function MountUtil:GetIsCanMountUp()
	local mountcfg = t_horse[MountModel:GetMountLvl()];
	if mountcfg == nil then
		return false;
	end
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	
	local wishcount = 0;
	if mountcfg.consume_item[2] > 0 then
		local itemId = mountcfg.consume_item[1];
		local intemNum = BagModel:GetItemNumInBag(itemId);
		wishcount = math.modf(intemNum / mountcfg.consume_item[2]) * mountcfg.wish_interval[1];
	end
	
	if mountcfg.consume_item2[2] > 0 then 
		wishcount = wishcount + math.modf(playerinfo.eaZhenQi / mountcfg.consume_item2[2]) * mountcfg.wish_interval2[1];
	end
	
	--所需的道具和灵力是否达到升到下一阶
	if MountModel.ridedMount.starProgress + wishcount >= mountcfg.wish_max then
		--银两是否足够
		if playerinfo.eaBindGold + playerinfo.eaUnBindGold >= mountcfg.consume_money * (mountcfg.wish_max - MountModel.ridedMount.starProgress) then
			return true;
		end
	end
	
	return false;
end

--5阶升阶需要消耗进阶石的信息
function MountUtil:GetMountUpToolInfo()
	for i=MountModel:GetMountLvl() + 1,MountConsts.MountLevelMax do
		local cfg = t_horse[i];
		if cfg then
			if cfg.consume_item[1] > 0 then
				return cfg.consume_item,cfg.id;
			end
		end
	end
	
	return nil;
end

-- 获得坐骑list
function MountUtil:GetMountSkinList(openlist)
	local treeData = {};
	treeData.label = "root";
	treeData.open = true;
	treeData.isShowRoot = false;
	treeData.nodes = {};
	
	local nodeputong = {};
	nodeputong.nodes = {};
	nodeputong.label1 = 1;
	
	if self:GetIsOpen(nodeputong, openlist) == true then
		nodeputong.open = true;
	else
		nodeputong.open = false;
	end
	
	nodeputong.label = "";
	nodeputong.lvl = 1;
	nodeputong.mounttype = 1;
	
	--普通皮肤
	local showmax = 0;
	if MountModel.ridedMount.mountLevel < MountConsts.shownextmountmaxorder then
		showmax = MountConsts.showmountmaxorder;
	else
		showmax = MountModel.ridedMount.mountLevel + MountConsts.showmountmaxorderadd;
	end
	if showmax > MountConsts.MountLevelMax then
		showmax = MountConsts.MountLevelMax;
	end
	for i=1,showmax do
		local cfgpt = t_horse[i];
		if cfgpt then
			local vochild = {};
			vochild.label1 = 1;
			vochild.label2 = cfgpt.id;
			vochild.id = cfgpt.id;
			if MountModel.ridedMount.mountLevel < cfgpt.id then
				vochild.label = string.format( StrConfig["mount28"], cfgpt["name"..MainPlayerModel.humanDetailInfo.eaProf]);
			else
				vochild.label = string.format( StrConfig["mount27"], cfgpt["name"..MainPlayerModel.humanDetailInfo.eaProf]);
			end
			
			if self:GetIsOpen(vochild, openlist) == true then
				vochild.open = true;
			else
				vochild.open = false;
			end
			vochild.lvl = 2;
			table.push(nodeputong.nodes,vochild);
		end
	end
	table.push(treeData.nodes, nodeputong);
	
	--特殊皮肤
	local nodeteshu = {};
	nodeteshu.nodes = {};
	nodeteshu.label1 = 2;
	
	if self:GetIsOpen(nodeteshu, openlist) == true then
		nodeteshu.open = true;
	else
		nodeteshu.open = false;
	end
	
	nodeteshu.label = "";
	nodeteshu.lvl = 1;
	nodeteshu.mounttype = 2;
	
	local skinlist = {};
	for voi = 201,200+99 do
		if not t_horseskn[voi] then
			break;
		end
		table.push(skinlist,t_horseskn[voi]);
	end
	table.sort(skinlist,function(A,B)
		if A.model1 < B.model1 then
			return true;
		else
			return false;
		end
	end);
	
	for i,vo in ipairs(skinlist) do
		local cfgts = vo;
		if cfgts then
			local vochild = {};
			vochild.label1 = 2;
			vochild.label2 = cfgts.id;
			vochild.id = cfgts.id;
			
			local skinname = MountUtil:GetListString(cfgts.name,MainPlayerModel.humanDetailInfo.eaProf);
			if MountUtil:GetMountTime(cfgts.id) == 0 then
				vochild.label = string.format( StrConfig["mount28"], skinname );
			else
				vochild.label = string.format( StrConfig["mount27"], skinname );
			end
			vochild.lvl = 2;
			if self:GetIsOpen(vochild, openlist) == true then
				vochild.open = true;
			else
				vochild.open = false;
			end
			local verSionName = Version:GetName();
			if not cfgts.plat then
				table.push(nodeteshu.nodes,vochild);
			else
				if cfgts.plat == '' or cfgts.plat == verSionName then
					table.push(nodeteshu.nodes,vochild);
				end
			end
		end
	end
	table.push(treeData.nodes, nodeteshu);
	
	-- if MountLingShouModel.mountLevel > 0 then
	-- 	--灵兽皮肤
	-- 	local nodelingshou = {};
	-- 	nodelingshou.nodes = {};
	-- 	nodelingshou.label1 = 3;
		
	-- 	if self:GetIsOpen(nodelingshou, openlist) == true then
	-- 		nodelingshou.open = true;
	-- 	else
	-- 		nodelingshou.open = false;
	-- 	end
		
	-- 	nodelingshou.label = "";
	-- 	nodelingshou.lvl = 1;
	-- 	nodelingshou.mounttype = 3;
	-- 	for i=301,MountConsts.LingShouSpecailDownid+MountConsts.MountLingShouLevelMax do
	-- 		local cfgpt = t_horselingshou[i];
	-- 		if cfgpt then
	-- 			local vochild = {};
	-- 			vochild.label1 = 1;
	-- 			vochild.label2 = cfgpt.id;
	-- 			vochild.id = cfgpt.id;
	-- 			if MountLingShouModel.mountLevel < cfgpt.id then
	-- 				vochild.label = string.format( StrConfig["mount28"], cfgpt.name);
	-- 			else
	-- 				vochild.label = string.format( StrConfig["mount27"], cfgpt.name);
	-- 			end
				
	-- 			if self:GetIsOpen(vochild, openlist) == true then
	-- 				vochild.open = true;
	-- 			else
	-- 				vochild.open = false;
	-- 			end
	-- 			vochild.lvl = 2;
	-- 			table.push(nodelingshou.nodes,vochild);
	-- 		end
	-- 	end
	-- 	table.push(treeData.nodes, nodelingshou);
	-- end
	
	return treeData;
end

--该节点是否是打开的
function MountUtil:GetIsOpen(node, openlist)
	for i,vo in pairs(openlist) do
		if vo then
			local ishave = true;
			for i=1,2 do
				if node["label"..i] and vo["label"..i] then
					if node["label"..i] ~= vo["label"..i] then
						ishave = false;
						break;
					end
				elseif (not node["label"..i] and vo["label"..i]) or (node["label"..i] and not vo["label"..i]) then
					ishave = false;
					break;
				end
			end
			
			if ishave == true then
				return true;
			end
		end
	end
	
	return false;
end

function MountUtil:GetMountSound(level,prof)
	local horsecfg = {};
	if level < MountConsts.SpecailDownid then
		horsecfg = t_horse[level];
		if not horsecfg then
			Error("Cannot find config of horse. level:"..level);
			return 0;
		end
	elseif level < MountConsts.LingShouSpecailDownid then
		horsecfg = t_horseskn[level];
		if not horsecfg then
			Error("Cannot find config of horseskn. level:"..level);
			return 0;
		end
	else
	--	horsecfg = t_horselingshou[level];
		if not horsecfg then
			Error("Cannot find config of t_horselingshou. level:"..level);
			return 0;
		end
	end
	if horsecfg.sound and horsecfg.sound ~= "" then
		local list = split(horsecfg.sound, "#")
		
		--只有一个
		if #list == 1 then
			return tonumber(horsecfg.sound);
		end
		
		for i = 1, #list do
			local strsound = list[i]
			local soundTable = split(strsound, ",")
			
			if prof == tonumber(soundTable[1]) then 
				return tonumber(soundTable[2]);
			end
		end
	end
	
	return 0;
end

function MountUtil:GetListString(str, prof)
	if str and str ~= "" then
		local list = split(str, "#")
		
		--只有一个
		if #list == 1 then
			return str;
		end
		
		for i = 1, #list do
			local strdes = list[i]
			local desTable = split(strdes, ",")
			
			if prof == tonumber(desTable[1]) then 
				return desTable[2];
			end
		end
	end
	
	return 0;
end

--当前条件是否可以进阶
function MountUtil:GetIsCanJinJie(type, auto, level)
	local info = t_horse[level]
	if info == nil then
		--info = t_horselingshou[level];
		if not info then
			return false;
		end
	end
	
	local ret = false;
	local sXDItem = t_item[info.consume_item[1]]
	--消耗进阶石
	if sXDItem then
		if type == 0 then
			--进阶石足够
			if MountUtil:GetIsJinJieBytool(level) == 1 then
				ret = true;
			end
		else
			--灵力足够
			local toolItem = t_item[info.consume_item2[1]]
			if MountUtil:GetIsJinJieByLingLi(level) == 1 then
				ret = true;
			end
		end
	--无进阶石消耗条件
	else
		--灵力足够
		local toolItem = t_item[info.consume_item2[1]]
		if MountUtil:GetIsJinJieByLingLi(level) == 1 then
			ret = true;
		end
	end
	
	if auto == true and ret == false then
		if self:GetIsJinJieByMoney(level) == 1 then
			ret = true;
		end
	end
	
	if ret == true then
		if MountUtil:GetIsJinJieByYinLiang(level) == 1 then
			return true;
		end
	end
	
	return false;
end

--坐骑VIP加成战斗力
function MountUtil:GetVIPFightAdd()
	local upRate = VipController:GetMountLvUp()/100
	if upRate <= 0 then
		upRate = VipController:GetMountLvUp(1)/100
	end
	if not MountModel.ridedMount.mountLevel then 
		MountModel.ridedMount.mountLevel=1
	end 
	if not MountModel.ridedMount.mountStar then 
		MountModel.ridedMount.mountStar=1
	end
	local attrlist = self:GetMountBaseAttrList(MountModel.ridedMount.mountLevel,MountModel.ridedMount.mountStar);
	if not attrlist or #attrlist<1 then
		return 0;
	end
	
	for i, vo in ipairs (attrlist) do
		if vo.type ~= enAttrType.eaMoveSpeed then
			vo.val = vo.val * upRate
		end
	end
	return PublicUtil:GetFigthValue(attrlist);
end

function MountUtil:GetMountLingShouMax()
	local count = 0;
	for i = 301,400 do
		if t_horselingshou[i] then
			count = count + 1;
		else
			break;
		end
	end
	return count;
end

--临时的功能 获得灵兽坐骑的装备 都是空的
function MountUtil:GetBagItemList(bagType,showType)
	local bagVO = BagModel:GetBag(bagType);
	if not bagVO then return; end;
	local bagTotalSize = bagVO:GetTotalSize();
	local bagOpenSize = bagVO:GetSize();
	local list = {};
	local itemlist = nil;--显示分类时的Item列表
	if showType ~= BagConsts.ShowType_All then
		itemlist = bagVO:GetItemListByShowType(showType);
	end
	for i=1,bagTotalSize do
		local slotVO = BagSlotVO:new();
		slotVO.bagType = bagType;
		slotVO.uiPos = i;
		slotVO.pos = i-1;
		if i<= bagOpenSize then--格子是否开启
			slotVO.opened = true;
			--如果是all,按格子逻辑排列
			if showType == BagConsts.ShowType_All then
				slotVO.hasItem = false;
			else
				slotVO.hasItem = false;
				slotVO.pos = -1;
			end
		else
			slotVO.opened = false;
		end
		table.push(list,slotVO);
	end
	return list;
end

function MountUtil:GetConsumeItem(level)
	local cfg = t_horse[level]
	if not cfg then
		--cfg = t_horselingshou[level]
		if not cfg then
			return;
		end
		local itemConsume1 = cfg.consume_item
		local hasEnoughItem = function( item, num )
			return BagModel:GetItemNumInBag( item ) >= num
		end
		local itemId, itemNum, isEnough
		if hasEnoughItem( itemConsume1[1], itemConsume1[2] ) then
			itemId = itemConsume1[1]
			itemNum = itemConsume1[2]
			isEnough = true
		else
			itemId = itemConsume1[1]
			itemNum = itemConsume1[2]
			isEnough = false
		end
		return itemId, itemNum, isEnough
	end
	local itemConsume1 = cfg.consume_item
	local itemConsume2 = cfg.consume_item3
	local itemConsume3 = cfg.consume_item4
	local hasEnoughItem = function( item, num )
		return BagModel:GetItemNumInBag( item ) >= num
	end
	local itemId, itemNum, isEnough
	if hasEnoughItem( itemConsume1[1], itemConsume1[2] ) then
		itemId = itemConsume1[1]
		itemNum = itemConsume1[2]
		isEnough = true
	-- elseif hasEnoughItem( itemConsume2[1], itemConsume2[2] ) then
	-- 	itemId = itemConsume2[1]
	-- 	itemNum = itemConsume2[2]
	-- 	isEnough = true
	-- elseif hasEnoughItem( itemConsume3[1], itemConsume3[2] ) then
	-- 	itemId = itemConsume3[1]
	-- 	itemNum = itemConsume3[2]
	-- 	isEnough = true
	else
		itemId = itemConsume1[1]
		itemNum = itemConsume1[2]
		isEnough = false
	end
	return itemId, itemNum, isEnough
end

--坐骑界面是否可以升级 
--adder:houxudong
--date:2016/7/31 1:04:05
function MountUtil:CheckCanLvUp(  )
	
    if not FuncManager:GetFuncIsOpen(FuncConsts.Horse) then return false end;
	local isCanLvUp = false
	--进阶石是否足够
	local _, _, isEnough = self:GetConsumeItem(MountModel.ridedMount.mountLevel);
	if isEnough then
		if MountModel.ridedMount.mountLevel < MountConsts.MountLevelMax then
			isCanLvUp = true
		end
	end

	local list = MountUtil:GetMountSortSkill();
    for i= 1, MountConsts.skillTotalNum do
	    local listvo = MountUtil:GetSkillListVO(list[i].skillId,list[i].lvl)
	    if listvo then
			
            local islearn=listvo.lvl == 0;
	        if listvo.lvl < listvo.maxLvl and MountUtil:GetCanLvlUpDzz(listvo.skillId,islearn) == true  then
	            isCanLvUp = true
	        end
	    end
	end
	return isCanLvUp;
end

function MountUtil:CheckCanLvUpToNextStar()
	if not FuncManager:GetFuncIsOpen(FuncConsts.Horse) then  return false end

	local itemID, itemNum, isEnough = self:GetConsumeItem(MountModel.ridedMount.mountLevel);
	local totalItemNum = 0;
	local cfg = t_horse[MountModel.ridedMount.mountLevel]
	if not cfg then return false; end
	if MountModel.ridedMount.mountLevel >= #t_horse and MountModel.ridedMount.starProgress == 5 then
		return false;
	end
	local curprogress = MountUtil:GetCurXingProgress(MountModel.ridedMount.mountLevel, MountModel.ridedMount.starProgress);
	local singleStarTotalProgress = cfg.wish_max / MountConsts.MountStarMax;
	local needProgress = singleStarTotalProgress - curprogress;
	totalItemNum = math.ceil(needProgress / cfg.wish_interval[2]);
	if BagModel:GetItemNumInBag( itemID ) >= totalItemNum then
		return true;
	end
	return false;
end
local maxLevel;
function MountUtil:GetMaxLevel()
	if not maxLevel then
	   maxLevel=0
	    for k,v in pairs(t_horse) do
		    maxLevel = math.max( maxLevel, k )
	    end
	end
	return maxLevel;
end
function MallUtils:GetIsQiZhanActive()
	local cfg = t_consts[342];
	if not cfg then
		return
	end
	local id = cfg.val1;
	local skill = SkillModel:GetSkill(id);
	if not skill then
		return;
	end
	return skill:GetLvl() > 0;
end


--获取当前玩家坐骑阶数
function MountUtil:GetMountLv()
	if not MountModel.ridedMount then
		return 0
	end
	if not MountModel.ridedMount.mountLevel then
		return 0
	end
	return MountModel.ridedMount.mountLevel
end