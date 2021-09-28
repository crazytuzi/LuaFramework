------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")


-- order 2,战力or品质  1，价格 负表示倒序
function i3k_sbean.sync_auction(itemType, name, page, order, rank, level, classType, callback, itemID)
	local sync = i3k_sbean.auction_syncitems_req.new()
	sync.classType = classType
	if not classType then
		sync.classType = 0
	end
	sync.itemType = itemType
	sync.page = page
	sync.order = order
	sync.rank = rank
	sync.level = level
	sync.callback = callback
	sync.name = name
	sync.itemID = itemID or 0
	i3k_game_send_str_cmd(sync, "auction_syncitems_res")
end

function i3k_sbean.auction_syncitems_res.handler(bean, res)
	if bean.items then
		g_i3k_ui_mgr:OpenUI(eUIID_Auction)

		if res.callback then
			res.callback(res.itemType)
		end

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Auction, "loadBuyData", bean.items, res.itemType, res.page, res.order, res.rank, res.level, bean.lastPage, res.classType, res.itemID)
	else
		if bean.lastPage < 0 then -- 封禁寄售行
			bean.items = {}
			local seconds = bean.lastPage
			g_i3k_ui_mgr:OpenUI(eUIID_Auction)

			if res.callback then
				res.callback(res.itemType)
			end

			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Auction, "loadBuyData", bean.items, res.itemType, res.page, res.order, res.rank, res.level, bean.lastPage, res.classType, res.itemID)
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1442, math.ceil(-seconds / 3600)))
			return
		end

		g_i3k_ui_mgr:PopupTipMessage("服务器错误")
	end
end


-----------------根据职业同步物品-------------------
function i3k_sbean.sync_classType_equip(itemType, page, order, rank, level, classType, callback)
	local sync = i3k_sbean.auction_syncequips_req.new()
	sync.itemType = itemType
	sync.classType = classType
	sync.order = order
	sync.page = page
	sync.rank = rank
	sync.level = level
	sync.callback = callback
	i3k_game_send_str_cmd(sync, "auction_syncitems_res")
end





-----------------同步自己的寄售商品-------------------
function i3k_sbean.sync_auction_sale()
	local sync = i3k_sbean.auction_syncselfitems_req.new()
	i3k_game_send_str_cmd(sync, "auction_syncselfitems_res")
end

function i3k_sbean.auction_syncselfitems_res.handler(bean, res)
	local bagItems = g_i3k_game_context:GetCanSaleBagInfo()
	if not bean.items or not bean.cellSize or not bean.expandTimes then
		g_i3k_ui_mgr:ShowMessageBox2(string.format("获取资讯失败"))
		return
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Auction, "loadSaleData", bean.items, bagItems, bean.cellSize, bean.expandTimes)
end



---------------上架物品-------------------
function i3k_sbean.putOnItem(itemId, itemCount, price)
	local put = i3k_sbean.auction_putonitems_req.new()
	put.id = itemId
	put.count = itemCount
	put.price = price
	i3k_game_send_str_cmd(put, "auction_putonitems_res")
end

function i3k_sbean.auction_putonitems_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_game_context:UseBagItem(res.id, res.count,AT_PUT_ON_NORMAL_ITEMS)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Auction, "reloadAuctionData")
		g_i3k_ui_mgr:CloseUI(eUIID_SaleProp)

		local eventID = "道具ID"
		DCEvent.onEvent("寄售行寄售", { eventID = tostring(res.id)})
	elseif bean.ok == -4 then
		local cfg = g_i3k_db.i3k_db_get_auction_buy_limit_days()
		local msg = i3k_get_string(15509, cfg.upStore)
		g_i3k_ui_mgr:ShowMessageBox1(msg)
	else
		g_i3k_ui_mgr:PopupTipMessage("服务器请求失败")
	end
end


