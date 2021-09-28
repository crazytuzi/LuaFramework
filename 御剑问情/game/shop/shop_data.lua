ShopData = ShopData or BaseClass()

function ShopData:__init()
	if ShopData.Instance then
		print_error("[ShopData] Attemp to create a singleton twice !")
	end
	ShopData.Instance = self
	self.flushtime = 0
	self.flag = 0
	self.mysterious_cfg = ConfigManager.Instance:GetAutoConfig("mysterious_shop_in_mall_auto")
	self.mysterious_item_list_cfg = ListToMap(self.mysterious_cfg.mysterious_shop_item, "seq")
	self.mysterious_other_cfg = self.mysterious_cfg.other
	self.jifen_item_list_cfg = ExchangeData.Instance:GetItemListByConverType(8)

	RemindManager.Instance:Register(RemindName.ShenmiShop, BindTool.Bind(self.GetShopShenMiRemind, self))
end

function ShopData:__delete()
	self.info = nil
	ShopData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.ShenmiShop)
end

SHOP_BIND_TYPE =
{
	BIND = 1,
	NO_BIND = 2,
}
SHOP_COL_ITEM = 2

--获取所有商店item配置
function ShopData:GetAllShopItemCfg()
	return ConfigManager.Instance:GetAutoConfig("shop_auto").item
end

function ShopData:GetAllFenquShopItemCfg()
	return ConfigManager.Instance:GetAutoConfig("shop_auto").fenqu
end

--获取单个商店item配置
function ShopData:GetShopItemCfg(item_id)
	item_id = item_id or 0

	return self:GetAllShopItemCfg()[item_id]
end

function ShopData:GetItemIdListType(shop_type)
	local all_item_cfg = self:GetAllFenquShopItemCfg()
	local item_id_list = {}
	for k,v in pairs(all_item_cfg) do
		if v.shop_type == shop_type then
			item_id_list[#item_id_list + 1] = v.item_id
		end
	end
	return item_id_list
end

--供滚动条使用
function ShopData:GetItemListByTypeAndIndex(shop_type,index)
	local all_fenqu_cfg = self:GetAllFenquShopItemCfg()
	local item_id_list = {}
	for k,v in pairs(all_fenqu_cfg) do
		if v.shop_type == shop_type then
			item_id_list[#item_id_list + 1] = v.item_id
		end
	end
	local new_id_list = {}
	if index == 1 then
		for i = 1 , SHOP_COL_ITEM do
			new_id_list[#new_id_list + 1] = item_id_list[i]
		end
		return new_id_list
	end
	for i = 1 , SHOP_COL_ITEM do
		if item_id_list[(index -  1 ) * SHOP_COL_ITEM + i] == nil then
			item_id_list[(index -  1 ) * SHOP_COL_ITEM + i] = 0
		end
		new_id_list[#new_id_list + 1] = item_id_list[(index -  1 ) * SHOP_COL_ITEM + i]
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
	item_id = item_id or 0
	
	if self:GetAllShopItemCfg()[item_id] then
		return true
	end

	return false
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

--检测是否够钱买商城的物品,优先使用绑定
function ShopData:CheckCanBuyItemByNum(item_id, num)
	if not self:CheckIsInShop(item_id) then return false end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local cfg = self:GetShopItemCfg(item_id)
	if cfg.bind_gold ~= 0 then
		if vo.bind_gold >= cfg.bind_gold * num then
			return true
		else
			if vo.gold >= cfg.gold * num then
				return true
			end
		end
	else
		if vo.gold >= cfg.gold * num then
			return true
		end
	end
	return false
end

function ShopData:SetShenMiShop(protocol)
    self.info = protocol
end

function ShopData:GetShenMiShop()
    return self.info
end

function ShopData:IsMyteriousIsBuyed(cell_index)
	local t = self.info.seq_list[cell_index]
	if nil == t then
		return false
	end

	return 1 == t.state
end

function ShopData:GetMysteriousShopItemCfg(cell_index)
	local t = self.info.seq_list[cell_index]
	if nil == t then
		return nil
	end

	return self.mysterious_item_list_cfg[t.seq]
end

function ShopData:GetJifenItemListCfg()
	return self.jifen_item_list_cfg
end

function ShopData:GetJifenItemCfg(index)
	return self.jifen_item_list_cfg[index]
end

function ShopData:GetShopShenMiRemind()
	if self.flushtime ~= self.info.next_shop_item_refresh_time then
		self.flag = 1
		self.flushtime = self.info.next_shop_item_refresh_time
	else
		self.flag = 0
	end
	return self.flag
end

function ShopData:GetShopShenMiFlag()
 	return self.flag
end

function ShopData:GetFlushPrice()
	return self.mysterious_other_cfg
end