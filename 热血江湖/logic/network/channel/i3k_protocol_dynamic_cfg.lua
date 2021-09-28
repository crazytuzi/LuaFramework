------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

---------------------------------VIP商城----------------------------------------------
-- 商城同步
--Packet:mall_sync_res
function i3k_sbean.mall_sync(curPoint, showType, itemId, callback)
	local data = i3k_sbean.mall_sync_req.new()
	data.curPoint = curPoint
	if showType then
		data.showType = showType
	end
	if itemId then
		data.itemId = itemId--需要购买商品的Id
	end
	data.callback = callback
	i3k_game_send_str_cmd(data, i3k_sbean.mall_sync_res.getName())
end

function i3k_sbean.mall_sync_res.handler(bean, res)
	local info = bean.info
	if info and info.log and info.mall then
		local curtime = i3k_game_get_time()
		if curtime < info.mall.time.endTime and curtime > info.mall.time.startTime then
			g_i3k_ui_mgr:OpenUI(eUIID_VipStore)
			g_i3k_ui_mgr:RefreshUI(eUIID_VipStore,info,res.curPoint, res.showType, res.itemId)
			if res.callback then
				res.callback(res.itemId)
			end
			DCEvent.onEvent("商城查看")
		else
			g_i3k_ui_mgr:PopupTipMessage("商城尚未开放或时间出错")
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("商城资料未配置")
	end
end


local PROTOCOL_OP_CONF_CONFIG_CHANGED = -1; --商店刷新
local PROTOCOL_OP_CONF_MALL_GOODS_RESTRICTION = -2; --限购结束
local PROTOCOL_OP_CONF_MALL_GOODS_DISCOUNT = -3; --打折结束

-- 商城购买
--Packet:mall_buy_res
function i3k_sbean.mall_buy(effectiveTime,id,gid,count,currencyType,price,itemname,finalcount, iid)
	local mall_buy = i3k_sbean.mall_buy_req.new()
	mall_buy.effectiveTime = effectiveTime
	mall_buy.id = id
	mall_buy.gid = gid
	mall_buy.count = count
	mall_buy.mallType = currencyType
	mall_buy.price = math.modf(price)
	mall_buy.itemname = itemname
	mall_buy.finalcount = finalcount
	if not g_i3k_db.i3k_db_prop_gender_qualify(iid) then
		local callfunction = function(ok)
			if ok then
				i3k_game_send_str_cmd(mall_buy, i3k_sbean.mall_buy_res.getName())
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(50068), callfunction)
		return
	end
	i3k_game_send_str_cmd(mall_buy, i3k_sbean.mall_buy_res.getName())
end

function i3k_sbean.mall_buy_res.handler(bean, res)
	local flag = bean.ok
	if flag > 0 then
		local currencyType = res.mallType
		local price = res.price
		local id = res.gid
		local itemname = res.itemname
		local count = res.count
		local finalcount = res.finalcount
		if currencyType == -g_BASE_ITEM_DIAMOND then
			g_i3k_game_context:UseDiamond(bean.ok,true,AT_BUY_MALL_GOODS)--(price,true)
		elseif currencyType == g_BASE_ITEM_DIAMOND then
			g_i3k_game_context:UseDiamond(bean.ok,false,AT_BUY_MALL_GOODS)--(price,false)
		elseif currencyType == g_BASE_ITEM_DIVIDEND then  --红利
			g_i3k_game_context:UseDividend(bean.ok, AT_BUY_MALL_GOODS)
		elseif currencyType == g_BASE_ITEM_DRAGON_COIN then
			g_i3k_game_context:UseDragonCoin(bean.ok, AT_BUY_MALL_GOODS)
		end
		if finalcount > 1 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(189,itemname.."*"..finalcount))
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(189,itemname))
		end

		DCItem.buy(id,g_i3k_db.i3k_db_get_common_item_is_free_type(id),count, bean.ok, currencyType, AT_BUY_MALL_GOODS)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_VipStore, "addLog",currencyType,id,count)
	elseif flag == PROTOCOL_OP_CONF_CONFIG_CHANGED then
		g_i3k_ui_mgr:PopupTipMessage("购买失败，商城资料已变更")
	elseif flag == PROTOCOL_OP_CONF_MALL_GOODS_RESTRICTION then
		g_i3k_ui_mgr:PopupTipMessage("购买失败，限购物品已变更")
	elseif flag == PROTOCOL_OP_CONF_MALL_GOODS_DISCOUNT then
		g_i3k_ui_mgr:PopupTipMessage("购买失败，物品价格已变更")
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_VipStore, "isNeedRefreshLog")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_VipStore, "setStoreList",false)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FiveUniquePrestige, "updateUI")

	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_upStage, "setPropData")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Unlock, "setPropData")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Slot_Unlock, "setPropData")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_update, "setPropData")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Talent_Point_Reset, "setPropData")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune, "updateWishRunesData")

	g_i3k_ui_mgr:RefreshUI(eUIID_QiankunBuy)
	g_i3k_ui_mgr:RefreshUI(eUIID_QiankunReset)

	g_i3k_ui_mgr:InvokeUIFunction(eUIID_PrayActivityTurntable, "updateCostItems")
end


---------------------------------动态活动----------------------------------------------
-- 活动同步
-- --Packet:activities_sync_res
-- function i3k_sbean.sync_dynamic_activities()
-- 	local bean = i3k_sbean.activities_sync_req.new()
-- 	i3k_game_send_str_cmd(bean, i3k_sbean.activities_sync_res.getName())
-- end
--
-- function i3k_sbean.activities_sync_res.handler(res, req)
-- 	if res.info then
-- 		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "setCanUse", true)
-- 		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "clearScorll")--new add
-- 		g_i3k_ui_mgr:OpenUI(eUIID_Fuli)
-- 		g_i3k_ui_mgr:RefreshUI(eUIID_Fuli, res.info)
-- 	end
-- end

-- 福利同步
--Packet:benefit_sync_res
function i3k_sbean.sync_dynamic_benefit(actName)
	local data = i3k_sbean.benefit_sync_req.new()
	data.actName = actName
	i3k_game_send_str_cmd(data, i3k_sbean.benefit_sync_res.getName())
end

function i3k_sbean.benefit_sync_res.handler(res,req)
	g_i3k_game_context:SetFuliRedPointCount(0)
	local checkinGift = res.checkinGift
	local dailyOnlineGift = res.dailyOnlineGift
	local dailyVitReward = res.dailyVitReward
	local monthlyCardReward = 0
	g_i3k_game_context:AddFuliRedPointCount(checkinGift)
	g_i3k_game_context:AddFuliRedPointCount(dailyOnlineGift)
	local activities = res.activities
	local bindPhoneReward = res.bindPhoneReward  --是否开启手机绑定功能
	g_i3k_ui_mgr:OpenUI(eUIID_Fuli)
	g_i3k_ui_mgr:RefreshUI(eUIID_Fuli, activities,checkinGift,dailyOnlineGift,monthlyCardReward,dailyVitReward, req.actName, bindPhoneReward)
end

-- 充值活动入口同步协议
function i3k_sbean.sync_pay_activity(jumpID)
	local data = i3k_sbean.payactivity_sync_req.new()
	data.jumpID = jumpID
	i3k_game_send_str_cmd(data, i3k_sbean.payactivity_sync_res.getName())
end
function i3k_sbean.payactivity_sync_res.handler(res,req)
	-- g_i3k_game_context:SetFuliRedPointCount(0)

	local activities = res.activities
	g_i3k_ui_mgr:OpenUI(eUIID_PayActivity)
	g_i3k_ui_mgr:RefreshUI(eUIID_PayActivity, activities, req.jumpID)
end


-- 特权卡（1月卡，2周卡）
function i3k_sbean.sync_special_card(cardType)
	local data = i3k_sbean.sync_special_card_req.new()
	data.cardType = cardType
	i3k_game_send_str_cmd(data, i3k_sbean.sync_special_card_res.getName())
end

function i3k_sbean.sync_special_card_res.handler(res, req)
	if res.info then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PayActivity, "updateSpecialCard", req.cardType, res.id, res.info)
	else
		g_i3k_ui_mgr:PopupTipMessage("同步失败")
	end
end

