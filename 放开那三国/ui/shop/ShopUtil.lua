-- Filename：	ShopUtil.lua
-- Author：		Cheng Liang
-- Date：		2013-8-23
-- Purpose：		Util

module ("ShopUtil", package.seeall)

--require "script/model/DataCache"

-- 获取本地的数据
function getAllShopInfo()

	require "db/DB_Goods"
	
	local tData = {}
	for k, v in pairs(DB_Goods.Goods) do
		table.insert(tData, v)
	end
	local allGoods = {}
	for k,v in pairs(tData) do
		table.insert(allGoods, DB_Goods.getDataById(v[1]))
	end
	tData = nil


	local function keySort ( goods_1, goods_2 )
	   	return tonumber(goods_1.type) > tonumber(goods_2.type)
	end
	table.sort( allGoods, keySort )

	return allGoods
end

-- 获取某个物品的当前购买次数
function getBuyNumBy( goods_id )
	goods_id = tonumber(goods_id)
	local cacheInfo = DataCache.getShopCache()
	local number = 0

	if(not table.isEmpty(cacheInfo.goods)) then
		for k_id, v in pairs(cacheInfo.goods) do
			if(tonumber(k_id) == goods_id) then
				number = tonumber(v.num)
				break
			end
		end
	end
	return number
end

-- vip购买某个物品增加的次数
function getAddBuyTimeBy( vip_level, i_tid )
	i_tid = tonumber(i_tid)
	require "db/DB_Vip"
    local vipArr = DB_Vip.getArrDataByField("level", UserModel.getVipLevel())
    local vipInfo = vipArr[1]


	local addTimes = 0

	local item_str = vipInfo.day_buy_goods
	item_str = string.gsub(item_str, " ", "")

	local item_arr = string.split(item_str, ",")

	for k,item_u in pairs(item_arr) do
		local item_info = string.split(item_u, "|")
		
		if(tonumber(item_info[1]) == i_tid) then
			addTimes = tonumber(item_info[2])
			break
		end
	end

	print("i_tid==", i_tid, "  number==", addTimes)
	return addTimes
end

-- 某次购买银币的价格
function getSiliverPriceBy( buyTimes )
	require "db/DB_Goods"
	local goodsData = DB_Goods.getDataById(11)

	local per_arr = string.split( string.gsub(goodsData.cost_gold_add_siliver, " ", ""), "|")
	local c_price = (buyTimes -1) * tonumber(per_arr[1]) + goodsData.current_price
	if(c_price  > tonumber(per_arr[2])) then
		c_price = tonumber(per_arr[2])
	end

	return c_price
end

-- 从某次开始购买多少个
function getBuySiliverTotalPriceBy( s_times, d_length )
	local totalPrice = 0
	for i=1,d_length do
		totalPrice = totalPrice + getSiliverPriceBy(s_times+i-1)
	end

	return totalPrice
end

-- 某次购买将魂的价格
function getSoulPriceBy( buyTimes )
	require "db/DB_Goods"
	local goodsData = DB_Goods.getDataById(12)
	
	local per_arr = string.split( string.gsub(goodsData.cost_gold_add_siliver, " ", ""), "|")
	local c_price = (buyTimes -1) * tonumber(per_arr[1]) + goodsData.current_price
	if(c_price  > tonumber(per_arr[2])) then
		c_price = tonumber(per_arr[2])
	end

	return c_price
end

-- 从某次开始购买多少个
function getBuySoulTotalPriceBy( s_times, d_length )
	local totalPrice = 0
	for i=1,d_length do
		totalPrice = totalPrice + getSoulPriceBy(s_times+i-1)
	end

	return totalPrice
end

-- 某次购买某物品所需金币
function getNeedGoldByGoodsAndTimes(goods_id, buy_times)
	require "db/DB_Goods"
	local goodsData = DB_Goods.getDataById(goods_id)

	local c_price = goodsData.current_price

	if(goodsData.cost_gold_add_siliver)then
		local per_arr = string.split( string.gsub(goodsData.cost_gold_add_siliver, " ", ""), "|")
		c_price = (buy_times -1) * tonumber(per_arr[1]) + goodsData.current_price
		if(c_price  > tonumber(per_arr[2])) then
			c_price = tonumber(per_arr[2])
		end
	end

	return c_price
end

-- 某次购买某商品多个
function getNeedGoldByMoreGoods( goods_id, s_times, d_length )
	d_length = tonumber(d_length)
	local totalPrice = 0
	for i=1,d_length do
		totalPrice = totalPrice + getNeedGoldByGoodsAndTimes(goods_id, s_times+i-1)
	end

	return totalPrice
end
--良将或神将的免费招将时间 可能会经过聚义厅功能开启后有所改变 在这里处理一下
--p_table是_shopCache p_type是要改变的类型 1是良将 2是神将
function dealLoyal(p_table,p_type )
	if(table.isEmpty(p_table) )then
		return
	end
	local pType = tonumber(p_type)
	require "script/ui/star/loyalty/LoyaltyData"
    require "db/DB_Hall_loyalty"
	if(pType == 1)then
		if(p_table.silver_recruit_time == nil)then
			return
		end
    	local silverArray = DB_Hall_loyalty.getArrDataByField("type",4)
    	print("silverArray")
    	print_t(silverArray)
    	if(not table.isEmpty(silverArray))then
    		for k,v in pairs(silverArray)do 
				if LoyaltyData.isFunOpen(4,v.id) then
					--良将招募的时间减少
					p_table.silver_recruit_time = tonumber(p_table.silver_recruit_time) - tonumber(v.num)*60

				end
			end
		end

	elseif(pType == 2)then
		if(p_table.gold_recruit_time == nil)then
			return
		end
		local goldArray = DB_Hall_loyalty.getArrDataByField("type",5)
		print("goldArray")
    	print_t(goldArray)
    	if(not table.isEmpty(goldArray))then
    		for k,v in pairs(goldArray)do 
				if LoyaltyData.isFunOpen(5,v.id) then
					--神将招募的时间减少
					p_table.gold_recruit_time = tonumber(p_table.gold_recruit_time) - tonumber(v.num)*60

				end
			end
		end
	end
end


