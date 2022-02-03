-- --------------------------------------------------------------------
-- 市场
--
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-06-04
-- --------------------------------------------------------------------
MarketModel = MarketModel or BaseClass()

function MarketModel:__init(ctrl)
    self.ctrl = ctrl
    self.gold_list = {}
    self.canSellList = {}
    self:config()
end

--金币市场数据
function MarketModel:setGoldShopList( data )
	self.gold_list[data.catalg] = data.goods
end

function MarketModel:getGoldShopList( catalg )
	
end

--金币市场限购数据
function MarketModel:setLimitList( list )
	self.limit_list = list
end

--返回某类型金币市场数据
function MarketModel:getShowGoldShowList( catalg )
	local config = {}
	if catalg == 1 then
		config = Config.MarketGoldData.data_skill_shop_list
	elseif catalg == 2 then
		config = Config.MarketGoldData.data_form_shop_list
	elseif catalg == 3 then
		config = Config.MarketGoldData.data_break_shop_list
	elseif catalg == 4 then
		config = Config.MarketGoldData.data_other_shop_list
	elseif catalg == 0 then --全部
		for k,v in pairs(Config.MarketGoldData.data_other_shop_list) do
			table.insert(config,v)
		end
		for k,v in pairs(Config.MarketGoldData.data_break_shop_list) do
			table.insert(config,v)
		end
		for k,v in pairs(Config.MarketGoldData.data_form_shop_list) do
			table.insert(config,v)
		end
		for k,v in pairs(Config.MarketGoldData.data_skill_shop_list) do
			table.insert(config,v)
		end
	end
	for k,v in pairs(self.gold_list[catalg]) do
		v.has_buy = 0
		--已购买数量
		if self.limit_list and next(self.limit_list)~= nil then
			for a,j in pairs(self.limit_list) do
				if j.item_id == v.base_id then
					v.has_buy = j.count
				end
			end
		end
		--限购数量
		for c,d in pairs(config) do
			if d.base_id == v.base_id then
				v.limit_num = d.limit_num
				v.limit_type = d.limit_type
				v.sort = d.sort
			end
		end
	end
	--Debug.info(self.gold_list[catalg])
	table.sort( self.gold_list[catalg], SortTools.KeyLowerSorter("sort") )

	return self.gold_list[catalg]
end

--获取金币市场可出售物品 
function MarketModel:getCanSellList( catalg )
	local temp_list = {}
	self.canSellList[catalg] = {}
	if catalg == 1 then
		for k,v in pairs(Config.MarketGoldData.data_skill_shop_list) do
			temp_list[v.base_id] = v
		end
	elseif catalg == 2 then
		for k,v in pairs(Config.MarketGoldData.data_form_shop_list) do
			temp_list[v.base_id] = v
		end
	elseif catalg == 3 then
		for k,v in pairs(Config.MarketGoldData.data_break_shop_list) do
			temp_list[v.base_id] = v
		end
	elseif catalg == 4 then
		for k,v in pairs(Config.MarketGoldData.data_other_shop_list) do
			temp_list[v.base_id] = v
		end
		--隐藏出售的放在其他类型
		for k,v in pairs(Config.MarketGoldData.data_hide_sell_list) do
			temp_list[k] = v
			temp_list[k].base_id = k
			temp_list[k].catalg = 4
		end
	elseif catalg == 0 then --全部类型
		for k,v in pairs(Config.MarketGoldData.data_skill_shop_list) do
			temp_list[v.base_id] = v
		end
		for k,v in pairs(Config.MarketGoldData.data_form_shop_list) do
			temp_list[v.base_id] = v
		end
		for k,v in pairs(Config.MarketGoldData.data_break_shop_list) do
			temp_list[v.base_id] = v
		end
		for k,v in pairs(Config.MarketGoldData.data_other_shop_list) do
			temp_list[v.base_id] = v
		end
		--隐藏出售的放在其他类型
		for k,v in pairs(Config.MarketGoldData.data_hide_sell_list) do
			temp_list[k] = v
			temp_list[k].base_id = k
			temp_list[k].catalg = 4
		end

	end

	--找出在背包里的数量
	for k,v in pairs(temp_list) do
		local model = BackpackController:getInstance():getModel()
		local num = model:getBackPackItemNumByBid(v.base_id)
		v.num = num 
		v.id = model:getBackPackItemIDByBid(v.base_id)
		--v.price = self:getPrice(v.base_id) or 0
		if num >0 then
			table.insert(self.canSellList[catalg],v)
		end
	end
	--Debug.info(self.canSellList[catalg])

	return self.canSellList[catalg] or {}
end

--获取金币市场可出售物品 含价格
function MarketModel:getCanSellListII( catalg )
	if self.canSellList[catalg] and next(self.canSellList[catalg])~=nil then
		for k,v in pairs(self.canSellList[catalg]) do
			v.price = math.floor(self:getPrice(v.base_id))
		end
	end
	return self.canSellList[catalg] or {}
