--[[
RealmUtil
zhangshuhui
2015年4月1日18:31:00
]]

_G.RealmUtil = {};

--根据等阶得到当前的巩固等级 --境界等阶*100+巩固次数
function RealmUtil:GetStrenthenIdByOrder(order)
	-- for i,vo in pairs(RealmModel:GetStrenthenList()) do
		-- if (vo - vo % 100) / 100 == order then
			-- return vo % 100;
		-- end
	-- end
	
	return 0;
end

--加上个判断 是否为空
function RealmUtil:AddUpAttrIsNil(list1,list2)
	if list1 == nil then
		return list2;
	end
	
	if list2 == nil then
		return list1;
	end
	
	return EquipUtil:AddUpAttr(list1,list2);
end

--解析巩固所需条件
function RealmUtil:ToolParse(str,index)
	local list = {}
	local itemid = 0;
	if str ~= "" then
		local itemList = split(str,"#");
		for i,itemStr in ipairs(itemList) do
			local item = split(itemStr,",");
			local vo = {};
			vo.id = tonumber(item[1]);
			vo.count = item[2];
			vo.name = t_item[vo.id].name;
			table.push(list,vo);
			
			if index and index == i then
				itemid = vo.id;
			end
		end
	end
	return list,itemid;
end

--判断是否礼金或者元宝联手渡劫次数达到上限
function RealmUtil:GetIsJoinlyMax(order, type)
	local ismax = false;
	local num = 0;
	
	return ismax,num;
end

--得到剩余礼金渡劫次数
function RealmUtil:GethaveBreakLJYBNum(order, type)
	local cost = 0;
	local num = 0;
	
	return cost,num;
end

--是否有足够的经验进行普通灌注
function RealmUtil:GetIsHaveExp(order)
	local playerinfo = MainPlayerModel.humanDetailInfo;
	
	-- 境界等阶*1000+重数
	local cfg = t_jingjie[order];
	if cfg then
		local floodexp = cfg.flood_exp;
		local percent = self:GetFloodExpNum();
		if percent < 1 then
			floodexp = math.modf(floodexp * percent);
		end
		
		if playerinfo.eaExp >= floodexp then
			return true;
		end
	end
	
	return false;
end

--是否有足够的道具进行普通灌注
function RealmUtil:GetIsHaveTool(order)
	local playerinfo = MainPlayerModel.humanDetailInfo;
	
	-- 境界等阶*1000+重数
	local cfg = t_jingjie[order];
	if cfg then
		--消耗道具
		-- local rewardList = RewardManager:ParseToVO(cfg.flood_item);
		-- for k,cfgvo in pairs(rewardList) do
			-- if cfgvo and t_item[cfgvo.id] then
				-- local intemNum = BagModel:GetItemNumInBag(cfgvo.id);
				-- if intemNum < cfgvo.count then
					-- return false;
				-- end
			-- end
		-- end
		
		--改为消耗修为
		local curVal = XiuweiPoolModel:GetXiuwei();
		if curVal < cfg.xiuweizhi then
			return false;
		end
	end
	
	return true;
end

--是否有足够的道具进行突破
function RealmUtil:GetIsHaveToolTuPo(order)
	local ordercfg = t_jingjie[order];
	if ordercfg then
		--消耗道具
		local itemId, itemNum, isEnough = RealmUtil:GetConsumeItem(order);
		return isEnough;
	end
	
	return false;
end

--是否有足够的银两进行突破
function RealmUtil:GetIsHaveMoneyTuPo(order)
	local ordercfg = t_jingjie[order];
	if ordercfg then
		local playerInfo = MainPlayerModel.humanDetailInfo;
		local playerMoney = playerInfo.eaBindGold + playerInfo.eaUnBindGold;
		if playerMoney < ordercfg.proce_money then
			return false;
		end
	end
	
	return true;
end

--是否有足够元宝进阶
function RealmUtil:GetIsJinJieByMoney(order)
	local ordercfg = t_jingjie[order];
	if not ordercfg then
		return false;
	end
	
	--消耗道具
	local itemId, itemNum, isEnough = RealmUtil:GetConsumeItem(order);
	if isEnough then
		return true;
	end
	if t_item[itemId] then
		local intemNum = BagModel:GetItemNumInBag(itemId);
		local buymax = MallUtils:GetMoneyShopMaxNum(itemId);
		if buymax == nil then
			return false
		end
		--材料足够
		if buymax + intemNum >= itemNum then
			return true;
		end
	end
	
	return false;
end

