--[[
商店格子VO
lizhuangzhuang
2014年12月6日15:54:43
]]

_G.ShopVO = {};

--商品id
ShopVO.id = 0;

function ShopVO:new()
	local obj = {};
	for k,v in pairs(self) do
		obj[k] = v;
	end
	return obj;
end

--配置
function ShopVO:GetCfg()
	return t_shop[self.id];
end

function ShopVO:GetTid()
	return self.id
end

--物品的配置
function ShopVO:GetItemCfg()
	local cfg = self:GetCfg();
	if not cfg then return; end
	return t_item[cfg.itemId] or t_equip[cfg.itemId];
end

--排序索引
function ShopVO:GetShowIndex()
	local cfg = self:GetCfg();
	if cfg then return cfg.showIndex; end
	return 0;
end

--获取物品的使用等级
function ShopVO:GetNeedLevel()
	local itemCfg = self:GetItemCfg();
	if not itemCfg then return 0; end
	return itemCfg.needlevel;
end

--获取绑定状态
function ShopVO:GetBind()
	local cfg = self:GetCfg();
	if not cfg then
		return BagConsts.Bind_None;
	end
	if cfg.bind == BagConsts.Bind_GetBind then
		return BagConsts.Bind_GetBind;
	else
		local itemCfg = self:GetItemCfg();
		if itemCfg then
			return itemCfg.bind;
		end
	end
	return BagConsts.Bind_None;
end

function ShopVO:GetPlayerMoney()
	local cfg = self:GetCfg();
	if not cfg then return end
	local moneyType = cfg.moneyType
	return ShopUtils:GetMoneyByType(moneyType)
end

-- 根据商品id获取商店购买物品确认面板所需数据：物品名称，物品价格，最大堆叠，货币类型, 货币图标url, iconUIData
function ShopVO:GetItemInfo( id )
	local cfg = self:GetCfg()
	if not cfg then return; end
	local itemId = cfg.itemId;
	if not itemId then return; end
	local itemCfg = t_item[itemId] or t_equip[itemId];
	if not itemCfg then return; end
	local itemNum = cfg.itemNum
	local suffix = itemNum > 1 and ("×" .. itemNum) or ""
	local itemName  = itemCfg.name .. suffix; --物品名称
	local itemColor = ShopUtils:GetItemQualityColor( itemId )
	local maxPile   = itemCfg.repeats or 1; --最大堆叠
	local from      = itemCfg.from or nil;  --物品获得说明方式
	return itemName, itemColor, maxPile,from
end

function ShopVO:GetPrice()
	local cfg = self:GetCfg()
	return cfg and cfg.price
end

function ShopVO:GetPriceLabel()
	return string.format( "%s", self:GetPrice() )
end

function ShopVO:GetCostFormat()
	return "%s"
end

function ShopVO:GetPrompt(bottleneck)
	return ShopConsts.MaxBuyMap[bottleneck]
end

function ShopVO:GetConsumeInfo()
	local cfg = self:GetCfg()
	if not cfg then return end
	local moneyType    = cfg.moneyType; --货币类型
	local moneyIconURL = ResUtil:GetMoneyIconURL( moneyType );
	return moneyType, moneyIconURL
end

--@hoxudong for:快速购买获取绑元或元宝
function ShopVO:GetQuickConsumeInfo()
	local cfg = self:GetCfg()
	if not cfg then return end
	local moneyShowType = cfg.showType;  -- 获取商店类型
	local moneyType;
	if moneyShowType == 2 then
		moneyType = moneyShowType + 10;
	elseif moneyShowType == 3 then
		moneyType = moneyShowType + 10;
	end 
	local moneyIconURL = ResUtil:GetMoneyIconURL( moneyType )
	return moneyType, moneyIconURL
end

function ShopVO:ShowConsumeTips()
	local moneyType, _ = self:GetConsumeInfo()
	if not moneyType then return; end
    TipsManager:ShowBtnTips( ShopUtils:GetMoneyNameByType(moneyType));
end

--获取UIData
function ShopVO:GetUIData()
	return self:GetItemUIData() .."*".. self:GetIconUIData();
end

--获取Item的UIData
function ShopVO:GetItemUIData()
	local data = {};
	data.id = self.id;
	local cfg = self:GetCfg();
	data.nameColor = ShopUtils:GetItemQualityColor(cfg.itemId);
	data.itemName = ShopUtils:GetItemNameById(cfg.itemId);
	data.price = cfg.price;
	data.iconMoneyURL = ResUtil:GetMoneyIconURL( cfg.moneyType );
	return UIData.encode(data);
end

--获取图标的UIData
function ShopVO:GetIconUIData()
	local cfg = self:GetCfg();
	if not cfg then return ""; end
	local rewardSlotVO = RewardSlotVO:new();
	rewardSlotVO.id = cfg.itemId;
	rewardSlotVO.count = 0;
	rewardSlotVO.bind = self:GetBind();
	return rewardSlotVO:GetUIData();
end
-- wangshuai
-- 获取商城 uidata
function ShopVO:GetShoppingItemUIData()
	return self:GetShoppingIconData() .."*".. self:GetIconUIData();
