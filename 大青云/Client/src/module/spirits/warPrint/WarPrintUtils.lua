--[[
灵兽战印 工具
wangshuai
]]
_G.WarPrintUtils = {};

WarPrintUtils.atblist = { "att", "def", "hp", "dodge", "hit", "cri", "defcri", "crivalue", "subcri", "absatt", "parryvalue", "defparry", "subdef"}

--得到当前item数据
function WarPrintUtils:OnEquipItemData(info, itemvo, isYuan)
	local vo = t_zhanyin[info.tid]
	if not vo then
		itemvo.isopen = info.isopen;
		itemvo.open = info.isdata;
		itemvo.bagType = info.bagType;
		itemvo.pos = info.pos;
		itemvo.dragType = BagConsts.Drag_S_Item;
		itemvo.acceptType = BagConsts.Drag_S_Item;
		itemvo.iconUrl = "";
		itemvo.openleveltxt = info.openleveltxt;
		return itemvo;
	end;
	itemvo.open = info.isdata;
	itemvo.pos = info.pos;
	itemvo.quality = vo.quality;
	itemvo.isopen = info.isopen;
	itemvo.iconUrl = ResUtil:GetSpiritWarPrintIconURL(vo.iconName);
	if isYuan then
		--3，6，9，这三个位置是大的圆形
		if itemvo.pos == 3 or itemvo.pos == 6 or itemvo.pos == 9 then
			itemvo.qualityUrl = ResUtil:GetSlotYuanQualityLingBaoBig(vo.quality);
		else
			itemvo.qualityUrl = ResUtil:GetSlotYuanQualityLingBaoSmall(vo.quality);
		end
	else
		itemvo.qualityUrl = ResUtil:GetSlotQuality(vo.quality);
	end;
	itemvo.lvl = vo.lvl;
	itemvo.name = vo.name;
	itemvo.bagType = info.bagType;
	itemvo.dragType = BagConsts.Drag_S_Item;
	itemvo.acceptType = BagConsts.Drag_S_Item;
	itemvo.openleveltxt = info.openleveltxt;
	return itemvo;
end

-- 得到当前背包类型的，item
function WarPrintUtils:GetSpiritBagitem(bag)
	local list = {};
	local itemlist = WarPrintModel:GetAllitemList();
	for i, info in pairs(itemlist) do
		if info.bagType == bag then
			table.push(list, info)
		end;
	end;
	return list;
end

-- 得到当前有数据的，item
function WarPrintUtils:GetSpiritHaveDataItem(bag)
	local list = {};
	local itemlist = WarPrintModel:GetAllitemList();
	for i, info in pairs(itemlist) do
		if info.bagType == bag then
			if info.isdata == true then
				table.push(list, info);
			end;
		end;
	end;
	return list;
end

-- 得到商店item，
function WarPrintUtils:OnGetCurShopShowItem()
	local cfg = t_zhanyinachieve;
	local listvo = {}
	local listvoc = {};
	for sj, nm in ipairs(cfg) do
		local vo = {}
		vo.id = nm.id;
		vo.name = nm.name;
		vo.iconUrl = ResUtil:GetSpiritWarPrintIconURL(nm.iconUrl);
		table.push(listvo, UIData.encode(vo));
		table.push(listvoc, vo)
	end;
	return listvo, listvoc
end


--得到长度
function WarPrintUtils:OnGetListLenght(list)
	if not list then return 0 end;
	local num = 0;
	for i, info in pairs(list) do
		num = num + 1;
	end;
	return num;
end


-- 得到当前itemlist里，对象层级
function WarPrintUtils:OnGetItemIndex(bagType, pos)
	local list = WarPrintModel:GetAllitemList()
	for i, info in pairs(list) do
		if info.bagType == bagType then
			if info.pos == pos then
				return i;
			end;
		end;
	end;
end


-- 得到当前item
function WarPrintUtils:OnGetItem(bagType, pos)
	local list = WarPrintModel:GetAllitemList()
	for i, info in pairs(list) do
		if info.bagType == bagType then
			if info.pos == pos then
				return info;
			end;
		end;
	end;