-- 领取特权卡奖励
function i3k_sbean.take_special_card_reward(cardType, items)
	local data = i3k_sbean.take_special_card_reward_req.new()
	data.cardType = cardType
	data.items = items
	i3k_game_send_str_cmd(data, i3k_sbean.take_special_card_reward_res.getName())
end

function i3k_sbean.take_special_card_reward_res.handler(res, req)
	if res.ok == 1 then
		local cfg = g_i3k_game_context:getRoleSpecialCards(req.cardType)
		if cfg then
			g_i3k_game_context:setRoleSpecialCardsReward(req.cardType, 1)
		end
		if req.cardType == WEEK_CARD then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_PayActivity, "updateWeekCardInfo")
		elseif req.cardType == MONTH_CARD then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_PayActivity, "updateMonthCardInfo")
		elseif req.cardType == SUPER_MONTH_CARD then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_PayActivity, "updateSuperMonthCardInfo")
		end
		g_i3k_ui_mgr:ShowGainItemInfo(req.items)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleEntrance, "RefreshAllItem") -- 刷新下充值的红点
	end
end

-- 龙魂币同步
function i3k_sbean.sync_dragon_coin(payType)
	local data = i3k_sbean.paygoods_sync_req.new()
	data.type = payType
	i3k_game_send_str_cmd(data, i3k_sbean.paygoods_sync_res.getName())
end

function i3k_sbean.paygoods_sync_res.handler(res, req)
	if res.id > 0 and #res.payLevels > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PayActivity, "updateDragonCoin", res.id, res.payLevels)
	else
		g_i3k_ui_mgr:PopupTipMessage("同步失败")
	end
end

--同步首次充值送礼活动信息
--Packet:firstpaygift_sync_res
function i3k_sbean.sync_activities_firstpaygift(actId,actType)
	local bean = i3k_sbean.firstpaygift_sync_req.new()
	bean.id = actId
	bean.__callback = function(effectiveTime, cfg, log)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PayActivity, "updateFirstPayGiftInfo", actType,actId,effectiveTime, cfg, log,index)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateFirstPayGiftInfo", actType,actId,effectiveTime, cfg, log,index)
	end
	i3k_game_send_str_cmd(bean, i3k_sbean.firstpaygift_sync_res.getName())
end

function i3k_sbean.firstpaygift_sync_res.handler(res, req)--ok,info
	if res.ok > 0 then
		if req.__callback then
			req.__callback(res.info.effectiveTime, res.info.cfg, res.info.log)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("活动已经失效")---做刷新，弹框？
	end

end

-- 领取首次充值活动奖励
--Packet:firstpaygift_take_res
function i3k_sbean.activities_firstpaygift_take(effectiveTime,id,gifts,index,actType)
	local bean = i3k_sbean.firstpaygift_take_req.new()
	bean.effectiveTime = effectiveTime
	bean.id = id
	bean.gifts = gifts
	bean.index = index
	bean.actType = actType
	i3k_game_send_str_cmd(bean, i3k_sbean.firstpaygift_take_res.getName())
end

function i3k_sbean.firstpaygift_take_res.handler(res, req)--ok
	if res.ok > 0 then
		g_i3k_game_context:ClearNotice(g_NOTICE_TYPE_CAN_REWARD_FIRST_PAYGIFT)
		g_i3k_game_context:SetDynamicActivityRedPointInfo(0)
		g_i3k_ui_mgr:ShowGainItemInfo(req.gifts)
		i3k_sbean.sync_activities_firstpaygift(req.id,req.actType)
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

-- 同步充值送礼活动信息
--Packet:paygift_sync_res
function i3k_sbean.sync_activities_paygift( actId,actType)
	local bean = i3k_sbean.paygift_sync_req.new()
	bean.id = actId
	bean.__callback = function(effectiveTime, cfg, log)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PayActivity, "updatePayGiftInfo", actType, actId, effectiveTime, cfg, log)
	end
	i3k_game_send_str_cmd(bean, i3k_sbean.paygift_sync_res.getName())
end

function i3k_sbean.paygift_sync_res.handler(res, req)
	if res.ok > 0 then
		if req.__callback then
			req.__callback(res.info.effectiveTime, res.info.cfg, res.info.log)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("活动已经失效")
	end
end


-- 领取充值送礼活动奖励
--Packet:paygift_take_res
function i3k_sbean.activities_paygift_take(effectiveTime,id,payLevel,actType,gifts,index)
	local bean = i3k_sbean.paygift_take_req.new()
	bean.effectiveTime = effectiveTime
	bean.id = id
	bean.payLevel = payLevel
	bean.actType = actType
	bean.gifts = gifts
	bean.index = index
	i3k_game_send_str_cmd(bean, i3k_sbean.paygift_take_res.getName())
end

function i3k_sbean.paygift_take_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:ShowGainItemInfo(req.gifts)
		g_i3k_game_context:SetDynamicActivityRedPointInfo(0)
		i3k_sbean.sync_activities_paygift(req.id,req.actType,req.percent)
		--si3k_sbean.sync_dynamic_activities()
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

-- 同步消费送礼活动
--Packet:consumegift_sync_res
function i3k_sbean.sync_activities_consumegift(actId,actType)
	local bean = i3k_sbean.consumegift_sync_req.new()
	bean.id = actId
	bean.__callback = function(effectiveTime, cfg, log)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateConsumeGiftInfo", actType, actId, effectiveTime, cfg, log)
	end
	i3k_game_send_str_cmd(bean, i3k_sbean.consumegift_sync_res.getName())
end

function i3k_sbean.consumegift_sync_res.handler(res, req)
	if res.ok > 0 then
		if req.__callback then
			req.__callback(res.info.effectiveTime, res.info.cfg, res.info.log)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("活动已经失效")
	end
end

-- 领取消费送礼活动奖励
--Packet:consumegift_take_res
function i3k_sbean.activities_consumegift_take(effectiveTime,id,consumeLevel,actType,gifts,index)
	local bean = i3k_sbean.consumegift_take_req.new()
	bean.effectiveTime = effectiveTime
	bean.id = id
	bean.consumeLevel = consumeLevel
	bean.actType = actType
	bean.gifts = gifts
	bean.index = index
	i3k_game_send_str_cmd(bean, i3k_sbean.consumegift_take_res.getName())
end

function i3k_sbean.consumegift_take_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetDynamicActivityRedPointInfo(0)
		g_i3k_ui_mgr:ShowGainItemInfo(req.gifts)
		i3k_sbean.sync_activities_consumegift(req.id,req.actType,req.percent )
		--i3k_sbean.sync_dynamic_activities()
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

-- 同步冲级送礼活动信息
--Packet:upgradegift_sync_res
function i3k_sbean.sync_activities_gradegift( actId,actType)
	local bean = i3k_sbean.upgradegift_sync_req.new()
	bean.id = actId
	bean.__callback = function(effectiveTime, cfg, log)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateGradeGiftInfo", actType, actId, effectiveTime, cfg, log)
	end
	i3k_game_send_str_cmd(bean, i3k_sbean.upgradegift_sync_res.getName())
end

function i3k_sbean.upgradegift_sync_res.handler(res, req)
	if res.ok > 0 then
		if req.__callback then
			req.__callback(res.info.effectiveTime, res.info.cfg, res.info.log)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("活动已经失效")
	end
end


-- 领取冲级送礼活动奖励
function i3k_sbean.activities_gradegift_take(effectiveTime,id,level,actType,gift,index)
	local bean = i3k_sbean.upgradegift_take_req.new()
	bean.effectiveTime = effectiveTime
	bean.id = id
	bean.level = level
	bean.actType = actType
	bean.gift = gift
	bean.index = index
	i3k_game_send_str_cmd(bean, i3k_sbean.upgradegift_take_res.getName())
end

function i3k_sbean.upgradegift_take_res.handler(res, req)--只有ok
	if res.ok > 0 then
		g_i3k_game_context:SetDynamicActivityRedPointInfo(0)
		g_i3k_ui_mgr:ShowGainItemInfo(req.gift)
		--i3k_sbean.sync_dynamic_activities()
		i3k_sbean.sync_activities_gradegift(req.id,req.actType,req.percent)
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

