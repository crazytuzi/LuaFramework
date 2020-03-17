--背包VO
--使用格子当索引

_G.BagVO = {};

--
--@param bagType 背包类型
function BagVO:new(bagType)
	local obj = {};
	for k,v in pairs(BagVO) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	obj.bagType = bagType;
	obj.itemlist = {};
	obj.size = 0;
	--初始化默认容量,总容量
	obj.defaultSize = BagConsts:GetBagDefaultSize(bagType);
	obj.totalSize = BagConsts:GetBagTotalSize(bagType);
	--自动开启下一格子时间
	obj.openNextTime = 0;
	TimerManager:RegisterTimer(function()
					if obj.openNextTime <= 0 then return; end
					obj.openNextTime = obj.openNextTime - 1;
				end,1000,0)
	return obj;
end

--获取背包类型
function BagVO:GetType()
	return self.bagType;
end

--增加Item
function BagVO:AddItem(item)
	if self.itemlist[item:GetPos()] then
		Debug("error:格子上已有物品.BagType:"..self.bagType..",Pos:"..item:GetPos());
		return;
	end
	self.itemlist[item:GetPos()] = item;
	Notifier:sendNotification(NotifyConsts.BagAdd, {type=self.bagType,pos=item:GetPos()});
	self:DoBagCapacityChange();
	if self.bagType == BagConsts.BagType_Bag then
		Notifier:sendNotification(NotifyConsts.BagItemNumChange,{id=item:GetTid()});
		self:showLingshouRemind(item:GetTid())
		EquipSmeltingManager:OnAutoSmelting(item)
		EquipSmeltingManager:RemindSmelting(item:GetTid());
		UIGiftsManager:OpenStoneNotice(item:GetTid());
	end
end

--移除Item
function BagVO:RemoveItem(pos)
	if not self.itemlist[pos] then
		return nil;
	end
	local removeItem = self.itemlist[pos];
	self.itemlist[pos] = nil;
	Notifier:sendNotification(NotifyConsts.BagRemove, {type=self.bagType,pos=removeItem:GetPos(),id=removeItem:GetId()});
	self:DoBagCapacityChange();
	if self.bagType == BagConsts.BagType_Bag then
		Notifier:sendNotification(NotifyConsts.BagItemNumChange,{id=removeItem:GetTid()});
	end
	return removeItem;
end

--更新物品
function BagVO:UpdateItem(id,tid,count,pos,useCnt,todayUse,flags,param1, param2, param4)
	if not self.itemlist[pos] then
		Debug("error:更新物品失败,指定位置没有该物品.BagType:"..self.bagType..",Pos:"..pos);
		local errorMsg = "error:更新物品失败,指定位置没有该物品.BagType:"..self.bagType..",Pos:"..pos..",tid:"..tid;
		_debug:throwException(errorMsg)
		return 0;
	end
	local item = self.itemlist[pos];
	if item:GetId() ~= id then
		Debug("error:更新物品失败,id不符");
		return 0;
	end
	local oldCount = item:GetCount();
	item:SetTid(tid);
	item:SetCount(count);
	item:SetFlags(flags);
	item:SetUseCnt(useCnt);
	item:SetTodayUse(todayUse);
	item:SetParam(param1)
	item:SetParam2(param2)
	item:SetParam4(param4)
	Notifier:sendNotification(NotifyConsts.BagUpdate, {type=self.bagType,pos=pos});
	if self.bagType == BagConsts.BagType_Bag then
		Notifier:sendNotification(NotifyConsts.BagItemNumChange,{id=item:GetTid()});
		self:showLingshouRemind(item:GetTid())
	end
	return oldCount;
end

--清空所有item
function BagVO:RemoveAllItem()
	for pos,v in pairs(self.itemlist) do
		self.itemlist[pos] = nil;
	end
	self.size = 0;
end

function BagVO:showLingshouRemind(itemId)
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	if itemId ~= SpiritsModel:getWuhuVO().feedItem then return end
	
	local cfg = t_wuhun[SpiritsModel:getWuhuVO().wuhunId]
	local feedTable = cfg.feed_consume
	local feedItemId = feedTable[1]
	local feedItemNum = feedTable[2]
	
	local feedNum = SpiritsModel.currentWuhun.feedNum
	local shangxian = cfg.feed_progress -- 喂养进度上限
	local bagItemNum = BagModel:GetItemNumInBag(feedItemId) or 0 --背包中的魂珠数量
	
	local guanzhuNum = toint(bagItemNum/feedItemNum)
	if feedNum < shangxian*5 then
		local maxNum = shangxian*5 - feedNum
		if guanzhuNum >= maxNum or guanzhuNum >= 5 then 
			if UIzhanshou:IsShow() == false then 
				UIItemGuide:Open(12);
			end;
		end
	end
