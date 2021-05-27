--------------------------------------------------------
--商城相关数据
--------------------------------------------------------
SHOP_CFG_NAME = {"1ReXiaoDaoJu", "2BuJiYaoPin", "3JingYanDaoJu", "4QiZhenYiBao", 
					"5ShiZhuangShenQi", "6LijinShangCheng", "7JiFenShangCheng", "8BangJinShangCheng"}

ShopData = ShopData or BaseClass()
ShopData.MYSTICAL_DATA_CHANGE = "mystical_data_change"
ShopData.SHOP_LIMIT_CHANGE = "shop_limit_change"
function ShopData:__init()
	if ShopData.Instance then
		ErrorLog("[ShopData] Attemp to create a singleton twice !")
	end
	ShopData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
	
	self.shop_item_list = {}
	self.mystical_shop_info = {
		refre_left_time = 0,
		client_time = 0,
		item_list = {},
	}
	self.shop_limit_list = {}

end

function ShopData:__delete()
	ShopData.Instance = nil
end

--获取商城的配置文件 区分跨服
function ShopData.GetShopCfg(index)
	local cfg_t = {}
	if SHOP_CFG_NAME[index] then
		local is_on_crossserver = IS_ON_CROSSSERVER
		local cfg = ConfigManager.Instance:GetServerConfig("store/ShangPu/" .. SHOP_CFG_NAME[index])[1].items
		for _, item in pairs(cfg) do
			if (not is_on_crossserver or (item.canBuyInCross and item.canBuyInCross == 1)) then
				table.insert(cfg_t, item)
			end
		end
	end
	return cfg_t
end

ShopData.cross_server_shop_cfg = nil -- 跨服时开放使用的物品
function ShopData.GetCrossServerItemCanUse(item_id)
	if nil == ShopData.cross_server_shop_cfg then
		ShopData.cross_server_shop_cfg = {}
		local is_on_crossserver = IS_ON_CROSSSERVER
		local cfg
		cfg = ConfigManager.Instance:GetServerConfig("store/ShangPu/" .. SHOP_CFG_NAME[3])[1].items
		for _, item in pairs(cfg) do
			if (not is_on_crossserver or (item.canBuyInCross and item.canBuyInCross == 1)) then
				ShopData.cross_server_shop_cfg[item.item] = true
			end
		end
		cfg = ConfigManager.Instance:GetServerConfig("store/ShangPu/" .. SHOP_CFG_NAME[4])[1].items
		for _, item in pairs(cfg) do
			if (not is_on_crossserver or (item.canBuyInCross and item.canBuyInCross == 1)) then
				ShopData.cross_server_shop_cfg[item.item] = true
			end
		end
		cfg = ConfigManager.Instance:GetServerConfig("store/ShangPu/" .. SHOP_CFG_NAME[5])[1].items
		for _, item in pairs(cfg) do
			if (not is_on_crossserver or (item.canBuyInCross and item.canBuyInCross == 1)) then
				ShopData.cross_server_shop_cfg[item.item] = true
			end
		end
	end

	return not ShopData.cross_server_shop_cfg[item_id]
end

function ShopData.GetItemPriceCfg(item_id, price_type, id)
	local function get_price_cfg(index)
		if SHOP_CFG_NAME[index] then
			local cfg = ConfigManager.Instance:GetServerConfig("store/ShangPu/" .. SHOP_CFG_NAME[index])[1].items
			for k,v in pairs(cfg) do
				if v.item == item_id then

					if price_type and v.price[1].type == price_type and (id == v.id or id == nil) then
						return v
					elseif price_type == nil then
						return v
					end
				end
			end
			index = index + 1
			return get_price_cfg(index)
		else
			Log("商城配置 store/ShangPu/... 无该物品")
			return nil
		end
	end
	return get_price_cfg(1)
end

function ShopData:BuyReplyResult(protocol)
	self.buy_result = protocol.is_succeed
end

function ShopData:SetMysticalShopData(protocol)
	self.mystical_shop_info = protocol
	self:DispatchEvent(ShopData.MYSTICAL_DATA_CHANGE)
end

function ShopData:GetMyRefreLeftTime()
	local now_left_time = self.mystical_shop_info.refre_left_time - (Status.NowTime - self.mystical_shop_info.client_time)
	return math.max(now_left_time, 0)
end