-- 同步投资基金活动信息
--Packet:investmentfund_sync_res
function i3k_sbean.sync_activities_investmentfund( actId,actType)
	local bean = i3k_sbean.investmentfund_sync_req.new()
	bean.id = actId
	bean.__callback = function(effectiveTime, cfg, log)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateInvestmentfundGiftInfo", actType, actId, effectiveTime, cfg, log)
	end
	i3k_game_send_str_cmd(bean, i3k_sbean.investmentfund_sync_res.getName())
end

function i3k_sbean.investmentfund_sync_res.handler(res, req)
	if res.ok > 0 then
		if req.__callback then
			req.__callback(res.info.effectiveTime, res.info.cfg, res.info.log)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("活动已经失效")
	end
end

-- 买投资基金
--Packet:investmentfund_buy_res
function i3k_sbean.activities_investmentfund_buy(effectiveTime,id,pay,buyendtime,actType)
	local bean = i3k_sbean.investmentfund_buy_req.new()
	bean.effectiveTime = effectiveTime
	bean.id = id
	bean.pay = pay
	bean.buyendtime = buyendtime
	bean.actType = actType
	i3k_game_send_str_cmd(bean, i3k_sbean.investmentfund_buy_res.getName())
end

function i3k_sbean.investmentfund_buy_res.handler(res, req)--只有ok
	local curtime = i3k_game_get_time()
	if curtime < req.buyendtime then
		if res.ok > 0 then
			g_i3k_game_context:UseDiamond(req.pay,true,AT_BUY_INVESTMENT_FUND)
			i3k_sbean.sync_activities_investmentfund(req.id ,req.actType)
			--i3k_sbean.sync_dynamic_activities()
		else
			g_i3k_ui_mgr:PopupTipMessage("购买投资基金失败")
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("活动已过期")
	end
end


-- 领取投资基金活动奖励
--Packet:investmentfund_take_res
function i3k_sbean.activities_investmentfund_take(effectiveTime,id,day,price,actType)
	local bean = i3k_sbean.investmentfund_take_req.new()
	bean.effectiveTime = effectiveTime
	bean.id = id
	bean.day = day
	bean.price = price
	bean.actType = actType
	i3k_game_send_str_cmd(bean, i3k_sbean.investmentfund_take_res.getName())
end

function i3k_sbean.investmentfund_take_res.handler(res, req)--只有ok
	if res.ok > 0 then
		g_i3k_game_context:SetDynamicActivityRedPointInfo(0)
		--i3k_sbean.sync_dynamic_activities()
		i3k_sbean.sync_activities_investmentfund(req.id,req.actType,req.percent )
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

-- 同步成长基金活动信息
--Packet:growthfund_sync_res
function i3k_sbean.sync_activities_growthfund(actId,actType)
	local bean = i3k_sbean.growthfund_sync_req.new()
	bean.id = actId
	bean.__callback = function(effectiveTime, cfg, log)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateGrowthfundGiftInfo", actType, actId, effectiveTime, cfg, log)
	end
	i3k_game_send_str_cmd(bean, i3k_sbean.growthfund_sync_res.getName())
end

function i3k_sbean.growthfund_sync_res.handler(res, req)--ok,info
	if res.ok > 0 then
		if req.__callback then
			req.__callback(res.info.effectiveTime, res.info.cfg, res.info.log)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("活动已经失效")
	end
end

-- 买成长基金
--Packet:growthfund_buy_res
function i3k_sbean.activities_growthfund_buy(effectiveTime,id,pay,buyendtime,actType)
	local bean = i3k_sbean.growthfund_buy_req.new()
	bean.effectiveTime = effectiveTime
	bean.id = id
	bean.pay = pay
	bean.buyendtime = buyendtime
	bean.actType = actType
	i3k_game_send_str_cmd(bean, i3k_sbean.growthfund_buy_res.getName())
end

function i3k_sbean.growthfund_buy_res.handler(res, req)--只有ok
	local curtime = i3k_game_get_time()
	if curtime < req.buyendtime then
		if res.ok > 0 then
			g_i3k_game_context:UseDiamond(req.pay,true,AT_BUY_INVESTMENT_FUND)
			i3k_sbean.sync_activities_growthfund(req.id ,req.actType)
			--i3k_sbean.sync_dynamic_activities()
		else
			g_i3k_ui_mgr:PopupTipMessage("购买基金失败")
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("活动已经失效")
	end
end

-- 领取成长基金活动奖励
--Packet:growthfund_take_res
function i3k_sbean.activities_growthfund_take(effectiveTime,id,level,price,actType)
	local bean = i3k_sbean.growthfund_take_req.new()
	bean.effectiveTime = effectiveTime
	bean.id = id
	bean.level = level
	bean.price = price
	bean.actType = actType
	i3k_game_send_str_cmd(bean, i3k_sbean.growthfund_take_res.getName())
end

function i3k_sbean.growthfund_take_res.handler(res, req)--只有ok
	if res.ok > 0 then
		g_i3k_game_context:SetDynamicActivityRedPointInfo(0)
		--i3k_sbean.sync_dynamic_activities()
		i3k_sbean.sync_activities_growthfund(req.id,req.actType,req.percent )
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

-- 同步双倍掉落副本活动信息
--Packet:doubledrop_sync_res
function i3k_sbean.sync_activities_doubledrop( actId,actType)
	local bean = i3k_sbean.doubledrop_sync_req.new()
	bean.id = actId
	bean.__callback = function(time, content, title)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateDoubleDropInfo", actType, actId,time, content, title)
	end
	i3k_game_send_str_cmd(bean, i3k_sbean.doubledrop_sync_res.getName())
end

function i3k_sbean.doubledrop_sync_res.handler(res, req)--ok,info
	if res.ok > 0 then
		if req.__callback then
			req.__callback(res.info.time, res.info.content, res.info.title)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("活动已经失效")
	end

end

-- 同步额外掉落副本活动信息
--Packet:extradrop_sync_res
function i3k_sbean.sync_activities_extradrop(actId,actType, percent)
	local bean = i3k_sbean.extradrop_sync_req.new()
	bean.id = actId
	bean.__callback = function(info)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateExtraDropInfo", actType, actId, info,percent)
	end
	i3k_game_send_str_cmd(bean, i3k_sbean.extradrop_sync_res.getName())
end

function i3k_sbean.extradrop_sync_res.handler(res, req)--ok,info
	local curtime = i3k_game_get_time()
	if res.ok > 0 then
		if req.__callback then
			req.__callback(res.info)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("活动已经失效")
	end

end

-- 同步兑换礼品活动信息
--Packet:exchangegift_sync_res
function i3k_sbean.sync_activities_exchangegift( actId,actType,percent)
	local bean = i3k_sbean.exchangegift_sync_req.new()
	bean.id = actId
	bean.__callback = function(effectiveTime, cfg, log)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateExchangeGiftInfo", actType, actId, effectiveTime, cfg, log,percent)
	end
	i3k_game_send_str_cmd(bean, i3k_sbean.exchangegift_sync_res.getName())
end

function i3k_sbean.exchangegift_sync_res.handler(res, req)--ok,info
	if res.ok > 0 then
		if req.__callback then
			req.__callback(res.info.effectiveTime, res.info.cfg, res.info.log)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("活动已经失效")
	end

end

-- 领取兑换礼品
--Packet:exchangegift_take_res
function i3k_sbean.activities_exchangegift_take(effectiveTime,id,seq,items,actType,gifts,percent)----扣道具 table ,callback
	local bean = i3k_sbean.exchangegift_take_req.new()
	bean.effectiveTime = effectiveTime
	bean.id = id
	bean.seq = seq
	bean.items = items
	bean.actType = actType
	bean.gifts = gifts
	bean.percent = percent
	i3k_game_send_str_cmd(bean, i3k_sbean.exchangegift_take_res.getName())
end

function i3k_sbean.exchangegift_take_res.handler(res, req)--只有ok
	if res.ok > 0 then
		for k,v in pairs (req.items) do
			--扣道具req.
			g_i3k_game_context:UseCommonItem(v.id, v.count,AT_TAKE_EXCHANGE_GIFT_REWARD)--UseBagItem
		end
		g_i3k_game_context:SetDynamicActivityRedPointInfo(0)
		g_i3k_ui_mgr:ShowGainItemInfo(req.gifts)
		i3k_sbean.sync_activities_exchangegift(req.id,req.actType,req.percent)
		g_i3k_ui_mgr:PopupTipMessage("领取成功")
		--i3k_sbean.sync_dynamic_activities()
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