end

--获取金币出售价格
function MarketModel:getPrice( base_id )
	if Config.MarketGoldData.data_hide_sell_list[base_id] then --隐藏出售物品 固定价格读表
		return Config.MarketGoldData.data_hide_sell_list[base_id].price
	elseif Config.MarketGoldData.data_change_sell_list[base_id] then --转换出售物品
		local bid = Config.MarketGoldData.data_change_sell_list[base_id].exchange_id
		--市价
		local price = self:getGoldMarketPrice(bid)
		if Config.MarketGoldData.data_stable_sell_list[bid] then --有固定折扣 
			--市价*固定折扣
			local config1 = Config.MarketGoldData.data_stable_sell_list[bid] 
			return math.floor(price*(config1.discount/1000))
		else--市价*默认折扣
			return math.floor(price*Config.MarketGoldData.data_market_gold_cost.item_sale.val)
		end

	elseif Config.MarketGoldData.data_stable_sell_list[base_id] then --有固定折扣
		local config1 = Config.MarketGoldData.data_stable_sell_list[base_id] 
		--市价*固定折扣
		local price = self:getGoldMarketPrice(base_id)
		return math.floor(price*(config1.discount/1000))
	else--没有固定折扣 市价*默认折扣
		local price = self:getGoldMarketPrice(base_id)
		return math.floor(price*Config.MarketGoldData.data_market_gold_cost.item_sale.val)
	end
end

--获取金币市场的价格
function MarketModel:getGoldMarketPrice( base_id )
	local list = self.ctrl:getPriceList()
	for k, v in pairs(list) do
		if v.base_id == base_id and v.source == 2 then
			return v.price
		end
	end
end

--获取金币市场某个数据 初始
function MarketModel:getData( base_id,catalg )
	if catalg == 1 then
		for k,v in pairs(Config.MarketGoldData.data_skill_shop_list) do
			if base_id == v.base_id then
				return v
			end
		end
	elseif catalg == 2 then
		for k,v in pairs(Config.MarketGoldData.data_form_shop_list) do
			if base_id == v.base_id then
				return v
			end
		end
	elseif catalg == 3 then
		for k,v in pairs(Config.MarketGoldData.data_break_shop_list) do
			if base_id == v.base_id then
				return v
			end
		end
	elseif catalg == 4 then
		for k,v in pairs(Config.MarketGoldData.data_other_shop_list) do
			if base_id == v.base_id then
				return v
			end
		end
	end
end


--获取银币市场摊位数据
function MarketModel:setSliverShop( data )
	self.sliver_shop= {}
	local temp_list = {}
	self.free_list = {}
	if data.free_ids and next(data.free_ids)~=nil then
		for k,v in pairs(data.free_ids) do
			temp_list[v.cell_id] = {cell_id=v.cell_id}
			temp_list[v.cell_id].is_free = 0 --都是空闲摊位
			temp_list[v.cell_id].is_lock = false --没上锁
			-- self.free_list[v.cell_id] = v.cell_id
			table.insert(self.free_list,{cell_id=v.cell_id})
		end
	end

	if data.cells and next(data.cells)~=nil then
		for k,v in pairs(data.cells) do
			local vo = {}--temp_list[v.cell_id]
			vo.cell_id = v.cell_id
			vo.is_free = 1--不是空闲摊位
			vo.is_lock = false --没上锁
			vo.item_base_id = v.item_base_id
			vo.num = v.num
			vo.price = v.price
			vo.expiry = v.expiry
			vo.status = v.status --摊位状态，未出售：0；已出售：1；废弃物品：2 可提现：5 超时：6
			vo.item_attrs = v.item_attrs
			temp_list[v.cell_id] = vo
		end
	end

	--加多一个锁的摊位
	local len = #temp_list
	if len < Config.MarketSilverData.data_market_sliver_cost.silvermarket_boothnum.val then
		temp_list[len+1] = {cell_id = len+1,is_lock=true}
	end

	self.sliver_shop = temp_list

end


function MarketModel:getSliverShop(  )
	return self.sliver_shop or {}
end

--返回当前空闲的摊位
function MarketModel:getFreeList(  )
	return self.free_list or {}
end

--获取银币市场可摆摊商品
function MarketModel:getSliverGroundingItems(  )
	local target = {}
	local list = {}
	list = deepCopy(Config.MarketSilverData.data_antique_list)
	--找出背包中的数量
	for k,v in pairs(list) do
		local model = BackpackController:getInstance():getModel()
		local num = model:getBackPackItemNumByBid(v.base_id)
		v.num = num 
		v.id = model:getBackPackItemIDByBid(v.base_id)
		if num >0 then
			table.insert(target,v)
		end
	end
	table.sort(list, SortTools.KeyLowerSorter("base_id"))

	return target
end


function MarketModel:config()
end

function MarketModel:__delete()
end