--灌注道具是否达到灌注两次的数量
function RealmUtil:GetIsFloodToolNum()
	-- 境界等阶*1000+重数
	local cfg = t_jingjie[RealmModel:GetRealmOrder()];
	if cfg then
		--星已满
		if RealmUtil:GetIsFullProgress() == true then
			return false;
		end
		
		--在灌注一次达到满星
		if cfg.item_max2 - RealmModel:GetRealmProgress() <= 1 then
			return false;
		end
		
		--消耗道具
		local rewardList = RewardManager:ParseToVO(cfg.flood_item);
		for k,cfgvo in pairs(rewardList) do
			if cfgvo and t_item[cfgvo.id] then
				local intemNum = BagModel:GetItemNumInBag(cfgvo.id);
				if intemNum < cfgvo.count*2 then
					return false;
				end
			end
		end
		
		return true;
	end
	
	return false;
end

--是否得到满进度 
function RealmUtil:GetIsFullProgress()
	local curorder = RealmModel:GetRealmOrder();
	local cfg = t_jingjie[curorder];
	if not cfg then
		return false;
	end
	
	if RealmModel:GetRealmProgress() >= cfg.item_max2 then
		return true;
	end
	
	return false;
end

--当前境界经验丹是否满足
function RealmUtil:GetIsHaveRealmDanUp()
	local intemNum = BagModel:GetItemNumInBag(tonumber(t_consts[125].val1));
	if intemNum >= 1 then
		return true;
	end
	return false;
end

--灌注境界消耗的经验比例
function RealmUtil:GetFloodExpNum()
	local val3 = math.max(0,0.4 * (RealmModel:GetOrderMaxInGame() - RealmModel:GetRealmOrder()));
	local pencent = math.max(0.1, math.cos(val3));
	
	return pencent;
end
--当前条件是否可以进阶
function RealmUtil:GetIsCanJinJie(atuo)
	local itemId, itemNum, isEnough = RealmUtil:GetConsumeItem(RealmModel:GetRealmOrder());
	if atuo == true and isEnough == false then
		if self:GetIsJinJieByMoney(RealmModel:GetRealmOrder()) == true then
			isEnough = true;
		end
	end
	return isEnough;
end
--是否有大量灵石可以直接灌注
function RealmUtil:GetIsAutoFloot(type)
	local curorder = RealmModel:GetRealmOrder();
	local cfg = t_jingjie[curorder];
	if not cfg then
		return false, 0;
	end
	
	--消耗道具
	local itemid = 0;
	local intemNum = 0;
	local rewardList = RewardManager:ParseToVO(cfg.flood_item);
	for k,cfgvo in pairs(rewardList) do
		if cfgvo and t_item[cfgvo.id] then
			itemid = cfgvo.id;
			intemNum = cfgvo.count;
		end
	end
	
	--经验是否足够次数
	local playerinfo = MainPlayerModel.humanDetailInfo;
	
	--背包灵石数量
	local bagintemNum = BagModel:GetItemNumInBag(itemid);
	
	local floodexp = cfg.flood_exp;
	local percent = self:GetFloodExpNum();
	if percent < 1 then
		floodexp = math.modf(floodexp * percent);
	end
	local expNum = math.modf(playerinfo.eaExp / floodexp);
	if type == 2 then
		local danNum = BagModel:GetItemNumInBag(tonumber(t_consts[125].val1));
		expNum = danNum;
	end
	
	local progressnum = bagintemNum;
	
	if progressnum > expNum then
		progressnum = expNum;
	end
	
	if progressnum >= RealmConsts.TOOLMAX then
		if progressnum > cfg.item_max2 - RealmModel.realmProgress then
			progressnum = cfg.item_max2 - RealmModel.realmProgress;
		end
		return true, progressnum;
	end
	
	return false, 0;
end

--是否有属性值
function RealmUtil:IsHaveAttrPro(attrtype)
	local info = RealmModel:GetAttrList();
	if info then
		for i,vo in ipairs(info) do
			if vo.type == AttrParseUtil.AttMap[attrtype] then
				return true;
			end
		end
	end
	
	return false;
end

--得到VIP战斗力加成
function RealmUtil:GetVIPFightAdd()
	local upRate = VipController:GetJingjieLvUp()
	if upRate <= 0 then
		upRate = VipController:GetJingjieLvUp(VipConsts:GetMaxVipLevel())
	end
	local list = {};
	local info = RealmModel:GetAttrList();
	if info then
		for i,vo in ipairs(info) do
			local vipvo = {};
			vipvo.type = vo.type;
			vipvo.val = vo.val * ( upRate * 0.01 );
			table.push(list, vipvo);
		end
	end
	return EquipUtil:GetFight(list);
end

function RealmUtil:GetConsumeItem(level)
	local cfg = t_jingjie[level]
	if not cfg then return end
	local itemConsume1 = cfg.break_item
	local itemConsume2 = cfg.break_item2
	local itemConsume3 = cfg.break_item3
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