--同步累积登录送礼活动信息
--Packet:logingift_sync_res
function i3k_sbean.sync_activities_logingift( actId,actType,percent)
	local bean = i3k_sbean.logingift_sync_req.new()
	bean.id = actId
	bean.__callback = function(effectiveTime, cfg, log)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateLoginGiftInfo", actType, actId, effectiveTime, cfg, log,percent)
	end
	i3k_game_send_str_cmd(bean, i3k_sbean.logingift_sync_res.getName())
end

function i3k_sbean.logingift_sync_res.handler(res, req)--ok,info
	if res.ok > 0 then
		if res.info and (res.info.log.lastLoginTime < res.info.cfg.time.endTime) then
			if req.__callback then
				req.__callback(res.info.effectiveTime, res.info.cfg, res.info.log)
			end
		else
			g_i3k_ui_mgr:PopupTipMessage("活动已经失效")
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("活动已经失效")
	end
end

--领取累积登录送礼活动奖励
--Packet:logingift_take_res
function i3k_sbean.activities_logingift_take(effectiveTime,id,day,actType,gifts,percent,index)
	local bean = i3k_sbean.logingift_take_req.new()
	bean.effectiveTime = effectiveTime
	bean.id = id
	bean.day = day
	bean.actType = actType
	bean.percent = percent
	bean.gifts = gifts
	bean.index = index
	i3k_game_send_str_cmd(bean, i3k_sbean.logingift_take_res.getName())
end

function i3k_sbean.logingift_take_res.handler(res, req)--只有ok
	if res.ok > 0 then
		--i3k_sbean.sync_dynamic_activities()
		g_i3k_game_context:SetDynamicActivityRedPointInfo(0)
		g_i3k_ui_mgr:ShowGainItemInfo(req.gifts)

		i3k_sbean.sync_activities_logingift(req.id,req.actType,req.percent )
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

--同步礼包码活动信息
--Packet:giftpackage_sync_res
function i3k_sbean.sync_activities_giftpackage( actId,actType)
	local bean = i3k_sbean.giftpackage_sync_req.new()
	bean.id = actId
	bean.__callback = function(effectiveTime)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateGiftPackageInfo", actType, actId, effectiveTime)
	end
	i3k_game_send_str_cmd(bean, i3k_sbean.giftpackage_sync_res.getName())
end
function i3k_sbean.giftpackage_sync_res.handler(res, req)

		if res.ok > 0 then
			if req.__callback then
				req.__callback(res.info.effectiveTime)--(res.info.time, res.info.title, res.info.content)
			end
		else
			g_i3k_ui_mgr:PopupTipMessage("活动已经失效")
		end
end
----兑换礼包码活动信息


local activity_error = {
	[-1] = "领取失败,请输入正确的礼包码",
	[-2] = "领取失败,礼包码还未配置",
	[-3] = "领取失败,礼包码未在有效期",
	[-4] = "领取失败,背包没有足够空间",
	[-5] = "领取失败,兑换码的管道与帐户的管道不匹配",
	[-6] = "领取失败,等级或贵族等级不足",
	[-7] = "领取失败,此礼包码领取已达上限",
	[-1001] = "领取失败,礼包码还未配置",
	[-1002] = "领取失败,礼包已经领取,请在背包中查收",
	[-1003] = "领取失败,礼包码已经被使用",
	[-1004] = "领取失败,该帐号已经兑换过同批次礼包码",
	[-101] = "领取失败,网路异常,连接兑换服务器失败",
	[-102] = "领取失败,兑换超时请重试",
	[-21] = "领取失败,请输入正确的礼包码",
	[-22] = "领取失败,礼包配置错误",
	[-23] = "领取失败,背包没有足够空间",
	[-2001] = "领取失败,请输入正确的礼包码",
	[-2002] ="领取失败,你已经领取了礼包，不能重复使用",
	[-2003] = "领取失败,礼包码已经被使用",
	[-2004] = "领取失败,礼包码未启动不可用",
	[-2005] = "领取失败,礼包码未到期启动",
	[-2006] = "领取失败,礼包码已经过期",
	[-2007] = "领取失败,礼包码不能在此游戏区使用",
	[-2008] = "领取失败,礼包码不能在此管道使用",
	[-2009] = "领取失败,角色等级不在礼包码使用需要的有效等级内",
	[-2010] = "领取失败,角色贵族等级不在礼包码使用需要的有效等级内",
	[-2011] = "领取失败,已经使用过其他互斥礼包",
	[-2012] = "领取失败,已经超过此批次礼包最大使用数目",
}

-- 兑换礼包
--Packet:giftpackage_take_res
function i3k_sbean.activities_giftpackage_take(effectiveTime,id,key,actType)
	local bean = i3k_sbean.giftpackage_take_req.new()
	bean.effectiveTime = effectiveTime
	bean.id = id
	bean.key = key
	bean.actType = actType
	i3k_game_send_str_cmd(bean, i3k_sbean.giftpackage_take_res.getName())
end
function i3k_sbean.giftpackage_take_res.handler(res, req)--ok，pack(title,content,gifts(id,count))
	if res.ok > 0  then
		g_i3k_ui_mgr:ShowGiftPackageGainItemInfo(res.pack.title,res.pack.gifts)
		i3k_sbean.sync_activities_giftpackage( req.id,req.actType)
	else
		local str = activity_error[res.ok] or "领取失败,请重试"..(res.ok or "nil")
		g_i3k_ui_mgr:PopupTipMessage(str)
	end
end

--每日充值送礼
--Packet:dailypaygift_sync_res
function i3k_sbean.pay_gift_everyday(actId,actType)
	local bean = i3k_sbean.dailypaygift_sync_req.new()
	bean.id = actId
	bean.type = actType
	i3k_game_send_str_cmd(bean, i3k_sbean.dailypaygift_sync_res.getName())
end

function i3k_sbean.dailypaygift_sync_res.handler(res,req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PayActivity,"updatePayGiftEveryDay",req.type,req.id,res.info,res.today)
	end
end

--连续充值同步数据
--Packet:lastpaygift_sync_res
function i3k_sbean.lastpaygift_sync(actId,actType)
	local bean = i3k_sbean.lastpaygift_sync_req.new()
	bean.id = actId
	bean.type = actType
	i3k_game_send_str_cmd(bean, i3k_sbean.lastpaygift_sync_res.getName())
end

function i3k_sbean.lastpaygift_sync_res.handler(res,req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PayActivity,"updateLastCharge",req.type,req.id,res.info)
		--g_i3k_ui_mgr:PopupTipMessage("连续储值活动同步成功")
	end
end

--连续充值领取奖励
--Packet:lastpaygift_take_res
function i3k_sbean.lastpaygift_take(effectiveTime,seq,gift,actType,actId)
	local bean = i3k_sbean.lastpaygift_take_req.new()
	bean.effectiveTime = effectiveTime
	bean.seq = seq
	bean.gift = gift
	bean.actType = actType
	bean.id = actId
	i3k_game_send_str_cmd(bean, i3k_sbean.lastpaygift_take_res.getName())
end

function i3k_sbean.lastpaygift_take_res.handler(res,req)
	if res.ok > 0 then
		g_i3k_game_context:SetDynamicActivityRedPointInfo(0)
		g_i3k_ui_mgr:ShowGainItemInfo(req.gift)
		i3k_sbean.lastpaygift_sync(req.id,req.actType)
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

--限时团购同步数据
--Packet:groupbuy_sync_res
function i3k_sbean.groupbuy_sync(index)
	local bean = i3k_sbean.groupbuy_sync_req.new()
	bean.index = index
	i3k_game_send_str_cmd(bean, i3k_sbean.groupbuy_sync_res.getName())
end

function i3k_sbean.groupbuy_sync_res.handler(res,req)
	if res.ok > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_GroupBuy)
		g_i3k_ui_mgr:RefreshUI(eUIID_GroupBuy,res.info,req.index)
		--g_i3k_ui_mgr:PopupTipMessage("限时团购同步成功")
	end