-- 神秘商城商品列表
function ShopData:GetMysticalShopList()
	local list = {}
	if self.mystical_shop_info then
		for k, v in pairs(self.mystical_shop_info.item_list) do
			--判断购买标记buy_mark和本地是否存在物品配置
			if v.buy_mark ~= 1 and self.MysticalShopCfg(v) ~= nil then
				list[#list + 1] = {shop_cfg = self.MysticalShopCfg(v), data = v}
			end
		end
	end
	
	return list
end

-- 神秘商城商品配置
function ShopData.MysticalShopCfg(data)
	local item_cfg
	if data.type == 1 then
		item_cfg = SecretShopConfig.material
	elseif data.type == 2 then
		item_cfg = SecretShopConfig.equip
	else
		return nil
	end

	if item_cfg[data.index] then
		return item_cfg[data.index]
	else
		return nil
	end
end

function ShopData:SetShopLimitInfo(protocol)
	for k, v in pairs(protocol.shop_limit_list) do
		self.shop_limit_list[v.shop_id] = v.can_buy_num
	end
	self:DispatchEvent(ShopData.SHOP_LIMIT_CHANGE)
end

-- 商品剩余购买次数(有限购的)
function ShopData:GetShopLeftBuyTimes(shop_id)
	return self.shop_limit_list[shop_id]
end

function ShopData.GetMoneyTypeIcon(price_type)
	if price_type == MoneyType.BindCoin then
		return ResPath.GetCommon("bind_coin")
	elseif price_type == MoneyType.Coin then
		return ResPath.GetCommon("bind_gold")
	elseif price_type == MoneyType.BindYuanbao then
		return ResPath.GetCommon("bind_gold")
	elseif price_type == MoneyType.Yuanbao then
		return ResPath.GetCommon("gold")
	elseif price_type == MoneyType.StorePoint then
		return ResPath.GetCommon("gold")
	elseif price_type == MoneyType.Honour then
		return ResPath.GetCommon("gold")
	elseif price_type == MoneyType.ZhanXun then
		return ResPath.GetCommon("gold")
	elseif price_type == MoneyType.Energy then
		return ResPath.GetCommon("gold")
	elseif price_type == MoneyType.Ticket then
		return ResPath.GetCommon("ticket")
	elseif price_type == MoneyType.Yongzhe then
		return ResPath.GetCommon("yz_score")
	elseif price_type == MoneyType.RedDiamond then
		return ResPath.GetCommon("red_drill")
	end
end

function ShopData.GetMoneyTypeName(price_type)
	if price_type == MoneyType.BindCoin then
		return Language.Common.BindCoin
	elseif price_type == MoneyType.Coin then
		return Language.Common.Coin
	elseif price_type == MoneyType.BindYuanbao then
		return Language.Common.BindGold
	elseif price_type == MoneyType.Yuanbao then
		return Language.Common.Diamond
	elseif price_type == MoneyType.StorePoint then
		return Language.Common.Coin
	elseif price_type == MoneyType.Honour then
		return Language.Common.Coin
	elseif price_type == MoneyType.ZhanXun then
		return Language.Common.Coin
	elseif price_type == MoneyType.Energy then
		return Language.Common.Coin
	elseif price_type == MoneyType.Ticket then
		return Language.Common.Ticket
	elseif price_type == MoneyType.Yongzhe then
		return Language.Common.YzScore
	elseif price_type == MoneyType.RedDiamond then
		return Language.Common.RedDiamond
	end
end

function ShopData.GetMoneyObjAttrIndex(price_type)
	if price_type == MoneyType.BindCoin then
		return OBJ_ATTR.ACTOR_BIND_COIN
	elseif price_type == MoneyType.Coin then
		return OBJ_ATTR.ACTOR_COIN
	elseif price_type == MoneyType.BindYuanbao then
		return OBJ_ATTR.ACTOR_BIND_GOLD
	elseif price_type == MoneyType.Yuanbao then
		return OBJ_ATTR.ACTOR_GOLD
	elseif price_type == MoneyType.StorePoint then
		return OBJ_ATTR.ACTOR_GOLD
	elseif price_type == MoneyType.Honour then
		return OBJ_ATTR.ACTOR_GOLD
	elseif price_type == MoneyType.ZhanXun then
		return OBJ_ATTR.ACTOR_GOLD
	elseif price_type == MoneyType.Energy then
		return OBJ_ATTR.ACTOR_GOLD
	elseif price_type == MoneyType.Yongzhe then
		return OBJ_ATTR.ACTOR_BRAVE_POINT
	elseif price_type == MoneyType.RedDiamond then
		return OBJ_ATTR.ACTOR_RED_DIAMONDS
	end
end

function ShopData.GetShopItemCfgByIndexAndItemId(index, item_id)
	
	if SHOP_CFG_NAME[index] then
		local is_on_crossserver = IS_ON_CROSSSERVER
		local cfg = ConfigManager.Instance:GetServerConfig("store/ShangPu/" .. SHOP_CFG_NAME[index])[1].items
		for _, item in pairs(cfg) do
			if (not is_on_crossserver or (item.canBuyInCross and item.canBuyInCross == 1)) then
				if item.item == item_id then
					return item
				end
			end
		end
	end
	return nil
end