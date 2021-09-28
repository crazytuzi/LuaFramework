------------------------------------------------------
module(..., package.seeall)

local require = require
require("i3k_sbean")

---------------------------------渠道充值----------------------------------------------
function i3k_sbean.sync_channel_pay(fun, openType)
	local pay_sync = i3k_sbean.pay_sync_req.new()
	pay_sync.fun = fun
	pay_sync.openType = openType
	i3k_game_send_str_cmd(pay_sync, i3k_sbean.pay_sync_res.getName())
end

function i3k_sbean.pay_sync_res.handler(bean, req)
	if bean.info then
		g_i3k_ui_mgr:OpenUI(eUIID_ChannelPay)
		g_i3k_ui_mgr:RefreshUI(eUIID_ChannelPay, bean.info, req.fun, req.openType)
	end
end

function i3k_sbean.goto_channel_pay(id, payLevelCfg, callback)
	local buy = i3k_sbean.pay_asgod_req.new()
	buy.level = payLevelCfg.level
	buy.id = id
	buy.payLevelCfg = payLevelCfg
	buy.callback = callback
	i3k_game_send_str_cmd(buy, i3k_sbean.pay_asgod_res.getName())
end

function i3k_sbean.pay_asgod_res.handler(bean, req)
	if bean.ok == 1 then
		if req.callback then
			req.callback()
		end
		-- if req.level == 0 then			--月卡
		-- 	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(313))
		-- else
		-- 	g_i3k_ui_mgr:PopupTipMessage(string.format(i3k_get_string(311), req.gain))
		-- end
		-- g_i3k_ui_mgr:InvokeUIFunction(eUIID_ChannelPay, "updateAfterBuy", req.level)
	elseif bean.ok == -1 then
		i3k_game_role_pay_info(req.id, req.payLevelCfg)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(314))
	end
end

function i3k_sbean.role_pay_notice.handler(bean)
	if bean.payLevel == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(313))
	else
		if bean.payLevel == g_DISCOUNT_MONTH_CARD_ID then  --折扣月卡
			i3k_sbean.sync_special_card(MONTH_CARD)
		end
		if bean.addDiamond > 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(311, bean.addDiamond))
		end
		if bean.addDragonCoin > 0 then
			--g_i3k_ui_mgr:InvokeUIFunction(eUIID_PayActivity, "setMyDragonCoin")
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1161, bean.addDragonCoin))
		end
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_PayActivity, "handleDirectPuschaseCallback")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "handleDirectPuschaseCallback")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_ChannelPay, "updateAfterBuy", bean.payLevel)
end

function i3k_sbean.user_vip_sync.handler(bean)
	g_i3k_game_context:SetVipLevel(bean.vipLvl)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_ChannelPay, "setTopInfo", bean.vipLvl, bean.points)
	g_i3k_game_context:SetPayRedStateIfPay(bean.vipLvl)
end
---------------------------------渠道充值end----------------------------------------------

---------------------------------VIP系统-----------------------------------------------
function i3k_sbean.take_vip_reward(level, gifts, needDiamond)
	local vip_take = i3k_sbean.vip_take_req.new()
	vip_take.level = level
	vip_take.gifts = gifts
	vip_take.needDiamond = needDiamond
	i3k_game_send_str_cmd(vip_take, i3k_sbean.vip_take_res.getName())
end

function i3k_sbean.vip_take_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_ui_mgr:ShowGainItemInfo(req.gifts)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_VipSystem, "takeRewardHandle", req.level)
		g_i3k_game_context:SetPayRedStateIfReward(req.level)
		g_i3k_game_context:UseCommonItem(-g_BASE_ITEM_DIAMOND, req.needDiamond, AT_TAKE_VIP_REWARD)
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

---------------------------------VIP系统end----------------------------------------------