end

--限时团购领取奖励
--Packet:groupbuy_buy_res
function i3k_sbean.groupbuy_buy(effectiveTime,id,gid,count,index,gift,price)
	local bean = i3k_sbean.groupbuy_buy_req.new()
	bean.effectiveTime = effectiveTime
	bean.id = id
	bean.gid = gid
	bean.count = count
	bean.index = index
	bean.gift = gift
	bean.price = price
	i3k_game_send_str_cmd(bean, i3k_sbean.groupbuy_buy_res.getName())
end

function i3k_sbean.groupbuy_buy_res.handler(res,req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("购买成功")
		i3k_sbean.groupbuy_sync(req.index)
		g_i3k_ui_mgr:ShowGainItemInfo(req.gift)
		g_i3k_game_context:UseDiamond(req.price, true , AT_GROUPUY_GOODS)
	end
end

--限时特卖同步数据
function i3k_sbean.flashsale_sync(index)
	local bean = i3k_sbean.flashsale_sync_req.new()
	bean.index = index
	i3k_game_send_str_cmd(bean, i3k_sbean.flashsale_sync_res.getName())
end

function i3k_sbean.flashsale_sync_res.handler(res,req)
	if res.ok > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_FlashSale)
		g_i3k_ui_mgr:RefreshUI(eUIID_FlashSale,res.infos,req.index )
	end
end

--限时特卖领取奖励
function i3k_sbean.flashsale_buy(effectiveTime, id, gid, index, gift, price, moneyId,count)
	local bean = i3k_sbean.flashsale_buy_req.new()
	bean.effectiveTime = effectiveTime
	bean.id = id
	bean.goodid = gid
	bean.index = index
	bean.gift = gift
	bean.price = price
	bean.moneyId = moneyId
	bean.count = count
	i3k_game_send_str_cmd(bean, i3k_sbean.flashsale_buy_res.getName())
end

function i3k_sbean.flashsale_buy_res.handler(res,req)
	if res.ok > 0 then
		i3k_sbean.flashsale_sync(req.index)
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_FlashSale, "updateCount" , req.count)
		g_i3k_ui_mgr:ShowGainItemInfo(req.gift)
		if req.moneyId < 0 then
			g_i3k_game_context:UseBaseItem(req.moneyId, req.price*req.count, AT_FLASHSALE_GOODS)
		else
			local bind = g_i3k_game_context:GetBaseItemCanUseCount(req.moneyId)
			local unbind = g_i3k_game_context:GetBaseItemCanUseCount(-req.moneyId)
			if unbind >= req.price*req.count then
				g_i3k_game_context:UseBaseItem(req.moneyId, req.price*req.count, AT_FLASHSALE_GOODS)
			else
				g_i3k_game_context:UseBaseItem(req.moneyId, bind, AT_FLASHSALE_GOODS)
				g_i3k_game_context:UseBaseItem(-req.moneyId, req.price*req.count - bind, AT_FLASHSALE_GOODS)
			end
		end

	else
		g_i3k_ui_mgr:PopupTipMessage("购买失败")
	end
end

--限时特卖领取宝箱奖励
function i3k_sbean.falshsale_open_box_req(effectiveTime, id, index, gifts)
	local bean = i3k_sbean.falshsale_open_box.new()
	bean.effectiveTime = effectiveTime
	bean.id = id
	bean.index = index
	bean.gifts = gifts
	i3k_game_send_str_cmd(bean, i3k_sbean.falshsale_open_box_res.getName())
end

function i3k_sbean.falshsale_open_box_res.handler(res, req)
	if res.ok > 0 then
		i3k_sbean.flashsale_sync(req.index)
		if req.gifts then
			g_i3k_ui_mgr:ShowGainItemInfo(req.gifts)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("打开宝箱失败")
	end
end

--领取每日充值奖励
--Packet:dailypaygift_take_res
function i3k_sbean.pay_gift_get_award(effectiveTime,actType,id,gift)
	local data = i3k_sbean.dailypaygift_take_req.new()
	data.effectiveTime = effectiveTime
	data.id = id
	data.actType = actType
	data.gift = gift
	i3k_game_send_str_cmd(data, i3k_sbean.dailypaygift_take_res.getName())
end

function i3k_sbean.dailypaygift_take_res.handler(res,req)
	if res.ok > 0 then
		g_i3k_game_context:SetDynamicActivityRedPointInfo(0)
		g_i3k_ui_mgr:ShowGainItemInfo(req.gift)
		i3k_sbean.pay_gift_everyday(req.id,req.actType)
	else

	g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

--征战天下同步数据
function i3k_sbean.activitychallengegift_sync(actId,actType,index)
	local bean = i3k_sbean.activitychallengegift_sync_req.new()
	bean.id = actId
	bean.type = actType
	bean.index = index
	i3k_game_send_str_cmd(bean, i3k_sbean.activitychallengegift_sync_res.getName())
end

function i3k_sbean.activitychallengegift_sync_res.handler(res,req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli,"updateActivitychallenge",req.type,req.id,res.info,req.index)
	end
end

--征战天下领取奖励
function i3k_sbean.activitychallengegift_take(effectiveTime,id,activityId,times,index,gift,actType)
	local bean = i3k_sbean.activitychallengegift_take_req.new()
	bean.effectiveTime = effectiveTime
	bean.id = activityId
	bean.activityId = id
	bean.times = times
	bean.index = index
	bean.gift = gift
	bean.actType = actType
	i3k_game_send_str_cmd(bean, i3k_sbean.activitychallengegift_take_res.getName())
end

function i3k_sbean.activitychallengegift_take_res.handler(res,req)
	if res.ok > 0 then
		i3k_sbean.activitychallengegift_sync(req.id,req.actType,req.index)
		g_i3k_ui_mgr:ShowGainItemInfo(req.gift)
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

--升级特惠活动同步数据
function i3k_sbean.upgradepurchase_sync(actId,actType)
	local bean = i3k_sbean.upgradepurchase_sync_req.new()
	bean.id = actId
	bean.type = actType
	i3k_game_send_str_cmd(bean, i3k_sbean.upgradepurchase_sync_res.getName())
end

function i3k_sbean.upgradepurchase_sync_res.handler(res,req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli,"updateUpgradepurchase",req.type,req.id,res.info)
	end
end

--升级特惠活动领取奖励
function i3k_sbean.upgradepurchase_buy(effectiveTime,id,activityId,gift,actType, price)
	local bean = i3k_sbean.upgradepurchase_buy_req.new()
	bean.effectiveTime = effectiveTime
	bean.id = activityId
	bean.activityId = id
	bean.gift = gift
	bean.actType = actType
	bean.price = price
	i3k_game_send_str_cmd(bean, i3k_sbean.upgradepurchase_buy_res.getName())
end

function i3k_sbean.upgradepurchase_buy_res.handler(res,req)
	if res.ok > 0 then
		i3k_sbean.upgradepurchase_sync(req.id,req.actType)
		g_i3k_ui_mgr:ShowGainItemInfo(req.gift)
		g_i3k_game_context:UseDiamond(req.price, true, AT_BUY_LEVEL_UP_REWARD)
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

-- 直购礼包活动信息
function i3k_sbean.sync_direct_purchase(id, actType)
	local bean = i3k_sbean.directpurchase_sync_req.new()
	bean.id = id
	bean.type = actType
	i3k_game_send_str_cmd(bean, i3k_sbean.directpurchase_sync_res.getName())
end
function i3k_sbean.directpurchase_sync_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PayActivity,"updateDirectPurchase", req.type, req.id, res.info)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli,"updateDirectPurchase", req.type, req.id, res.info)
	end
end
-- 领取直购礼包奖励
function i3k_sbean.take_direct_purchase(id, effectiveTime, payLevel, gift, callback)
	local bean = i3k_sbean.directpurchase_take_req.new()
	bean.id = id
	bean.effectiveTime = effectiveTime
	bean.payLevel = payLevel
	bean.gift = gift
	bean.callback = callback
	i3k_game_send_str_cmd(bean, i3k_sbean.directpurchase_take_res.getName())
end
function i3k_sbean.directpurchase_take_res.handler(res, req)
	if res.ok == 1 then
		g_i3k_ui_mgr:ShowGainItemInfo(req.gift)
		if req.callback then
			req.callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