--------------下架物品--------------------
function i3k_sbean.putOffItem(item)
	local putOff = i3k_sbean.auction_putoffitems_req.new()
	putOff.cid = item.dealId
	putOff.itemID = item.id
	putOff.count = item.count
	i3k_game_send_str_cmd(putOff, "auction_putoffitems_res")
end

function i3k_sbean.auction_putoffitems_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Auction, "reloadAuctionData")
		g_i3k_ui_mgr:CloseUI(eUIID_AuctionPutOff)
		g_i3k_ui_mgr:CloseUI(eUIID_PutOffEquip)

		if res then
			local eventID = "道具ID"
			DCEvent.onEvent("寄售行下架", { eventID = tostring(res.itemID)})
		end
	elseif bean.ok==-2 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Auction, "reloadAuctionData")
		g_i3k_ui_mgr:CloseUI(eUIID_AuctionPutOff)
		g_i3k_ui_mgr:CloseUI(eUIID_PutOffEquip)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(258))
	else
		g_i3k_ui_mgr:PopupTipMessage("服务器请求失败")
	end
end



--------------上架装备----------------------
function i3k_sbean.putOnEquip(equipId, guid, price)
	local put = i3k_sbean.auction_putonequip_req.new()
	put.id = equipId
	put.guid = guid
	put.price = price
	i3k_game_send_str_cmd(put, "auction_putonequip_res")
end

function i3k_sbean.auction_putonequip_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_game_context:DelBagEquip(res.id, res.guid,AT_PUT_ON_EQUIP)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Auction, "reloadAuctionData")
		g_i3k_ui_mgr:CloseUI(eUIID_SaleEquip)

		local eventID = "道具ID"
		DCEvent.onEvent("寄售行寄售", { eventID = tostring(res.id)})
	elseif bean.ok == -4 then
		local cfg = g_i3k_db.i3k_db_get_auction_buy_limit_days()
		local msg = i3k_get_string(15509, cfg.upStore)
		g_i3k_ui_mgr:ShowMessageBox1(msg)
	else
		g_i3k_ui_mgr:PopupTipMessage("服务器请求失败")
	end
end



------------拓展摊位--------------------
function i3k_sbean.auction_expand(times, needPrice)
	local expand = i3k_sbean.auction_expand_req.new()
	expand.times = times
	expand.needPrice = needPrice
	i3k_game_send_str_cmd(expand, "auction_expand_res")
end

function i3k_sbean.auction_expand_res.handler(bean, res)
	if bean.ok==1 then
		local costTable = i3k_db_common.aboutAuction.price
		local needPrice = res.needPrice
		g_i3k_game_context:UseMoney(needPrice, false,AT_EXPAND_AUCTION_CELLS)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Auction, "reloadAuctionData")
	else
		g_i3k_ui_mgr:PopupTipMessage("服务器错误")
	end
end




------------交易记录------------------
function i3k_sbean.auction_log()
	local req = i3k_sbean.auction_tradelog_req.new()
	i3k_game_send_str_cmd(req, "auction_tradelog_res")
end

function i3k_sbean.auction_tradelog_res.handler(bean, res)
	local logs = bean.logs
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Auction, "loadRecordData", logs)
end




------------购买商品----------------
function i3k_sbean.buyItem(dealId, salerId, item, itemType, callback)
	local buy = i3k_sbean.auction_buyitems_req.new()
	buy.cid = dealId
	buy.sellerID = salerId
	buy.items = item
	buy.itemType = itemType
	--buy.sellerServerID = serverId
	buy.callback = callback
	i3k_game_send_str_cmd(buy, "auction_buyitems_res")
end

