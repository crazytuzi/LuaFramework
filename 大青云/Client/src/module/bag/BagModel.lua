
_G.BagModel = Module:new();

BagModel.sellNeedConfirm = true;--出售是否需要确认
BagModel.itemGroupCDMap = {};
BagModel.itemUseNumList = {};--物品使用数量列表
BagModel.compoundMap = {};--每个道具可以合成的目标道具Map

BagModel.baglist = {
	[BagConsts.BagType_Role] = BagVO:new(BagConsts.BagType_Role),
	[BagConsts.BagType_Bag] = BagVO:new(BagConsts.BagType_Bag),
	[BagConsts.BagType_Storage] = BagVO:new(BagConsts.BagType_Storage),
	[BagConsts.BagType_Horse] = BagVO:new(BagConsts.BagType_Horse),
	[BagConsts.BagType_RoleItem] = BagVO:new(BagConsts.BagType_RoleItem),
	[BagConsts.BagType_LingShou] = BagVO:new(BagConsts.BagType_LingShou),
	[BagConsts.BagType_LingShouHorse] = BagVO:new(BagConsts.BagType_LingShouHorse),
	-- [BagConsts.BagType_LingZhenZhenYan] = BagVO:new(BagConsts.BagType_LingZhenZhenYan),
	[BagConsts.BagType_QiZhan] = BagVO:new(BagConsts.BagType_QiZhan),
	-- [BagConsts.BagType_ShenLing] = BagVO:new(BagConsts.BagType_ShenLing)
	[BagConsts.BagType_MingYu] = BagVO:new(BagConsts.BagType_MingYu),
	[BagConsts.BagType_Armor] = BagVO:new(BagConsts.BagType_Armor),
	[BagConsts.BagType_MagicWeapon] = BagVO:new(BagConsts.BagType_MagicWeapon),
	[BagConsts.BagType_LingQi] = BagVO:new(BagConsts.BagType_LingQi),
	[BagConsts.BagType_RELIC] = BagVO:new(BagConsts.BagType_RELIC),
	[BagConsts.BagType_Tianshen] = BagVO:new(BagConsts.BagType_Tianshen)
}

function BagModel:GetBag(type)
	return self.baglist[type];
end

--获取玩家背包内某道具的数量
function BagModel:GetItemNumInBag(itemId)
	local bagVO = self.baglist[BagConsts.BagType_Bag];
	if not bagVO then return 0; end
	local num = 0;
	for k,itemVO in pairs(bagVO.itemlist) do
		if itemVO:GetTid()==itemId then
			num = num + itemVO:GetCount();
		end
	end
	return num;
end

--设置物品组CD时间
function BagModel:SetItemGroupCD(groupId,time)
	if self.itemGroupCDMap[groupId] then
		self.itemGroupCDMap[groupId].time = time;
		self.itemGroupCDMap[groupId].totalTime = time;
	else
		self.itemGroupCDMap[groupId] = {time= time,totalTime=time};
	end
	local needUpdateBagList = {};--需要刷新的背包
	for i,bagVO in pairs(self.baglist) do
		for j,itemVO in pairs(bagVO.itemlist) do
			local cfg = itemVO:GetCfg();
			if cfg and cfg.groupcd==groupId then
				if not needUpdateBagList[bagVO:GetType()] then
					needUpdateBagList[bagVO:GetType()] = true;
				end
			end
		end
	end
	--
	for bagType,_ in pairs(needUpdateBagList) do
		self:sendNotification(NotifyConsts.BagItemCDUpdate,{type=bagType});
	end
end

--更新物品组剩余时间
function BagModel:UpdateItemGroupCD(dwInterval)
	for groupId,vo in pairs(self.itemGroupCDMap) do
		local lastTime = vo.time-dwInterval;
		if lastTime<0 then
			self.itemGroupCDMap[groupId] = nil;
		else
			vo.time = lastTime;
		end
	end
end

--获取物品CD时间
function BagModel:GetItemCD(itemId)
	local cfg = t_item[itemId];
	if not cfg then return 0; end
	if self.itemGroupCDMap[cfg.groupcd] then
		return self.itemGroupCDMap[cfg.groupcd].time;
	end
	return 0;
end

--获取物品的总CD时间
function BagModel:GetItemTotalCD(itemId)
	local cfg = t_item[itemId];
	if not cfg then return 0; end
	if self.itemGroupCDMap[cfg.groupcd] then
		return self.itemGroupCDMap[cfg.groupcd].totalTime;
	end
	return 0;
end

--获取玩家背包内某道具
function BagModel:GetItemInBag(itemId)
	local bagVO = self.baglist[BagConsts.BagType_Bag];
	if not bagVO then return end
	local num = 0;
	local cfg = t_item[itemId];
	if not cfg then return end
	for k, itemVO in pairs(bagVO.itemlist) do
		if itemVO:GetTid() == itemId then
			return itemVO
		end
	end