-- 老虎机(12亿回馈)
function i3k_sbean.sync_oneArmBandit(id, actType)
	local bean = i3k_sbean.onearmbandit_sync_req.new()
	bean.id = id
	bean.type = actType
	i3k_game_send_str_cmd(bean, i3k_sbean.onearmbandit_sync_res.getName())
end
function i3k_sbean.onearmbandit_sync_res.handler(res, req)
	if res.ok == 1 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli,"updateOneArmBandit", req.type, req.id, res.info)
	end
end
-- 老虎机领奖
function i3k_sbean.take_oneArmBandit(id, effectiveTime)
	local bean = i3k_sbean.onearmbandit_take_req.new()
	bean.id = id
	bean.effectiveTime = effectiveTime
	i3k_game_send_str_cmd(bean, i3k_sbean.onearmbandit_take_res.getName())
end
function i3k_sbean.onearmbandit_take_res.handler(res, req)
	if res.gift > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "onTakeOneArmBanditCallback", res.gift)
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

-- 广告
function i3k_sbean.syncAdvertisement(id, actType)
	local bean = i3k_sbean.adver_sync_req.new()
	bean.id = id
	bean.type = actType
	i3k_game_send_str_cmd(bean, i3k_sbean.adver_sync_res.getName())
end

function i3k_sbean.adver_sync_res.handler(res, req)
	if res.ok > 0 then
		local icon = res.advers.icons[1]
		local content = res.advers.content
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateAdvertisement", icon, content)
	end
end

-- 充值排行活动同步
function i3k_sbean.syncRechargeRank(actId, actType, isNotTabBtn)
	local bean = i3k_sbean.payrank_sync_req.new()
	bean.bid = actId
	bean.type = actType
	bean.isNotTabBtn = isNotTabBtn  --不是点击页签调的协议
	i3k_game_send_str_cmd(bean, i3k_sbean.payrank_sync_res.getName())
end

function i3k_sbean.payrank_sync_res.handler(res, req)
	if res.ok > 0 then
		local info = res.info
		if info and info.cfg then
			local startTime = info.cfg.time.startTime
			local endTime = info.cfg.time.endTime
			local curTime = i3k_game_get_time()
			if curTime < endTime and curTime > startTime then
				if req.isNotTabBtn then
					g_i3k_ui_mgr:OpenUI(eUIID_RECHARGE_CONSUME_RANK)
					g_i3k_ui_mgr:RefreshUI(eUIID_RECHARGE_CONSUME_RANK, info, g_Pay_Rank)
				else
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updatePayRank", req.type, req.bid, info)
				end
			else
				g_i3k_ui_mgr:PopupTipMessage("活动还未开启，敬请期待")
			end
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("活动已经失效")
	end
end

-- 消费排行活动同步
function i3k_sbean.syncConsumeRank(actId, actType, isNotTabBtn)
	local bean = i3k_sbean.consumerank_sync_req.new()
	bean.bid = actId
	bean.type = actType
	bean.isNotTabBtn = isNotTabBtn  --不是点击页签调的协议
	i3k_game_send_str_cmd(bean, i3k_sbean.consumerank_sync_res.getName())
end

function i3k_sbean.consumerank_sync_res.handler(res, req)
	if res.ok > 0 then
		local info = res.info
		if info and info.cfg then
			local startTime = info.cfg.time.startTime
			local endTime = info.cfg.time.endTime
			local curTime = i3k_game_get_time()
			if curTime < endTime and curTime > startTime then
				if req.isNotTabBtn then
					g_i3k_ui_mgr:OpenUI(eUIID_RECHARGE_CONSUME_RANK)
					g_i3k_ui_mgr:RefreshUI(eUIID_RECHARGE_CONSUME_RANK, info, g_Consume_Rank)
				else
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateConsumeRank", req.type, req.bid, info)
				end
			else
				g_i3k_ui_mgr:PopupTipMessage("活动还未开启，敬请期待")
			end
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("活动已经失效")
	end
end

-- 新登录活动同步
function i3k_sbean.syncLuckyGift(actId, actType)
	local bean = i3k_sbean.luckygift_sync_req.new()
	bean.bid = actId
	bean.__callback = function(info)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateLuckyGift", actType, actId, info)
	end
	i3k_game_send_str_cmd(bean, i3k_sbean.luckygift_sync_res.getName())
end

function i3k_sbean.luckygift_sync_res.handler(res, req)
	if res.ok > 0 then
		if req.__callback then
			req.__callback(res.info)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("活动已经失效")
	end
end

-- 新登录活动领奖
function i3k_sbean.take_luckyGift(id, actType, effectiveTime, dayReq, gift, callback)
	local bean = i3k_sbean.luckygift_take_req.new()
	bean.effectiveTime = effectiveTime
	bean.bid = id
	bean.dayReq = dayReq
	bean.actType = actType
	bean.gift = gift
	bean.callback = callback
	i3k_game_send_str_cmd(bean, i3k_sbean.luckygift_take_res.getName())
end

function i3k_sbean.luckygift_take_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:ShowGainItemInfo(req.gift)
		if req.callback then
			req.callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
		i3k_sbean.syncLuckyGift(req.bid, req.actType) --失败了也要同步刷新一下
	end
end

-- 共享好礼活动同步
function i3k_sbean.syncSharedGift(actId, actType)
	local bean = i3k_sbean.shared_pay_sync_req.new()
	bean.id = actId
	bean.__callback = function(info)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateSharedGift", actType, actId, info)
	end
	i3k_game_send_str_cmd(bean, i3k_sbean.shared_pay_sync_res.getName())
end

function i3k_sbean.shared_pay_sync_res.handler(res, req)
	if res.ok > 0 then
		if req.__callback then
			req.__callback(res.info)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("活动已经失效")
	end
end

-- 共享好礼活动领奖
function i3k_sbean.take_sharedGift(id, actType, effectiveTime, payReq, payRoles, gifts, callback)
	local bean = i3k_sbean.shared_pay_take_reward_req.new()
	bean.effectiveTime = effectiveTime
	bean.id = id
	bean.payReq = payReq
	bean.payRoles = payRoles
	bean.actType = actType
	bean.gifts = gifts
	bean.callback = callback
	i3k_game_send_str_cmd(bean, i3k_sbean.shared_pay_take_reward_res.getName())
end

function i3k_sbean.shared_pay_take_reward_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:ShowGainItemInfo(req.gifts)
		if req.callback then
			req.callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
		i3k_sbean.syncSharedGift(req.id, req.actType) --失败了也要同步刷新一下
	end
end

-- 同步循环基金活动信息
function i3k_sbean.sync_activities_cyclefund(actId, actType)
	local bean = i3k_sbean.cyclefund_sync_req.new()
	bean.id = actId
	bean.__callback = function(effectiveTime, cfg, log)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateCycleFundGiftInfo", actType, actId, effectiveTime, cfg, log)
	end
	i3k_game_send_str_cmd(bean, i3k_sbean.cyclefund_sync_res.getName())
end

function i3k_sbean.cyclefund_sync_res.handler(res, req)
	if res.ok > 0 then
		if req.__callback then
			req.__callback(res.info.effectiveTime, res.info.cfg, res.info.log)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("活动已经失效")
	end
end

-- 买循环基金
function i3k_sbean.activities_cyclefund_buy(effectiveTime, id, pay, actType, callFun)
	local bean = i3k_sbean.cyclefund_buy_req.new()
	bean.effectiveTime = effectiveTime
	bean.id = id
	bean.pay = pay
	bean.actType = actType
	bean.callFun = callFun
	i3k_game_send_str_cmd(bean, i3k_sbean.cyclefund_buy_res.getName())
end

function i3k_sbean.cyclefund_buy_res.handler(res, req)
	if res.ok > 0 then
		if req.callFun then
			req.callFun()
		end
		g_i3k_game_context:UseDiamond(req.pay, true, AT_BUY_CYCLE_FUND)  --非绑元
		i3k_sbean.sync_activities_cyclefund(req.id, req.actType)
	else
		g_i3k_ui_mgr:PopupTipMessage("购买回圈基金失败")
	end
end