function RealmUtil:GetGongGuFloodItem()
	local cfg = t_jingjiegonggu[RealmModel:GetChongId()];
	if not cfg then return end
	local itemflood = cfg.flood_item;
	local hasEnoughItem = function( item, num )
		return BagModel:GetItemNumInBag( item ) >= num
	end
	local itemId, itemNum, isEnough
	if hasEnoughItem( itemflood[1], itemflood[2] ) then
		itemId = itemflood[1]
		itemNum = itemflood[2]
		isEnough = true
	else
		itemId = itemflood[1]
		itemNum = itemflood[2]
		isEnough = false
	end
	return itemId, itemNum, isEnough
end

function RealmUtil:GetGongGuBreakItem()
	local cfg = t_jingjiegonggu[RealmModel:GetChongId()];
	if not cfg then return end
	local itembreak = cfg.break_item;
	local hasEnoughItem = function( item, num )
		return BagModel:GetItemNumInBag( item ) >= num
	end
	local itemId, itemNum, isEnough
	if RealmModel:GetChongProgress() == cfg.max then
		if hasEnoughItem( itembreak[1], itembreak[2] ) then
			itemId = itembreak[1]
			itemNum = itembreak[2]
			isEnough = true
		else
			itemId = itembreak[1]
			itemNum = itembreak[2]
			isEnough = false
		end
	end
	return itemId, itemNum, isEnough
end

--根据境界等阶得到已获得重数,是否已满
function RealmUtil:GetChongIdByOrder(order)
	local chongId = RealmModel:GetChongId();
	if chongId == 0 then
		return 0,false;
	end
	if toint(chongId / 100) > order then
		return order * 100 + RealmConsts.xingmax, true;
	end
	if toint(chongId / 100) == order then
		if chongId % 100 == 1 then
			return 0,false;
		else
			return chongId,false;
		end
	end
	if toint(chongId / 100) < order then
		return 0,false;
	end
	
	return 0, false;
end

--得到巩固境界获得的属性加成
function RealmUtil:GetGongGuAttrList()
	local list = {};
	local attrmap = {};
	for _, type in pairs( RealmConsts.Attrs ) do
		attrmap[type] = 0;
	end
	local chongId = RealmModel:GetChongId();
	if chongId == 0 then
		return list;
	end
	for i=1,toint(chongId / 100)-1 do
		local attrlist = {};
		local cfg = t_jingjie[i];
		local precfg = t_jingjie[i-1];
		if cfg then
			for _, type in pairs( RealmConsts.Attrs ) do
				if cfg[type.."max"] then
					local vo = {};
					vo.type = AttrParseUtil.AttMap[type];
					if precfg then
						vo.val = math.ceil((cfg[type.."max"] - precfg[type.."max"]) * t_jingjiegonggu[i*100 + RealmConsts.xingmax].attr / 100);
					else
						vo.val = math.ceil(cfg[type.."max"] * t_jingjiegonggu[i*100 + RealmConsts.xingmax].attr / 100);
					end
					table.push(attrlist, vo);
					
					if attrmap[type] then
						attrmap[type] = attrmap[type] + vo.val;
					else
						attrmap[type] = vo.val;
					end
				end
			end
		end
		list = RealmUtil:AddUpAttrIsNil(list, attrlist);
	end
	local attrlist = {};
	local chongLevel = chongId % 100;
	local chongOrder = toint(chongId / 100);
	local cfg = t_jingjie[chongOrder];
	local precfg = t_jingjie[chongOrder-1];
	if cfg then
		for _, type in pairs( RealmConsts.Attrs ) do
			if cfg[type.."max"] then
				local vo = {};
				vo.type = AttrParseUtil.AttMap[type];
				if precfg then
					vo.val = math.ceil((cfg[type.."max"] - precfg[type.."max"]) * t_jingjiegonggu[chongOrder*100 + chongLevel - 1].attr / 100);
				else
					vo.val = math.ceil(cfg[type.."max"] * t_jingjiegonggu[chongOrder*100 + chongLevel - 1].attr / 100);
				end
				table.push(attrlist, vo);
				if attrmap[type] then
					attrmap[type] = attrmap[type] + vo.val;
				else
					attrmap[type] = vo.val;
				end
			end
		end
	end
	list = RealmUtil:AddUpAttrIsNil(list, attrlist);
	return list,attrmap;
end

--加上个判断 是否为空
function RealmUtil:AddUpAttrIsNil(list1,list2)
	if list1 == nil then
		return list2;
	end
	
	if list2 == nil then
		return list1;
	end
	
	return EquipUtil:AddUpAttr(list1,list2);