end;
-- 图标data
function ShopVO:GetShoppingIconData()
	local data = {};
	data.id = self.id;
	local cfg = self:GetCfg();
	local namecolor = ShopUtils:GetItemQualityColor(cfg.itemId);
	data.nameColor = namecolor
	data.name = ShopUtils:GetItemNameById(cfg.itemId);
	data.falseMoney = cfg.priceFalse;
	data.falseMoneyStr = string.format(StrConfig['shoppingmall004'],cfg.priceFalse)
	data.money = string.format(StrConfig['shoppingmall002'],cfg.price)
	data.moneySource = ResUtil:GetMoneyIconURL(cfg.moneyType);
	return UIData.encode(data);
end;
-- 获取honor UIdata
function ShopVO:GetHonorUIdata()
	return self:GetHonorItemUIData().."*"..self:GetIconUIData();
end;
-- 获取honor的uidate
function ShopVO:GetHonorItemUIData()
	local data = {};
	data.id = self.id;
	local cfg = self:GetCfg();
	local cfgitem = t_item[cfg.itemId]
	data.name =string.format(StrConfig["shop504"],TipsConsts:GetItemQualityColor(cfgitem.quality),ShopUtils:GetItemNameById(cfg.itemId));    -- 名字
	data.honor = string.format(StrConfig["shop502"],cfg.price); -- 消耗荣誉
	

	local num = ShopModel:GetDayLimitItemHasBuyNum(self.id)

	local lanum = cfg.dayLimit-num;

	data.lanum = cfg.dayLimit-num

	if lanum == 0 then 
		data.buynum = string.format(StrConfig["shop503"],"#ff0000",lanum,cfg.dayLimit); -- 数量
	else
		data.buynum = string.format(StrConfig["shop503"],"#00ff00",lanum,cfg.dayLimit); -- 数量
	end;
	if cfg.dayLimit == 0 then 
		data.buynum = StrConfig["shop508"];
	end;
	
	return UIData.encode(data)
end;
-- 获取功勋 UIdata
function ShopVO:GetGongxunUIdata()
	return self:GetGongxunItemUIData().."*"..self:GetIconUIData();
end;
-- 获取功勋的uidate
function ShopVO:GetGongxunItemUIData()
	local data = {};
	data.id = self.id;
	local cfg = self:GetCfg();
	local cfgitem = t_item[cfg.itemId]
	data.name =string.format(StrConfig["shop511"],TipsConsts:GetItemQualityColor(cfgitem.quality),ShopUtils:GetItemNameById(cfg.itemId));    -- 名字
	local myHonor = MainPlayerModel.humanDetailInfo.eaCrossExploit
	local colorStr = '#00ff00'
	if myHonor < cfg.price then
		colorStr = '#ff0000'
	end
	
	data.honor = string.format(StrConfig["shop509"],colorStr, cfg.price); -- 消耗荣誉	

	local num = ShopModel:GetDayLimitItemHasBuyNum(self.id)

	local lanum = cfg.dayLimit-num;

	data.lanum = cfg.dayLimit-num

	if lanum == 0 then 
		data.buynum = string.format(StrConfig["shop510"],"#FF0000",lanum,cfg.dayLimit); -- 数量
	else
		data.buynum = string.format(StrConfig["shop510"],"#00FF00",lanum,cfg.dayLimit); -- 数量
	end;
	if cfg.dayLimit == 0 then 
		data.buynum = StrConfig["shop515"];
	end;
	
	return UIData.encode(data)
end;

function ShopVO:DoBuy(num)
	ShopController:ReqBuyItem( self.id, num );
end


-- 获取honor UIdata
function ShopVO:GetinterSSceneUIdata()
	return self:GetinterSSUIData().."*"..self:GetIconUIData();
end;
-- 获取honor的uidate
function ShopVO:GetinterSSUIData()
	local data = {};
	data.id = self.id;
	local cfg = self:GetCfg();
	local cfgitem = t_item[cfg.itemId]
	if not cfgitem then 
		cfgitem = t_equip[cfg.itemId]
		if not cfgitem then 
			print(debug.traceback(),cfg.itemId)
			return "" 
		end;
		end;
	data.name =string.format(StrConfig["shop504"],TipsConsts:GetItemQualityColor(cfgitem.quality),ShopUtils:GetItemNameById(cfg.itemId));    -- 名字
	data.honor = string.format(StrConfig["shop901"],cfg.price); -- 消耗荣誉
	

	local num = ShopModel:GetDayLimitItemHasBuyNum(self.id)

	local lanum = cfg.dayLimit-num;

	data.lanum = cfg.dayLimit-num

	if lanum == 0 then 
		data.buynum = string.format(StrConfig["shop503"],"#ff0000",lanum,cfg.dayLimit); -- 数量
	else
		data.buynum = string.format(StrConfig["shop503"],"#00ff00",lanum,cfg.dayLimit); -- 数量
	end;
	if cfg.dayLimit == 0 then 
		data.buynum = StrConfig["shop508"];
	end;
	
	return UIData.encode(data)
end;