-- 领取循环基金活动奖励
function i3k_sbean.activities_cyclefund_take(effectiveTime, id, seq, actType)
	local bean = i3k_sbean.cyclefund_take_req.new()
	bean.effectiveTime = effectiveTime
	bean.id = id
	bean.seq = seq
	bean.actType = actType
	i3k_game_send_str_cmd(bean, i3k_sbean.cyclefund_take_res.getName())
end

function i3k_sbean.cyclefund_take_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetDynamicActivityRedPointInfo(0)
		i3k_sbean.sync_activities_cyclefund(req.id, req.actType)
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end
------------------------连续使用道具送礼-------------------------

--同步协议
function i3k_sbean.sync_activities_useItems_reward(actId, actType)
	local bean = i3k_sbean.use_item_act_sync_req.new()
	bean.id = actId
	bean.actType = actType
	i3k_game_send_str_cmd(bean, i3k_sbean.use_item_act_sync_res.getName())
end

function i3k_sbean.use_item_act_sync_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateUseItemsRewardInfo", req.actType, req.id, res.info.effectiveTime, res.info.cfg, res.info.log)
	else
	    g_i3k_ui_mgr:PopupTipMessage("活动已经失效")
	end
end

--领奖协议
function i3k_sbean.sync_activities_getUseItems_reward(effectiveTime, id, levelid, gifts, actType)
	local bean = i3k_sbean.use_item_act_take_reward_req.new()
	bean.effectiveTime = effectiveTime
	bean.id = id
	bean.levelid = levelid
	bean.gifts = gifts
	bean.actType = actType
	i3k_game_send_str_cmd(bean, i3k_sbean.use_item_act_take_reward_res.getName())
end

function i3k_sbean.use_item_act_take_reward_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:ShowGainItemInfo(req.gifts)
		i3k_sbean.sync_activities_useItems_reward(req.id, req.actType)
	else
	    g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

-------------------------------------------------------------------------
-- 买赠活动同步
function i3k_sbean.extra_gift_sync()
	local bean = i3k_sbean.extra_gift_sync_req.new()
	i3k_game_send_str_cmd(bean, "extra_gift_sync_res")
end

function i3k_sbean.extra_gift_sync_res.handler(bean, req)
	if bean.extraGifts.gifts then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updataBuyItemGetItem", bean.extraGifts)
	end
end

-------------------------------------------------------------------------
-- 同步红包拿来活动信息
function i3k_sbean.redpack_sync(actId, actType)
	local bean = i3k_sbean.redpack_sync_req.new()
	bean.id = actId
	bean.actType = actType
	i3k_game_send_str_cmd(bean, "redpack_sync_res")
end

function i3k_sbean.redpack_sync_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateRedPack", req.actType, req.id, res.info.effectiveTime, res.info.cfg, res.info.log)
	else
		g_i3k_ui_mgr:PopupTipMessage("活动已经失效")
	end
end

-- 红包拿来活动奖励
function i3k_sbean.redpack_take(id, actType, effectiveTime, day, gifts)
	local bean = i3k_sbean.redpack_take_req.new()
	bean.id = id
	bean.actType = actType
	bean.effectiveTime = effectiveTime
	bean.day = day
	bean.gifts = gifts
	i3k_game_send_str_cmd(bean, "redpack_take_res")
end

function i3k_sbean.redpack_take_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_RedPacketTips)
		g_i3k_ui_mgr:ShowGainItemInfo(req.gifts)
		i3k_sbean.redpack_sync(req.id, req.actType)
	else
		g_i3k_ui_mgr:PopupTipMessage("领取红包失败")
	end
end

----------------------------------------
-- 充值返元宝
function i3k_sbean.syncPayRebate(id, type)
	local data = i3k_sbean.payrebate_sync_req.new()
	data.id = id
	data.type = type
	i3k_game_send_str_cmd(data, "payrebate_sync_res")
end
function i3k_sbean.payrebate_sync_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PayActivity, "updatePayRebate", req.id, req.type, res.info)
	end
end

function i3k_sbean.takePayRebate(cfg)
	local data = i3k_sbean.payrebate_take_req.new()
	data.id = cfg.id
	data.type = cfg.type
	data.effectiveTime = cfg.effectiveTime
	data.gifts = cfg.gifts
	i3k_game_send_str_cmd(data, "payrebate_take_res")
end
function i3k_sbean.payrebate_take_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:ShowGainItemInfo(req.gifts)
		i3k_sbean.syncPayRebate(req.id, req.type)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PayActivity, "setLeftRedPoint", req.type, req.id)
	end
end

------------------------------------------
-- 拼多多，优惠团购
function i3k_sbean.syncMoreRoleDiscount(id, type)
	local data = i3k_sbean.morerolediscount_sync_req.new()
	data.id = id
	data.type = type
	i3k_game_send_str_cmd(data, "morerolediscount_sync_res")
end
function i3k_sbean.morerolediscount_sync_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateMoreRoleDiscount", req.id, req.type, res.info)
	end
end

function i3k_sbean.joinMoreRoleDiscount(cfg)
	local data = i3k_sbean.morerolediscount_join_req.new()
	data.id = cfg.id
	data.effectiveTime = cfg.effectiveTime
	data.gid = cfg.gid
	data.type = cfg.type
	i3k_game_send_str_cmd(data, "morerolediscount_join_res")
end
function i3k_sbean.morerolediscount_join_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("参与成功")
		i3k_sbean.syncMoreRoleDiscount(req.id, req.type)
	else
		g_i3k_ui_mgr:PopupTipMessage("参与失败")
	end
end

function i3k_sbean.buyMoreRoleDiscount(cfg)
	local data = i3k_sbean.morerolediscount_buy_req.new()
	data.id = cfg.id
	data.effectiveTime = cfg.effectiveTime
	data.gid = cfg.gid
	data.type = cfg.type
	data.costItem = cfg.costItem
	data.price = cfg.price
	data.getItem = cfg.getItem
	i3k_game_send_str_cmd(data, "morerolediscount_buy_res")
end
function i3k_sbean.morerolediscount_buy_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("购买成功")
		i3k_sbean.syncMoreRoleDiscount(req.id, req.type)
		g_i3k_game_context:UseCommonItem(req.costItem, req.price, AT_MORE_ROLE_DISCOUNT)
		g_i3k_ui_mgr:ShowGainItemInfo(req.getItem)
	else
		g_i3k_ui_mgr:PopupTipMessage("购买失败")
	end
end

-- 同步手机绑定信息
function i3k_sbean.phone_reward_sync()
	local data = i3k_sbean.phone_reward_sync_req.new()
	i3k_game_send_str_cmd(data, "phone_reward_sync_res")
end

function i3k_sbean.phone_reward_sync_res.handler(res, req)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateMobileBindInfo", res.lastTime, res.phoneNumber)
end

--发送验证码
function i3k_sbean.send_phone_msg(phoneNumber, bindUI)
	local bean = i3k_sbean.send_phone_msg_req.new()
	bean.phoneNumber = phoneNumber
	bean.bindUI = bindUI
	i3k_game_send_str_cmd(bean, i3k_sbean.send_phone_msg_res.getName())
end

function i3k_sbean.send_phone_msg_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateCodeBtnState", req.bindUI, i3k_game_get_time())
		g_i3k_ui_mgr:PopupTipMessage("发送成功")
	else
		g_i3k_ui_mgr:PopupTipMessage("发送失败")
	end
end

--绑定手机
function i3k_sbean.take_bind_phone_reward(code, gifts)
	local bean = i3k_sbean.take_bind_phone_reward_req.new()
	bean.code = code
	bean.gifts = gifts
	i3k_game_send_str_cmd(bean, i3k_sbean.take_bind_phone_reward_res.getName())
end

function i3k_sbean.take_bind_phone_reward_res.handler(res, req)
	if res.ok > 0 then
		i3k_sbean.phone_reward_sync()
		g_i3k_ui_mgr:ShowGainItemInfo(req.gifts)
		g_i3k_ui_mgr:PopupTipMessage("绑定成功")
	else
		g_i3k_ui_mgr:PopupTipMessage("绑定失败")
	end
