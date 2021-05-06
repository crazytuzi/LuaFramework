module(..., package.seeall)

--GS2C--

function GS2CNpcStoreInfo(pbdata)
	local shop_id = pbdata.shop_id --商店
	local goodslist = pbdata.goodslist --商品信息
	local refresh_time = pbdata.refresh_time --下次刷新时间戳,没有刷新规则返回0
	local refresh_cost = pbdata.refresh_cost --下次刷新所需货币数量
	local refresh_coin_type = pbdata.refresh_coin_type --下次刷新所需货币类型
	local refresh_count = pbdata.refresh_count --剩余可刷新次数
	local refresh_rule = pbdata.refresh_rule --0-不能刷新,1-CD刷新,2-固定时间刷新,3-CD+固定
	--todo
	if shop_id == define.Store.Page.TravelShop then
		g_TravelCtrl:OpenTravelExchangeView(shop_id, goodslist, refresh_time, refresh_cost, refresh_coin_type, refresh_count, refresh_rule)
	else
		g_NpcShopCtrl:OnReceiveOpenShop(shop_id, goodslist, refresh_time, refresh_cost, refresh_coin_type, refresh_count, refresh_rule)
	end
end

function GS2COpenGold2Coin(pbdata)
	local type = pbdata.type --1水晶to金币,4水晶to体力
	local ratio = pbdata.ratio --兑换比例
	local max_extra = pbdata.max_extra --最大赠送次数
	local remain_extra = pbdata.remain_extra --剩余赠送次数
	--todo
	g_NpcShopCtrl:OnReceiveExchange(type, ratio, max_extra, remain_extra)
end

function GS2CGold2Coin(pbdata)
	local result = pbdata.result --1玩法关闭
	--todo
	if result == 1 then
		g_NpcShopCtrl:OnEvent(define.Store.Event.CloseGold2Coin)
	end
end

function GS2CStoreRefresh(pbdata)
	local shop_id = pbdata.shop_id
	local goodsInfo = pbdata.goodsInfo --商品信息
	--todo
	g_NpcShopCtrl:RefreshItem(shop_id, goodsInfo)
end

function GS2CPayForColorCoinInfo(pbdata)
	local colorcoin_list = pbdata.colorcoin_list
	--todo
	g_NpcShopCtrl:UpdatePayList(colorcoin_list)
end

function GS2CRefreshChargeColorCoin(pbdata)
	local unit = pbdata.unit
	--todo
	g_NpcShopCtrl:UpdatePayInfo(unit)
end


--C2GS--

function C2GSOpenShop(shop_id)
	local t = {
		shop_id = shop_id,
	}
	g_NetCtrl:Send("store", "C2GSOpenShop", t)
end

function C2GSExchangeGold(store_itemid)
	local t = {
		store_itemid = store_itemid,
	}
	g_NetCtrl:Send("store", "C2GSExchangeGold", t)
end

function C2GSExchangeSilver(store_itemid)
	local t = {
		store_itemid = store_itemid,
	}
	g_NetCtrl:Send("store", "C2GSExchangeSilver", t)
end

function C2GSNpcStoreBuy(buy_id, buy_count, buy_price, pos)
	local t = {
		buy_id = buy_id,
		buy_count = buy_count,
		buy_price = buy_price,
		pos = pos,
	}
	g_NetCtrl:Send("store", "C2GSNpcStoreBuy", t)
end

function C2GSOpenGold2Coin(type)
	local t = {
		type = type,
	}
	g_NetCtrl:Send("store", "C2GSOpenGold2Coin", t)
end

function C2GSGold2Coin(val, ratio, type)
	local t = {
		val = val,
		ratio = ratio,
		type = type,
	}
	g_NetCtrl:Send("store", "C2GSGold2Coin", t)
end

function C2GSRefreshShop(shop_id)
	local t = {
		shop_id = shop_id,
	}
	g_NetCtrl:Send("store", "C2GSRefreshShop", t)
end

function C2GSExchangeTrapminePoint(amount)
	local t = {
		amount = amount,
	}
	g_NetCtrl:Send("store", "C2GSExchangeTrapminePoint", t)
end

function C2GSStoreBuyList(buys)
	local t = {
		buys = buys,
	}
	g_NetCtrl:Send("store", "C2GSStoreBuyList", t)
end

function C2GSBuyItemByCoin(coin_type, item_sid, buy_amount)
	local t = {
		coin_type = coin_type,
		item_sid = item_sid,
		buy_amount = buy_amount,
	}
	g_NetCtrl:Send("store", "C2GSBuyItemByCoin", t)
end