end


-- 得到当前tid  cfg
function WarPrintUtils:OnGetItemCfg(tid)
	if tid == -1 then
		return
	end;
	local cfg = t_zhanyin[tid]
	if not cfg then
		print("Error : cfg is null at WarPrintUtils #104", tid)
		return;
	end;
	return cfg;
end

-- 得到当前item tips vo
function WarPrintUtils:OnGetItemTipsVO(bagType, pos)
	local tipsvo = {};
	local item = self:OnGetItem(bagType, pos);
	if not item then
		print("Error : item is null at WarPrintUtils #109", bagType, pos)
		return
	end;
	local cfg = self:OnGetItemCfg(item.tid);
	if not cfg then
		print("Error : item is null at WarPrintUtils #113", item.tid)
		return
	end;
	tipsvo.cfg = cfg; -- 全部配置
	tipsvo.iconUrl = ResUtil:GetSpiritWarPrintIconURL(cfg.iconName, true);
	tipsvo.value = item.value;
	tipsvo.curlvlatblist = self:OnGetItemAtb(cfg);
	local nextcfg = self:OnGetItemCfg(cfg.nextlvlid)
	if not nextcfg then
		print("Log  : nextcfg is null at WarPrintUtils #128", cfg.nextlvlid)
		nextcfg = {};
	end;
	tipsvo.nextlvlatblist = self:OnGetItemAtb(nextcfg);
	tipsvo.MaxLvlAtbList = self:OnGetItemAtb(self:OnGetItemMaxLvl(cfg.nextlvlid));
	return tipsvo
end

--得到当前item atb属性
function WarPrintUtils:OnGetItemAtb(cfg, pos)
	if not cfg then return end;
	local attrmuti = 1;
	if pos and pos >= 0 then
		attrmuti = t_zhanyinhole[pos + 1].attrmuti;
	end
	local list = {};
	for i, info in pairs(self.atblist) do
		local atb = cfg[info];
		if atb then
			if atb > 0 then
				list[AttrParseUtil.AttMap[info]] = atb * attrmuti;
			end;
		end;
	end;
	return list;
end

-- 得到当前item的满级
function WarPrintUtils:OnGetItemMaxLvl(tid, exp)
	local item = self:OnGetItemCfg(tid)
	if not item then return {} end;
	local AllExp = item.up_exp
	while (item.nextlvlid > 1)
	do
		item = self:OnGetItemCfg(item.nextlvlid)
		AllExp = AllExp + item.up_exp;
	end
	if exp then
		return item, AllExp;
	end;
	return item
end


function WarPrintUtils:OnGetShopItemIndex(list, qua)
	local alIndex = #list;
	local index = math.random(16, 1)
	for i = index, alIndex do
		local cfg = list[i];
		if cfg then
			if cfg.quality == qua then
				return i
			end;
		end;
	end;
	for c = 1, index do
		local cfg = list[c];
		if cfg then
			if cfg.quality == qua then
				return c
			end;
		end;
	end;
end

--获得身上灵宝的属性值列表，isToShow表示是否是界面显示百分比那种的
function WarPrintUtils:OnGetItemAllAtb(isToShow)
	--获得穿身上的灵宝列表
	local list = WarPrintUtils:GetSpiritHaveDataItem(WarPrintModel.spirit_Wear);
	local atblist = {};
	for i, info in pairs(list) do
		--获得对应的配表数据
		local cfg = WarPrintUtils:OnGetItemCfg(info.tid)
		--根据配表得到当前灵宝的属性名字和属性值列表
		local atb = WarPrintUtils:OnGetItemAtb(cfg, info.pos);
		--将属性值汇总
		for ca, no in pairs(atb) do
			local num = atblist[ca];
			if not num then
				atblist[ca] = no;
			else
				atblist[ca] = no + atblist[ca];
			end;
		end;
	end;
	if isToShow then
		return atblist
	end;
	local list = {};
	--转换显示成百分比样式
	for cac, ap in pairs(atblist) do
		if attrIsPercent(cac) then
			list[cac] = string.format("%.2f", tonumber(ap) * 100) .. "%";
		else
			list[cac] = ap;
		end;
		--
	end;
	return list;