end
-------------------------------------------------------------------------
-- 同步活跃领奖活动信息
function i3k_sbean.schdulegift_sync(actId, actType)
	local bean = i3k_sbean.schdulegift_sync_req.new()
	bean.id = actId
	bean.actType = actType
	i3k_game_send_str_cmd(bean, "schdulegift_sync_res")
end

function i3k_sbean.schdulegift_sync_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateScheduleGift", req.actType, req.id, res.info)
	else
		g_i3k_ui_mgr:PopupTipMessage("活动已经失效")
	end
end

-- 领取活跃领奖活动奖励
function i3k_sbean.schudulegift_take(id, actType, effectiveTime, schduleLevel, gifts, callback)
	local bean = i3k_sbean.schudulegift_take_req.new()
	bean.id = id
	bean.actType = actType
	bean.effectiveTime = effectiveTime
	bean.schduleLevel = schduleLevel
	bean.callback = callback
	i3k_game_send_str_cmd(bean, "schdulegift_take_res")
end

function i3k_sbean.schdulegift_take_res.handler(res, req)
	if res.ok > 0 then
		if req.callback then
			req.callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("领取奖励失败")
	end
end
-------------------------------------------------------------------------
-- 佛诞节信息同步
function i3k_sbean.sync_doante_info()
	local bean = i3k_sbean.donate_sync_info_req.new()
	i3k_game_send_str_cmd(bean, "donate_sync_info_res")
end

function i3k_sbean.donate_sync_info_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_NpcDonate)
		g_i3k_ui_mgr:RefreshUI(eUIID_NpcDonate, res.donateInfo)
	else
		g_i3k_ui_mgr:PopupTipMessage("活动不在开启时间")
	end
end

-- 佛诞节进行捐赠
function i3k_sbean.conduct_donate(inputGoods, outputGoods, callback)
	local bean = i3k_sbean.donate_conduct_req.new()
	bean.inputGoods = inputGoods
	bean.outputGoods = outputGoods
	bean.callback = callback
	i3k_game_send_str_cmd(bean, "donate_conduct_res")
end

function i3k_sbean.donate_conduct_res.handler(res, req)
	if res.totalTimes > 0 then
		--扣道具获得奖励，刷新界面
		for _, v in pairs (req.inputGoods) do
			g_i3k_game_context:UseCommonItem(v.id, v.count, "")
		end
		g_i3k_ui_mgr:ShowGainItemInfo(req.outputGoods)
		if req.callback then
			req.callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("捐赠失败")
	end
end

-- 领取奖励
function i3k_sbean.receive_award(grade, goods, callback)
	local bean = i3k_sbean.donate_reward_req.new()
	bean.grade = grade
	bean.goods = goods
	bean.callback = callback
	i3k_game_send_str_cmd(bean, "donate_reward_res")
end

function i3k_sbean.donate_reward_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:ShowGainItemInfo(req.goods)
		if req.callback then
			req.callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("领奖失败")
	end
end

--传世大酬宾
function i3k_sbean.requireInheritDivinework(id, fuliType)
	local data = i3k_sbean.legendmake_sync_req.new()
	data.id = id
	data.type = fuliType
	i3k_game_send_str_cmd(data, "legendmake_sync_res")
end

function i3k_sbean.legendmake_sync_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateInheritDivinework", req.id, req.type, res.info)
	end
end
-- 回归玩家双倍掉落活动
function i3k_sbean.syncBackRoleDoubleDrop(id, actType)
	local data = i3k_sbean.back_role_double_drop_sync_req.new()
	data.id = id
	data.actType = actType
	i3k_game_send_str_cmd(data, "back_role_double_drop_sync_res")
end
function i3k_sbean.back_role_double_drop_sync_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateBackRoleDoubleDrop", req.id, req.actType, res.cfg)
	end
end
--纪念金币活动
--登陆同步
function i3k_sbean.souvenir_coin_login_sync.handler(bean)
	--self.info:		DBSouvenirCoin	
	local data = {
		takeHoldReward = bean.info.takeHoldReward,
		canTakeHoldReward = bean.info.canTakeHoldReward,
	}
	g_i3k_game_context:setSouvenirCoinOnLogin(data)
end
--纪念币同步
function i3k_sbean.sync_activities_comCoin(isRefChangeUI, isShowTop)
	local data = i3k_sbean.souvenir_coin_sync_req.new()
	data.isRefChangeUI = isRefChangeUI
	data.isShowTop = isShowTop
	i3k_game_send_str_cmd(data, "souvenir_coin_sync_res")
end
function i3k_sbean.souvenir_coin_sync_res.handler(res, req)
	if res.info then
		if req.isRefChangeUI then
			local data = {
				nowExchangeScale = i3k_db_commecoin_addValueNode[g_i3k_db.i3k_db_getCoin_changeScale()].scaleValue,
				exchangeItemNums = res.info.exchangeItemNums,
			}
			g_i3k_ui_mgr:RefreshUI(eUIID_ExChangeCoin, data, req.isShowTop)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_PayActivity, "updateComCoinInfo", res.info, req.isShowTop)
		else
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_PayActivity, "updateComCoinInfo", res.info, req.isShowTop)
		end
	end
end
--购买纪念币
function i3k_sbean.syncBuycomCoin(num)
	local data = i3k_sbean.souvenir_coin_buy_req.new()
	data.num = num
	i3k_game_send_str_cmd(data, "souvenir_coin_buy_res")
end
function i3k_sbean.souvenir_coin_buy_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:UseCommonItem(i3k_db_commecoin_cfg.buyConfig.needPropId, req.num * i3k_db_commecoin_cfg.buyConfig.unitPrice)
		i3k_sbean.sync_activities_comCoin(false, true)
		g_i3k_ui_mgr:CloseUI(eUIID_JnCoinBuyTips)
	end
end
--兑现纪念币
function i3k_sbean.syncCashcomCoin(index, num)
	local data = i3k_sbean.souvenir_coin_cash_req.new()
	data.index = index
	data.num = num
	i3k_game_send_str_cmd(data, "souvenir_coin_cash_res")
end
function i3k_sbean.souvenir_coin_cash_res.handler(res, req)
	if res.ok > 0 then
		local coinId = i3k_db_commecoin_cfg.buyConfig.getPropId
		g_i3k_game_context:UseBagMiscellaneous(coinId, req.num)
		i3k_sbean.sync_activities_comCoin(true, true)
	else
		g_i3k_game_context:UpdateScaleToChangeCoin()
	end
end
--代币兑换
function i3k_sbean.syncExchangeCoin(id, time, isShowTop)
	local data = i3k_sbean.souvenir_coin_exchange_req.new()
	data.id = id
	data.time = time
	data.isShowTop = isShowTop
	i3k_game_send_str_cmd(data, "souvenir_coin_exchange_res")
end
function i3k_sbean.souvenir_coin_exchange_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:UseCoinChangeBagItem(req.id, req.time)
		i3k_sbean.sync_activities_comCoin(true, req.isShowTop)
	end
end
--强制兑现纪念币
function i3k_sbean.syncForveExchangeCoin(id, time, needId)
	local data = i3k_sbean.souvenir_coin_force_cash_req.new()
	data.id = id
	data.time = time
	data.needId = needId
	i3k_game_send_str_cmd(data, "souvenir_coin_force_cash_res")
end
function i3k_sbean.souvenir_coin_force_cash_res.handler(res, req)
	if res.ok > 0 then
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_PayActivity, "updateComCoinInfo", res.info)
	end
end
--保持奖励领取
function i3k_sbean.syncHoldTakeRewardComCoin(index)
	local data = i3k_sbean.souvenir_coin_hold_reward_take_req.new()
	data.index = index
	i3k_game_send_str_cmd(data, "souvenir_coin_hold_reward_take_res")
end
function i3k_sbean.souvenir_coin_hold_reward_take_res.handler(res, req)
	if res.ok > 0 then
		local items = i3k_db_commecoin_addValueNode[req.index].rewards
		g_i3k_ui_mgr:ShowGainItemInfo(items)
		i3k_sbean.sync_activities_comCoin(false, true)
		g_i3k_game_context:getSouvenirCoinInfo(req.index)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PayActivity, "isShowComCoinActRedPoint")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleEntrance, "RefreshAllItem") -- 刷新充值的红点
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19103))
	end
end
