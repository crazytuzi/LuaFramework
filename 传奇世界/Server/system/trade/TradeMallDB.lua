--TradeMallDB.lua
--/*-----------------------------------------------------------------
 --* Module:  TradeMallDB.lua
 --* Author:  HE Ningxu
 --* Modified: 2014年5月23日
 --* Purpose: Implementation of the Shop Data
 -------------------------------------------------------------------*/

require ("system.trade.TradeConstants")

MallItemTable = {}
VIPshopNum = {}
JFShopLimit = {}				--20150919
SpeMallItem = {}				--存储特殊的商城道具	20151027
MallLimit = {}					--20151030 商品限购 { [购买ID]={全服限购=，个人限购=} }
MallItemTable2 = {}				--20151112 商品表	{ [商城类型]={ [购买ID]={整条记录} } }
TradeLimit = {} 				--交易限制信息

function loadVIPDB()
	if package.loaded["data.VIPShopDB"] then
		package.loaded["data.VIPShopDB"] = nil
	end
	VIPshopNum = {}
	
	local itemDatas = require "data.VIPShopDB"
	
	for _, record in pairs(itemDatas or {}) do
		
		if VIPshopNum[record.q_id] == nil then
			VIPshopNum[record.q_id] = {}
		end
		VIPshopNum[record.q_id][record.vip] = tonumber(record.sl or 0)
	end
end

function loadShopDB()
	if package.loaded["data.MallDB"] then
		package.loaded["data.MallDB"] = nil
	end
	MallItemTable = {}

	local itemDatas = require "data.MallDB"
	
	for _, record in pairs(itemDatas or {}) do
		
		local item = {}
	
		item.id = record.q_id or 0
		item.shop_type = record.q_shop_type or -1
		item.sell = record.q_sell or 0
		item.losttime = record.q_losttime or 0
		item.duration = record.q_duration or 0
		item.buy_bind = (record.q_buy_bind == true) or false
		
		item.money_type = record.q_money_type or 0
		item.money = tonumber(record.q_coin) or 0
		item.show_money = tonumber(record.q_show_coin) or 0
		item.ingot = tonumber(record.q_gold) or 0
		item.show_ingot = tonumber(record.q_show_gold) or 0
		item.bind_money = tonumber(record.q_coupon) or 0
		item.show_bind_money = tonumber(record.q_show_coupon) or 0
		item.bind_ingot = tonumber(record.q_bindgold) or 0
		item.show_bind_ingot = tonumber(record.q_show_bindgold) or 0
		
		item.rack = record.q_rack or "A"
		item.unrack = record.q_unrack or 0
		
		item.show_level = record.q_show_level or 0
		item.job = record.q_job or 0
		item.sale_rate = record.q_sale_rate or 0
		item.discount_time = record.q_discount_time or 0
		item.openserver_discount = record.q_openserver_discount or 0
		item.openserver_rack = record.q_openserver_rack or 0
		item.service_area = record.q_service_area or 0

		item.shop_limit = tonumber(record.q_shop_limit) or -1
		item.all_limit = tonumber(record.q_all_limit) or -1
		item.faction_money = tonumber(record.xhbg) or 0
		item.faction_limit = tonumber(record.djzs) or -1
		
		item.honour = tonumber(record.q_honour) or 0
		item.meritorious = tonumber(record.q_meritorious) or 0
		item.jf = tonumber(record.jf) or 0
		item.special = tonumber(record.q_special) or 0 						--元宝商城加坐骑
		item.label = tonumber(record.q_labels) or 0 						--商品标签
		
		item.starOnSellTick = 0
		item.endOnSellTick = 0
		local starOnSell = tostring(record.q_startTime or "")
		if starOnSell and #starOnSell>16 then		
			local Year = string.sub(starOnSell , 1, 4)
		    local Month = string.sub(starOnSell , 6, 7)
		    local Day = string.sub(starOnSell , 9, 10)
		    local Hour = string.sub(starOnSell , 12, 13)
		    local Min = string.sub(starOnSell , 15, 16)
		    local Second = string.sub(starOnSell , 18, 19)
		    local starOnSellTick = os.time({year=Year, month=Month, day=Day, hour=Hour,min=Min,sec=Second})
			if starOnSellTick>0 and tonumber(record.q_endTime)>0 then
				item.starOnSellTick = starOnSellTick
				item.endOnSellTick = starOnSellTick + tonumber(record.q_endTime)
			end
		end

		if item.special>0 then
			SpeMallItem[item.id] = item
		end
		
		if item.all_limit>0 or item.shop_limit>0 then
			if not MallLimit[item.id] then
				MallLimit[item.id] = {}
			end
			MallLimit[item.id] = {itemID=item.sell,moneyType=item.money_type,shopType=item.shop_type,allLimit=item.all_limit,roleLimit=item.shop_limit}
		end

		MallItemTable[item.id] = item

		if not MallItemTable2[item.shop_type] then
			MallItemTable2[item.shop_type] = {}
		end
		MallItemTable2[item.shop_type][item.sell] = item
	end

	updateShop()
end

ShopTable = {}
ShopCount = {}
PriceTable = {}
VIPshopTable = {}

function updateShop(t)
	--商店表
	ShopTable = {}
	ShopCount = {}

	for i,v in pairs(MallItemTable) do
		
		--商店分类
		if nil == ShopTable[v.shop_type] then
			ShopTable[v.shop_type] = {}
			ShopCount[v.shop_type] = 0
		end
		
		if VIP_SHOP == v.shop_type then
			VIPshopTable[i] = v
		end
		
		if onSall(v.rack, t) == true then			
			ShopTable[v.shop_type][i] = v
			if PriceTable[v.shop_type] == nil then
				PriceTable[v.shop_type] = {}
			end
			if v.money_type == 1 then
				PriceTable[v.shop_type][v.sell] = {price = v.money, show = v.show_money}
			end
			if v.money_type == 2 then
				PriceTable[v.shop_type][v.sell] = {price = v.ingot, show = v.show_ingot}
			end
			if v.money_type == 3 then
				PriceTable[v.shop_type][v.sell] = {price = v.bind_money, show = v.show_bind_money}
			end
			if v.money_type == 4 then
				PriceTable[v.shop_type][v.sell] = {price = v.bind_ingot, show = v.show_bind_ingot}
			end
			if v.money_type == 5 then
				PriceTable[v.shop_type][v.sell] = {price = v.faction_money, show = v.faction_money}
			end
			if v.money_type == 6 then
				PriceTable[v.shop_type][v.sell] = {price = v.honour, show = v.honour}
			end
			if v.money_type == 7 then
				PriceTable[v.shop_type][v.sell] = {price = v.jf, show = v.jf}				
			end
			if v.money_type == 8 then
				PriceTable[v.shop_type][v.sell] = {price = v.meritorious, show = v.meritorious}
			end
			
			ShopCount[v.shop_type] = ShopCount[v.shop_type] + 1
		end
	end
end

function loadTradeLimit()
	if package.loaded["data.TransactionLimit"] then
		package.loaded["data.TransactionLimit"] = nil
	end

	TradeLimit = {}
	local limitDatas = require "data.TransactionLimit"
	for i,v in pairs(limitDatas or {}) do
		local itemID = tonumber(v.q_ItemId or 0)
		local isLimit = tonumber(v.q_LimitFace or 0)
		local limitMax = tonumber(v.q_MaxNum1 or 0)
		if isLimit > 0 or limitMax > 0 then
			local datas = {}
			datas.itemID = itemID
			datas.limitTrade = isLimit
			datas.limitNum = limitMax
			TradeLimit[itemID] = datas
		end
	end
end