end


function WarPrintUtils:OnGetStoreItem()
	local cfg = t_zhanyinexchange;
	local list = {};
	for i, info in pairs(cfg) do
		local itemCfg = WarPrintUtils:OnGetItemCfg(info.id)
		if itemCfg then
			local vo = {};
			vo.tid = info.id;
			vo.quality = itemCfg.quality;
			vo.lvl = itemCfg.lvl
			local myDebris = WarPrintModel.curDebris;
			vo.pres = info.num
			if info.num > myDebris then
				--红色
				vo.debris = "<font color='#ff0000'>" .. info.num .. "</font>";
			else
				vo.debris = "<font color='#29cc100'>" .. info.num .. "</font>";
			end;
			vo.iconUrl = ResUtil:GetSpiritWarPrintIconURL(itemCfg.iconName);
			vo.qualityUrl = ResUtil:GetSlotQuality(itemCfg.quality);
			vo.name = string.format(StrConfig['warprintstore001'], TipsConsts:GetItemQualityColor(vo.quality), itemCfg.name);
			table.push(list, vo);
		end;
	end;

	table.sort(list, function(A, B)
		if A.quality < B.quality then
			return true;
		else
			return false;
		end
	end);

	table.sort(list, function(A, B)
		if A.pres < B.pres then
			return true;
		else
			return false;
		end
	end);
	local uidata = {};
	for i, info in ipairs(list) do
		table.push(uidata, UIData.encode(info))
	end;
	--

	return uidata;
end

;

-- 得到当前item tips vo
function WarPrintUtils:OnGetStoreItemTipsVO(tid)
	local tipsvo = {};
	local cfg = self:OnGetItemCfg(tid);
	if not cfg then
		print("Error : item is null at WarPrintUtils #113")
		return
	end;
	tipsvo.cfg = cfg; -- 全部配置
	tipsvo.iconUrl = ResUtil:GetSpiritWarPrintIconURL(cfg.iconName, true);
	tipsvo.curlvlatblist = self:OnGetItemAtb(cfg);
	local nextcfg = self:OnGetItemCfg(cfg.nextlvlid)
	if not nextcfg then
		print("Error : nextcfg is null at WarPrintUtils #128")
		nextcfg = {};
	end;
	tipsvo.nextlvlatblist = self:OnGetItemAtb(nextcfg);
	tipsvo.MaxLvlAtbList = self:OnGetItemAtb(self:OnGetItemMaxLvl(cfg.nextlvlid));
	return tipsvo
end

;

--  得到总页数
WarPrintUtils.onePage = 24;
function WarPrintUtils:GetListLenght(list)
	local lenght = #list / self.onePage;
	return math.ceil(lenght) - 1;
end

;
-- 得到当前页数下的itemlist
function WarPrintUtils:GetListPage(list, page)
	local vo = {};
	page = page + 1;
	for i = (self.onePage * page) - self.onePage + 1, (self.onePage * page) do
		table.push(vo, list[i])
	end;
	return vo
end

;

--获取格子的开启等级  pos从1开始
function WarPrintUtils:GetOpenNeedLv(pos)
	local cfg = t_zhanyinhole[pos];
	return cfg.level;
end
--获得同一page的配置
function WarPrintUtils:GetExchangeCFGListByPage(page)
	local cfg = {};
	for k, v in pairs(t_zhanyinexchange) do
		if v.page == page then
			table.push(cfg, v);
		end
	end
	return cfg;
end

-- 得到当前item
function WarPrintUtils:GetItemNumByID(bagType, tid)
	local list = WarPrintModel:GetAllitemList()
	local num = 0;
	for i, info in pairs(list) do
		if info.bagType == bagType then
			if info.tid == tid then
				num = num + 1;
			end;
		end;
	end;
	return num;
end