function i3k_sbean.auction_buyitems_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_game_context:UseDiamond(res.items.price, true,AT_BUY_AUCTION_ITEMS)
		if res.callback then
			res.callback()
		end
		local itemName = g_i3k_db.i3k_db_get_common_item_name(res.items.id)
		if res.itemType>10 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(742, string.format("%s*%d", itemName, res.items.count)))
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(742, itemName))
		end
		local eventID = "道具ID"
		DCEvent.onEvent("寄售行购买", { eventID = tostring(res.items.id)})
	elseif bean.ok==-1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(243))
	elseif bean.ok == -4 then
		local cfg = g_i3k_db.i3k_db_get_auction_buy_limit_days()
		local msg = i3k_get_string(15510, cfg.buy)
		g_i3k_ui_mgr:ShowMessageBox1(msg)
	else
		g_i3k_ui_mgr:PopupTipMessage("服务器错误")
	end
end



--查询同类物品价格
function i3k_sbean.query_advise_price(item)
	local query = i3k_sbean.auction_itemprices_req.new()
	query.itemID = item.id
	query.item = item
	i3k_game_send_str_cmd(query, "auction_itemprices_res")
end

function i3k_sbean.auction_itemprices_res.handler(bean, res)
	local logs = bean.items
	if not logs then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(631))
		return
	end
	local item = res.item
	if item.guid then
		local equip = g_i3k_game_context:GetBagEquip(item.id, item.guid)
		g_i3k_ui_mgr:OpenUI(eUIID_SaleEquip)
		g_i3k_ui_mgr:RefreshUI(eUIID_SaleEquip, item, equip, logs)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_SaleProp)
		g_i3k_ui_mgr:RefreshUI(eUIID_SaleProp, item, logs)
	end
end



-------------拍卖行（非寄售行）-----------------
function i3k_sbean.syncBid(isRefresh)
	local data = i3k_sbean.black_market_sync_req.new()
	data.isRefresh = isRefresh and 1 or 0
	i3k_game_send_str_cmd(data, "black_market_sync_res")
end

function i3k_sbean.black_market_sync_res.handler(res, req)
	if res.goods then
		g_i3k_ui_mgr:OpenUI(eUIID_Bid)
		g_i3k_ui_mgr:RefreshUI(eUIID_Bid, res.goods, res.unAddGroupIds)
		if req.isRefresh == 1 then
			g_i3k_ui_mgr:PopupTipMessage("刷新成功")
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bid, "setHistory", res.history)
	end
end

function i3k_sbean.bidForPrice(gid, price, isQuickBuy, displayName, info)
	local data = i3k_sbean.black_market_price_req.new()
	data.gid = gid
	data.price = price
	data.displayName = displayName and 1 or 0
	data.isQuickBuy = isQuickBuy and 1 or 0
	data.info = info
	i3k_game_send_str_cmd(data, "black_market_price_res")
end
function i3k_sbean.black_market_price_res.handler(res, req)
	if res.ok > 0 then
		if req.info then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bid, "bidSuccessCallback", req.info)
		end
		if req.isQuickBuy == 1 then
			g_i3k_ui_mgr:CloseUI(eUIID_BidTips)
			g_i3k_ui_mgr:PopupTipMessage("一口价成功")
		else
			g_i3k_ui_mgr:PopupTipMessage("竞价成功")
		end
		g_i3k_game_context:UseCommonItem(req.info.needCoinID, req.price, AT_BLACK_MARKET_PRICE)
		g_i3k_game_context:setBidTime(req.info.gid)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bid, "setBidPriceTimeLimitGray")
	else
		g_i3k_ui_mgr:CloseUI(eUIID_BidTips)
		if res.ok == - 1 then
			g_i3k_ui_mgr:PopupTipMessage("当前价格已变化，请点击刷新按钮刷新")
		elseif res.ok == -2 then
			g_i3k_ui_mgr:PopupTipMessage("当前出价已是最高价了，无法再竞价")
		elseif res.ok == -3 then
			g_i3k_ui_mgr:PopupTipMessage("当前出价已是最高价了，无法再竞价")
		end
	end
end

--通知客户端寄售行操作违规
function i3k_sbean.auction_invalid_times.handler(bean)
	if bean.times == 1 then
		g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(1441))
	end
end
