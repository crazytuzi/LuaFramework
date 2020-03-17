--[[
灵兽model
wangshaui
]]
_G.WarPrintModel = Module:new()

WarPrintModel.spirit_Wear = 0; -- 穿身上的
WarPrintModel.spirit_Bag = 1; -- 背包；
WarPrintModel.spirit_House = 2; -- 仓库
WarPrintModel.warprintmaxlvl =10;
WarPrintModel.curDebris = 0; -- 当前分解碎片
WarPrintModel.dongTianLv = 1;
WarPrintModel.itemlist = {};
WarPrintModel.fightScore = 0;
WarPrintModel.tianHeXingShaID = 9000000;
function WarPrintModel:OnTextInfo()
	local list1 = {};
	for i=1,2 do 
		local vo = {};
		vo.tid = 1001000+i;
		vo.value = math.random(100);
		vo.pos = i;
		vo.bagType = 1;
		table.push(list1,vo)
	end;

	for c=1,10 do 
		local vo = {};
		vo.tid = 2002000+c;
		vo.value = math.random(100);
		vo.pos = c;
		vo.bagType = 2;
		table.push(list1,vo)
	end;

	for a=1,10 do 
		local vo = {};
		vo.tid = 4003000+a;
		vo.value = math.random(100);
		vo.pos = a;
		vo.bagType = 3;
		table.push(list1,vo)
	end;
	--self:OnSetBagInfo(list1);
end;

function WarPrintModel:GetBagLastNum()
	local num = 0;
	for i,info in pairs(self.itemlist) do 
		if info.bagType == self.spirit_Bag then 
			if info.isdata == true then 
				num = num + 1;
			end;
		end;
	end;
	local const = t_consts[57]
	return const.val2 - num;
end;

function WarPrintModel:InitInfo()
	local cfg = t_consts[57]
	local rolee = cfg.val1-1
	local bage = cfg.val2-1;
	local housee = cfg.val3-1;
	self.itemlist = {};
	for i=0,rolee do 
		local vo = {};
		vo.isopen = false;
		vo.pos = i;
		vo.bagType = self.spirit_Wear;
		vo.isdata = false;
		--开启等级
		local holeCFG = t_zhanyinhole[i + 1];
		vo.openleveltxt = string.format(StrConfig["warprintstore033"], holeCFG.level);
		table.push(self.itemlist,vo)
	end;
	for c=0,bage  do 
		local vo ={};
		vo.pos = c;
		vo.isopen = false;
		vo.bagType = self.spirit_Bag;
		vo.isdata = false;
		table.push(self.itemlist,vo)
	end;
	for b=0,housee do 
		local vo = {};
		vo.pos = b;
		vo.isopen = false;
		vo.bagType = self.spirit_House;
		vo.isdata = false;
		table.push(self.itemlist,vo)
	end;
end;

function WarPrintModel:SetOpenState()
	local playerLv = MainPlayerModel.humanDetailInfo.eaLevel;
	local cfg = t_consts[57] --配置了战印各个背包的大小
	local rolee = cfg.val1-1
	for i=0,rolee do
		local index = WarPrintModel:GetBagData(self.spirit_Wear,i);
		local data = self.itemlist[index];
		for k, v in pairs(t_zhanyinhole) do
			if v.id == (i+1) then
				local openLv = v.level;
				if playerLv >= openLv then
					data.isopen = true;
				else
					data.isopen = false;
				end
				break;
			end
		end

	end;
end;

-- all bag info
function WarPrintModel:OnSetBagInfo(list)
	for i,info in ipairs(list) do 
		local index = WarPrintUtils:OnGetItemIndex(info.bagType,info.pos)
		local vo = self.itemlist[index]
		vo.tid = info.tid;
		vo.value = info.value;
		vo.pos = info.pos;
		vo.bagType = info.bagType;
		vo.isdata = true;
		--table.push(self.itemlist,vo)
	end;
	-- 背包更新
	--trace(self.itemlist)
	--print("item更新")

end;