end

--设置物品列表
function BagVO:SetItemList(list)
	self.itemlist = {};
	for i,data in pairs(list) do
		local item = BagItem:new(data.id,data.tid,data.count,data.bag,data.pos,data.useCnt,data.todayUse,data.flags,data.param1, data.param2, data.param4);
		self.itemlist[item:GetPos()] = item;
	end
	Notifier:sendNotification(NotifyConsts.BagRefresh, {type=self.bagType});
	self:DoBagCapacityChange();
end

--获取Item列表
function BagVO:GetItemList()
	return self.itemlist;
end

--获取指定位置的Item
function BagVO:GetItemByPos(pos)
	return self.itemlist[pos];
end

--根据cid获取物品
function BagVO:GetItemById(id)
	for i,item in pairs(self.itemlist) do
		if item:GetId() == id then
			return item;
		end
	end
end

--获取背包已经开启的总容量
function BagVO:GetSize()
	return self.size;
end

function BagVO:SetSize(size)
	if size<self.size then
		Debug("error:背包容量不能减小.BagType:"..self.bagType);
		return;
	end
	local oldSize = self.size;
	self.size = size;
	Notifier:sendNotification(NotifyConsts.BagSlotOpen, {type=self.bagType,oldSize=oldSize,newSize=size});
	self:DoBagCapacityChange();
end

--获取某物品的背包使用量
function BagVO:GetItemUsedSize( tid )
	local num = 0;
	for k,item in pairs(self.itemlist) do
		if item:GetTid() == tid then
			num = num + 1;
		end
	end
	return num;
end

--获取背包当前使用量
function BagVO:GetUseSize()
	local num = 0;
	for k,v in pairs(self.itemlist) do
		num = num + 1;
	end
	return num;
end

--背包的默认容量
function BagVO:GetDefaultSize()
	return self.defaultSize;
end

--背包可以开启的总容量
function BagVO:GetTotalSize()
	return self.totalSize;
end

--可以使用的数量
function BagVO:GetFreeSize()
	return self:GetSize() - self:GetUseSize();
end

--根据显示分类获取物品列表
function BagVO:GetItemListByShowType(showType)
	if showType == BagConsts.ShowType_All then
		return self.itemlist;
	end
	local list = {};
	for i,item in pairs(self.itemlist) do
		if item:GetShowType() == showType then
			table.push(list,item);
		end
	end
	return list;
end

--获取人物可穿戴装备
function BagVO:GetEquipList()
	local list = {};
	for i,item in pairs(self.itemlist) do
		if item:GetShowType() == BagConsts.ShowType_Equip then
			local itemCfg = item:GetCfg();
			if itemCfg.pos >= BagConsts.Equip_WuQi and itemCfg.pos <= BagConsts.Equip_JieZhi2 then
				table.push(list,item);
			end
		end
	end
	return list;
end

--根据子类获取道具列表
function BagVO:BagItemListBySub(subType)
	local list = {};
	for i,item in pairs(self.itemlist) do
		if item:GetShowType()~=BagConsts.ShowType_Equip and item:GetCfg().sub==subType then
			table.push(list,item);
		end
	end
	return list;
end

--寻找一个空位置,没有返回-1
function BagVO:FindEmptyPos()
	for i=0,self.size-1 do
		if not self.itemlist[i] then
			return i;
		end
	end
	return -1;
end

--开启下一格子时间
function BagVO:SetOpenNextTime(time)
	self.openNextTime = time;
end
function BagVO:GetOpenNextTime()
	return self.openNextTime<0 and 0 or self.openNextTime;
end

--检查背包容量
function BagVO:DoBagCapacityChange()
	if self.bagType == BagConsts.BagType_Bag then
		local func = FuncManager:GetFunc(FuncConsts.Bag);
		if not func then return; end
		local useSize = self:GetUseSize();
		local totalSize = self:GetSize();
		func:OnBagCapacityChange(useSize,totalSize);
	end
end

--按顺序获取背包里的物品ID(用于套装)
function BagVO:GetGroupEList()
	local list = {};
	for i=0,self.totalSize do
		if self.itemlist[i] then
			local vo = {};
			local cid = self.itemlist[i]:GetId()
			vo.id = self.itemlist[i]:GetTid();
			vo.groupId = EquipModel:GetGroupId(cid);
			vo.groupId2 = EquipUtil:GetEquipGroupId(vo.id)
			vo.groupId2Level = 0 --EquipModel:GetEquipGroupLevel(cid);
			vo.pos = self.itemlist[i]:GetPos()
			table.push(list,vo);
		end
	end
	return list;
end