end

--检查背包内是否可放某物品
function BagModel:CheckCanPutItem(itemId,num)
	if itemId < 999 then
		return true;
	end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return false; end
	local itemCfg = t_item[itemId] or t_equip[itemId];
	if not itemCfg then return false; end
	local leftSize = bagVO:GetSize() - bagVO:GetUseSize();
	local repeats = itemCfg.repeats or 1;
	if leftSize*repeats >= num then
		return true;
	end
	local itemBagSize = bagVO:GetItemUsedSize(itemId);
	local itemNums = BagModel:GetItemNumInBag(itemId);
	if leftSize*repeats + itemBagSize*repeats - itemNums >= num then
		return true;
	else
		return false;
	end
end

--设置物品使用数量列表
function BagModel:SetItemUseNum(list)
	local isHaveBoegey = false;
	for i,vo in ipairs(list) do
		self.itemUseNumList[vo.itemId] = vo;
		self:sendNotification(NotifyConsts.BagItemUseNumChange,{id=vo.itemId});
		for i , v in ipairs(RoleBoegeyConsts.BoegeyID) do
			if vo.itemId == v then 
				isHaveBoegey = true;
			end
		end
		--[[
		for i , v in ipairs(RoleBoegeyConsts.BoegeyVipID) do
			if vo.itemId == v then 
				isHaveBoegey = true;
			end
		end
		--]]
	end
	if isHaveBoegey == true then
		self:sendNotification(NotifyConsts.UpdataBogeyPillChangeList);
	end
end

--获取物品每日使用数量
function BagModel:GetDailyUseNum(id)
	--此功能暂时没有了 
	if self.itemUseNumList[id] then
		return self.itemUseNumList[id].dailyNum;
	end

	return 0;
end

--获取物品一生使用数量
function BagModel:GetLifeUseNum(id)                
	if self.itemUseNumList[id] then
		return self.itemUseNumList[id].lifeNum;
	end
	return 0;
end

-- 根据等级消耗不同数量的物品
function BagModel:GetDailyLimit(id)
	local cfg = t_item[id];
	if not cfg then return 0; end
	if not MainPlayerModel.humanDetailInfo then return 0; end
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	if cfg.daily_limit == "" then return 0; end
	local arr = GetPoundTable(cfg.daily_limit);
	local count = 0;
	for i = #arr, 1, -1 do
		local item = GetCommaTable(arr[i]);
		local lv = toint(item[1]);
		local dailyLimitNum = toint(item[2]);
		if level <= lv then
			count = dailyLimitNum
		end
	end
	return count
end

--获取物品每日可使用的上限
function BagModel:GetDailyTotalNum(id)
	local cfg = t_item[id];
	if not cfg then return 0; end
	if self:GetDailyLimit(id) == 0 then return 0; end
	return self:GetDailyLimit(id) + self:GetDailyExtraNum(id);
end

--获取物品每日可使用的上限 不包括vip
function BagModel:GetDailyTotalWithOutVipNum(id)
	local cfg = t_item[id];
	if not cfg then return 0; end
	if self:GetDailyLimit(id) == 0 then return 0; end
	return self:GetDailyLimit(id)
end

--获取物品一生使用的上限
function BagModel:GetLiftTotalNum(id)
	local cfg = t_item[id];
	if not cfg then return 0; end
	if cfg.zhuan_number ~= "" then
		local defaultNum = toint(ZhuanZhiModel:GetLv()) or 0    --当前玩家的转生阶段
		local t = split(cfg.zhuan_number,",") 
		return toint(t[defaultNum+1]) or 0;
	end
	return cfg.life_limit or 0;
end

--获取物品可使用数量
--@return param1:-1无限,0不能使用,>0可使用数量; param2:param1>=0时,-1每日上限,-2一生上限
function BagModel:GetItemCanUseNum(id)
	local cfg = t_item[id];
	if not cfg then return -2; end
	if self:GetDailyLimit(id)==0 and self:GetLiftTotalNum(id) ==0 then
		return -1;
	end
	--
	if self:GetDailyLimit(id)>0 and self:GetLiftTotalNum(id) ==0 then  --cfg.life_limit==0
		return BagModel:GetDailyTotalNum(id)-BagModel:GetDailyUseNum(id),-1;
	end
	--
	if self:GetDailyLimit(id)==0 and self:GetLiftTotalNum(id) >0 then
		return BagModel:GetLiftTotalNum(id)-BagModel:GetLifeUseNum(id),-2;
	end
	--
	local dayLeft = BagModel:GetDailyTotalNum(id) - BagModel:GetDailyUseNum(id) - BagModel:GetDailyOtherUseExtraNum(id);
	local lifeLeft = BagModel:GetLiftTotalNum(id) - BagModel:GetLifeUseNum(id);
	if lifeLeft < dayLeft then
		return lifeLeft,-2;
	else
		return dayLeft,-1;
	end