end

--本次突破的属性加成
function RealmUtil:GetChongAttrAddList()
	local list = {};
	local chongId = RealmModel:GetChongId();
	if chongId == 0 then
		return list;
	end
	
	local attrlist = {};
	local chongLevel = chongId % 100;
	local chongOrder = toint(chongId / 100);
	local cfg = t_jingjie[chongOrder];
	local precfg = t_jingjie[chongOrder-1];
	local gonggucfg = t_jingjiegonggu[chongId];
	local pregonggucfg = t_jingjiegonggu[chongId-1];
	if cfg then
		for _, type in pairs( RealmConsts.Attrs ) do
			if cfg[type.."max"] and cfg[type.."max"] > 0 then
				local val = 0;
				if pregonggucfg then
					if precfg then
						val = math.ceil((cfg[type.."max"] - precfg[type.."max"]) * (gonggucfg.attr - pregonggucfg.attr) / 100);
					else
						val = math.ceil(cfg[type.."max"] * (gonggucfg.attr - pregonggucfg.attr) / 100);
					end
					
				else
					if precfg then
						val = math.ceil((cfg[type.."max"] - precfg[type.."max"]) * gonggucfg.attr / 100);
					else
						val = math.ceil(cfg[type.."max"] * gonggucfg.attr / 100);
					end
				end
				list[type] = val;
			end
		end
	end
	return list;
end

--本次突破属性加成百分比
function RealmUtil:GetChongAddPercent()
	local chongId = RealmModel:GetChongId();
	if chongId == 0 then
		return 0;
	end
	local val = 0;
	local gonggucfg = t_jingjiegonggu[chongId];
	local pregonggucfg = t_jingjiegonggu[chongId-1];
	if pregonggucfg then
		val = gonggucfg.attr - pregonggucfg.attr;
	else
		val = gonggucfg.attr;
	end
	return val;
end

--境界巩固是否批量巩固
function RealmUtil:GetIsAutoGongGu()
	local cfg = t_jingjiegonggu[RealmModel:GetChongId()];
	if not cfg then
		return;
	end
	local blessing = RealmModel:GetChongProgress();
	--背包灵石数量
	local itemflood = cfg.flood_item;
	local bagintemNum = BagModel:GetItemNumInBag(itemflood[1]);
	local progressnum = bagintemNum;
	
	if progressnum >= cfg.max then
		if progressnum > cfg.max - blessing then
			progressnum = cfg.max - blessing;
		end
		return true, progressnum;
	end
	
	return false, 0;
end

--检查是否执行巩固引导
function RealmUtil:CheckGongGuGuide()
	if RealmModel:GetRealmOrder() >= 2 then
		if ConfigManager:GetRoleCfg().RealmGongGuGuide then return; end
		local selfLevel = MainPlayerModel.humanDetailInfo.eaLevel;
		local guideLevel = t_consts[203].val1;
		if selfLevel > guideLevel then
			return
		end
		QuestScriptManager:DoScript("realmgongguguide");
		ConfigManager:GetRoleCfg().RealmGongGuGuide = true;
		ConfigManager:Save();
	end
end

-- adder:houxudong date:2016/10/28 15:06:23
-- 检测境界是否可以操作
function RealmUtil:CheckCanOperation()
	--满阶满星满进度
	if RealmModel:GetRealmOrder() >= RealmConsts.ordermax and
	   RealmUtil:GetIsFullProgress() == true then
		return false;
	end

	-- isEnough 开始境界，进度条为满格(true) || 开始灌注, 进度条为不满格(false)
	local _, _, isEnough = RealmUtil:GetConsumeItem(RealmModel:GetRealmOrder())  --境界
	if RealmUtil:GetIsFullProgress() == false then
		local isHave = true
		--经验不足
		if RealmUtil:GetIsHaveExp(RealmModel:GetRealmOrder()) == false then       --灌注
			isHave = false
		end
		--道具不足
		if RealmUtil:GetIsHaveTool(RealmModel:GetRealmOrder()) == false then
			isHave = false
			local cfg = t_jingjie[RealmModel:GetRealmOrder()]
			if not cfg then return false end
			local reCfg = split(cfg.flood_item_daiti,',')
			if not reCfg then return false end
			if toint(reCfg[1]) > 0 then 
				local NbItemId = toint(reCfg[1])
				local NbNum = BagModel:GetItemNumInBag(NbItemId)
				if NbNum >= toint(reCfg[2]) then 
					isHave = true
				end
			end
		end
		if isHave == true then
			return true
		end
	else
		if isEnough == true then
			return true
		else
			return false
		end
	end
	return false
end