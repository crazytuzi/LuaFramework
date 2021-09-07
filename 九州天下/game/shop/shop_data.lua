ShopData = ShopData or BaseClass()

SHOP_BIND_TYPE =
{
	BIND = 1,
	NO_BIND = 2,

	IS_LIMUIT = 5, --限购商城

}

ShopData.SHOP_COL_ITEM = 2

function ShopData:__init()
	if ShopData.Instance then
		print_error("[ShopData] Attemp to create a singleton twice !")
	end
	ShopData.Instance = self

	self.shop_config = nil
	-- self.fenqu_config = ListToMap(self:GetAllFenquShopItemCfg(), "item_id")

	self.buy_limit_list = {}
end

function ShopData:__delete()
	ShopData.Instance = nil
end

--获取所有商店item配置
function ShopData:GetAllShopItemCfg()
	return self:GetShopConfig().item
end

function ShopData:GetShopConfig()
	if not self.shop_config then
		self.shop_config = ConfigManager.Instance:GetAutoConfig("shop_auto")
	end
	return self.shop_config
end

function ShopData:GetShopOtherByStr(str)
	if str == nil then
		return
	end

	return ConfigManager.Instance:GetAutoConfig("shop_auto").other[1][str]
end

function ShopData:GetAllFenquShopItemCfg()
	return self:GetShopConfig().fenqu
end

--获取单个商店item配置
function ShopData:GetShopItemCfg(item_id)
	local all_item_cfg = self:GetAllShopItemCfg()
	return all_item_cfg[item_id]
end

function ShopData:GetItemIdListType(shop_type)
	local all_item_cfg = self:GetAllFenquShopItemCfg()
	local item_id_list = {}
	for k,v in pairs(all_item_cfg) do
		if v.shop_type == shop_type then
			item_id_list[#item_id_list + 1] = v.item_id
		end
	end
	
	if shop_type == SHOP_BIND_TYPE.IS_LIMUIT then
		for i = #item_id_list, 1, -1 do
			if self:GetLimitMaxNum(item_id_list[i]) <= 0 then
				table.remove(item_id_list, i)
			end
		end
	end

	return item_id_list
end

--供滚动条使用
function ShopData:GetItemListByTypeAndIndex(shop_type, index)
	local all_fenqu_cfg = self:GetAllFenquShopItemCfg()

	local item_id_list = {}
	for k,v in pairs(all_fenqu_cfg) do
		if v.shop_type == shop_type then
			item_id_list[#item_id_list + 1] = v.item_id
		end
	end

	if shop_type == SHOP_BIND_TYPE.IS_LIMUIT then
		for i = #item_id_list, 1, -1 do
			if self:GetLimitMaxNum(item_id_list[i]) <= 0 then
				table.remove(item_id_list, i)
			end
		end
	end

	local new_id_list = {}
	if index == 1 then
		for i = 1 , ShopData.SHOP_COL_ITEM do
			new_id_list[#new_id_list + 1] = item_id_list[i]
		end
		return new_id_list
	end
	for i = 1 , ShopData.SHOP_COL_ITEM do
		if item_id_list[(index -  1 ) * ShopData.SHOP_COL_ITEM + i] == nil then
			item_id_list[(index -  1 ) * ShopData.SHOP_COL_ITEM + i] = 0
		end
		new_id_list[#new_id_list + 1] = item_id_list[(index -  1 ) * ShopData.SHOP_COL_ITEM + i]
	end
	return new_id_list
end

--获取物品被动消耗类配置
function ShopData:GetItemOtherCfg(item_id)
	return ConfigManager.Instance:GetAutoItemConfig("other_auto")[item_id]
end

--获取物品的购买货币类型
function ShopData:GetConsumeType(shop_type)
	local all_fenqu_cfg = self:GetAllFenquShopItemCfg()
	for k,v in pairs(all_fenqu_cfg) do
		if v.shop_type == shop_type then
			return v.consume_type
		end
	end
end

--检查商城中是否有该物品
function ShopData:CheckIsInShop(item_id)
	local cfg = self:GetAllShopItemCfg()
	return cfg[item_id]
end

--检测是否够钱买商城的物品,优先使用绑定
function ShopData:CheckCanBuyItem(item_id)
	if not self:CheckIsInShop(item_id) then return end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local cfg = self:GetShopItemCfg(item_id)
	if cfg.bind_gold ~= 0 then
		if vo.bind_gold >= cfg.bind_gold then
			return SHOP_BIND_TYPE.BIND
		else
			if vo.gold >= cfg.gold then
				return SHOP_BIND_TYPE.NO_BIND
			end
		end
	else
		if vo.gold >= cfg.gold then
			return SHOP_BIND_TYPE.NO_BIND
		end
	end
	return
end

function ShopData:SetShopBuyLimit(protocol)
	self.buy_limit_list = protocol.buy_limit_list
end

function ShopData:GetShopBuyLimit()
	if self.buy_limit_list ~= nil then
		return self.buy_limit_list
	end
end

function ShopData:GetShopBuyNum(item_id)
	for i,v in ipairs(self.buy_limit_list) do
		if v.item_id == item_id then
			return v.buy_num
		end
	end
	return 0
end

-- 根据id获取绑定商城上线数量
function ShopData:GetLimitMaxNum(item_id)
	local item_data = self:GetShopItemCfg(item_id)
	if item_data then
		return item_data.buy_limit - self:GetShopBuyNum(item_id)
	end
	return 0
end

function ShopData:GetItemCfgById(item_id)
	if item_id == nil then
		return {}
	end

	return ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
end