end

--获取物品使用每天额外的数量
function BagModel:GetDailyExtraNum(id)
	local cfg = t_item[id];
	if not cfg then return 0; end
	--妖丹VIP额外加成(加)
	if cfg.sub == BagConsts.SubT_YaoDan then
		local vipNum = VipController:YaodanNum()
		if vipNum <= 0 then return 0 end
		local yaodanCfg = t_yaodan[id];
		if not yaodanCfg then return 0; end
		if yaodanCfg.is_vip ~= 0 then return 0; end   --vip丹药的属性加成为0
		return vipNum
	elseif cfg.sub == BagConsts.SubT_TeshuLijinfu then
		local vipNum = VipController:GetTeshuLijinNum()
		if vipNum <= 0 then return 0 end
		
		return vipNum
	elseif cfg.sub == BagConsts.SubT_Box then
		local vipNum = VipController:GetBaoxiangNum()
		if vipNum <= 0 then return 0 end
		
		return vipNum
	end
	
	return 0;
end

--获取同类其他物品已经使用每天额外的数量
function BagModel:GetDailyOtherUseExtraNum(id)
	local cfg = t_item[id];
	if not cfg then return 0; end
	if self:GetDailyExtraNum(id) == 0 then
		return 0;
	end
	--妖丹VIP额外加成
	if cfg.sub == BagConsts.SubT_YaoDan then
		local vipcount = 0;
		for i,vo in pairs(t_yaodan) do
			local usenum = self:GetDailyUseNum(vo.id);
			if usenum > 0 then
				local itemvo = t_item[vo.id];
				if itemvo then
					if usenum > self:GetDailyLimit(itemvo.id) then
						vipcount = vipcount + (usenum - self:GetDailyLimit(itemvo.id));
					end
				end
			end
		end
		local usenum = self:GetDailyUseNum(id);
		if usenum > self:GetDailyLimit(id) then
			return vipcount - (usenum - self:GetDailyLimit(id));
		end
		return vipcount;
	end
	
	return 0;
end

--vip额外使用tips
function BagModel:GetDailyExtraNumTips(id, vipUseNum)
	local cfg = t_item[id];
	if not cfg then return ""; end
	--妖丹VIP额外加成
	local vipStr = ""
	if cfg.sub == BagConsts.SubT_YaoDan then		
		local yaodanCfg = t_yaodan[id];
		if not yaodanCfg then return ""; end
		if yaodanCfg.is_vip ~= 0 then return ""; end
		
		local vipNum = VipController:YaodanNum()
		local vipName = VipController:GetVipNameByIndex(310)
		if vipNum > 0 then 
			vipStr = vipName..'vip额外使用次数：'..RoleBoegeyPillUtil:GetDailyVIPUseNumNew(id)..'/'..vipNum	
		else
			vipStr = VipController:BagExtraNumTips(310)
		end		
	elseif cfg.sub == BagConsts.SubT_TeshuLijinfu then
		local vipNum = VipController:GetTeshuLijinNum()
		local vipName = VipController:GetVipNameByIndex(209)
		if vipNum > 0 then 
			vipStr = vipName..'vip额外使用次数：'..vipUseNum..'/'..vipNum	
		else
			vipStr = VipController:BagExtraNumTips(209,vipUseNum)
		end		
	elseif cfg.sub == BagConsts.SubT_Box then
		local vipNum = VipController:GetBaoxiangNum()
		local vipName = VipController:GetVipNameByIndex(318)
		if vipNum > 0 then
			vipStr = vipName..'vip额外使用次数：<font color="#65c47e">'..vipUseNum..'/'..vipNum..'</font>'
		else
			vipStr = VipController:BagExtraNumTips(318,vipUseNum)
		end		
	end
	
	return vipStr;
end


--生成合成道具map
function BagModel:CreateCompoundMap()
	for id,cfg in pairs(t_itemcompound) do
		local t = split(cfg.materialitem,"#");
		for i,str in ipairs(t) do
			local t1 = split(str,",");
			local id1 = tonumber(t1[1]);
			if not self.compoundMap[id1] then
				self.compoundMap[id1] = id;
			end
		end
	end
end

--- 根据uid获取装备 背包或者身上
function BagModel:GetEquipByUid(id)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	for k, v in pairs(bagVO:GetEquipList()) do
		if v:GetId() == id then
			return v
		end
	end

	bagVO = BagModel:GetBag(BagConsts.BagType_Role)
	for k, v in pairs(bagVO:GetEquipList()) do
		if v:GetId() == id then
			return v
		end
	end 
end