-- add item 
function WarPrintModel:OnSpiritAddItem(tid,value,pos,bagType)
	local index = WarPrintUtils:OnGetItemIndex(bagType,pos)
	local vo = self.itemlist[index]
	vo.tid = tid;
	vo.value = value;
	vo.pos = pos;
	vo.bagType = bagType;
	vo.isdata = true;
	Notifier:sendNotification(NotifyConsts.SpiritWarPrintItemAdd,pos);

end;

-- remove item
function WarPrintModel:OnSpiritRemoveItem(pos,bagType)
	local len = WarPrintUtils:OnGetListLenght(self.itemlist);
	local index = WarPrintUtils:OnGetItemIndex(bagType,pos) 
	local item = self.itemlist[index];
	item.isdata = false;
	item.tid = 0;
	item.value = 0;
	Notifier:sendNotification(NotifyConsts.SpiritWarPrintItemRemove,pos);
end;

-- updata item 
function WarPrintModel:OnSpiritUpdataItem(tid,value,pos,bagType)
	local index = WarPrintUtils:OnGetItemIndex(bagType,pos);
	local vo = self.itemlist[index]
	vo.tid = tid;
	vo.value = value;
	vo.pos = pos;
	vo.bagType = bagType;
	Notifier:sendNotification(NotifyConsts.SpiritWarPrintItemUpdata,pos);
end

--swap result
function WarPrintModel:OnSpiritSwapItem(vo)
	if vo.result ~= 0 then 
		-- 交换不成功
		return 
	end;
	local srcindex = WarPrintUtils:OnGetItemIndex(vo.src_bag,vo.src_idx);
	local srcitem = WarPrintUtils:OnGetItem(vo.src_bag,vo.src_idx);
	local dstindex = WarPrintUtils:OnGetItemIndex(vo.dst_bag,vo.dst_idx);
	local dstitem = WarPrintUtils:OnGetItem(vo.dst_bag,vo.dst_idx);


	srcitem.bagType = vo.dst_bag;
	srcitem.pos = vo.dst_idx;

	dstitem.bagType = vo.src_bag;
	dstitem.pos = vo.src_idx;
	dstitem.isopen,srcitem.isopen = srcitem.isopen,dstitem.isopen;
	self.itemlist[srcindex],self.itemlist[dstindex] = self.itemlist[dstindex],self.itemlist[srcindex]

	Notifier:sendNotification(NotifyConsts.SpiritWarPrintItemSwap);
end;

-- Debris result
function WarPrintModel:OnSpiritDebrisResult(vo)
	if vo.result ~= 0 then 
		-- 分解不成功
		return ;
	end;
	self:OnSpiritDebrisNum(vo.debris);
end;

-- shoping result
function WarPrintModel:OnSpiritShopintResult(vo)
	if vo.result ~= 0 then 
		-- 购买不成功
		UIWarPrintShop:StopGoldDuoClick();
		return;
	end;
	local item = {};
	item.tid = vo.cid;
	item.pos = vo.pos;
	item.bagType=  vo.bagType;
	Notifier:sendNotification(NotifyConsts.SpiritWarPrintShoping,item);

end;

-- debris num 
function WarPrintModel:OnSpiritDebrisNum(num, isBuyResult)
	if num > self.curDebris and isBuyResult then
		--银两获取的时候产生了天河星沙
		local item = {};
		item.tid = self.tianHeXingShaID;
		item.pos = -1;
		item.bagType = -1;
		Notifier:sendNotification(NotifyConsts.SpiritWarPrintShoping,item);
	end

	self.curDebris = num;
	Notifier:sendNotification(NotifyConsts.SpiritWarPrintDebris);
end;




-------------------------get
function WarPrintModel:GetAllitemList()
	return self.itemlist;
end;

function WarPrintModel:GetDebrisNum()
	return self.curDebris;
end;

function WarPrintModel:GetBagData(type,index)
	local list = {};
	for i,info in pairs(self.itemlist) do 
		if info.bagType == type then 
			if info.pos == index then 
				return i;
			end;
		end;
	end;
end;
