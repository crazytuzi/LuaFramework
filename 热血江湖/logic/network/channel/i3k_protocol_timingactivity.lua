------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")
--定时活动发送兑换
function i3k_sbean.activity_exchange_req(exchange)
	local data = i3k_sbean.regular_task_exchange_req.new()
	data.id = exchange.id
	data.count = exchange.count
	--data.exchangeId = exchange.get_goods_id
	--data.exchangeCnt = exchange.get_goods_count
	local cfginfo =  g_i3k_game_context:getTimingActivityinfo()
	local cfgExchange = i3k_db_timing_activity_exchange[cfginfo.id][data.id]
	local flag = true
	for k, v  in pairs(cfgExchange.exchangeItems) do
		if not g_i3k_db.i3k_db_prop_gender_qualify(v.id) then
			flag = false
		end
	end
	if not flag then
		local callfunction = function(ok)
			if ok then
				i3k_game_send_str_cmd(data, i3k_sbean.regular_task_exchange_res.getName())
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(50068), callfunction)
		return
	end
	i3k_game_send_str_cmd(data, i3k_sbean.regular_task_exchange_res.getName())
end
--定时活动兑换回馈
function i3k_sbean.regular_task_exchange_res.handler(bean, req)
	if bean.ok > 0 then 
		local cfginfo =  g_i3k_game_context:getTimingActivityinfo()
		local cfgExchange = i3k_db_timing_activity_exchange[cfginfo.id][req.id]
		local needItems = cfgExchange.needItems
		for k , v  in pairs(needItems) do
			g_i3k_game_context:UseCommonItem(v.id,  v.count, AT_ITEM_EXCHANGE)
		end			
		local showItem = { }
		for k, v  in pairs(cfgExchange.exchangeItems) do
			local item = { id = v.id, count = v.count  }
			table.insert(showItem, item)
		end
		g_i3k_game_context:setExchange(req.id)
		g_i3k_ui_mgr:ShowGainItemInfo(showItem)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_TimingActivity, "updateActivityExchange", req.id)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_TimingActivity, "refreshRed")
	else
		g_i3k_ui_mgr:PopupTipMessage("兑换失败")
	end
end
-- 领取奖励
function i3k_sbean.activityreward(id)
	local data = i3k_sbean.regular_task_score_reward_take_req.new()
	data.id = id
	i3k_game_send_str_cmd(data, "regular_task_score_reward_take_res")
end
--领取返回
function i3k_sbean.regular_task_score_reward_take_res.handler(bean,req)
	if bean.ok > 0 then 
		local rewardsTab = {}
		for k, v in pairs(bean.drops) do
		local t = {id = k,count = v}
			table.insert( rewardsTab, t )
		end
		g_i3k_ui_mgr:ShowGainItemInfo(rewardsTab)
		g_i3k_game_context:setTimingActivityRewards(req.id)
		g_i3k_ui_mgr:RefreshUI(eUIID_TimingActivity)
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_TimingActivity, "setSchedule", req.id)
	elseif bean.ok == 0 then 
		g_i3k_ui_mgr:PopupTipMessage("系统错误,领取失败")
	elseif bean.ok == -1 then 
		g_i3k_ui_mgr:PopupTipMessage("领取条件未达到")
	elseif bean.ok == -2 then 
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足,活跃奖励领取失败")
	end
end

--使用定时活动道具
function i3k_sbean.bag_use_regular_item_activity(id, count)
	local data = i3k_sbean.bag_use_regular_item_req.new()
	data.id = id
	data.count = count
	i3k_game_send_str_cmd(data, "bag_use_regular_item_res")
end
--使用返回
function i3k_sbean.bag_use_regular_item_res.handler(bean,req)
	if bean.ok > 0 then
		g_i3k_game_context:SetUseItemData(req.id, req.count,nil, AT_USE_ITEM_DIAMOND_BAG)
		g_i3k_game_context:setTimingActivityTotalScore(req.id,req.count)
		g_i3k_ui_mgr:RefreshUI(eUIID_TimingActivity)
	else
		g_i3k_ui_mgr:PopupTipMessage("使用失败")
	end
end

--定时活动
function i3k_sbean.open_timing_activity_req(callBack)
	local data = i3k_sbean.regular_task_open_req.new()
	data.callBack = callBack
	i3k_game_send_str_cmd(data, "regular_task_open_res")
end

--同步
function i3k_sbean.regular_task_open_res.handler(bean, req)
	if bean.data.id > 0 then	
		g_i3k_game_context:setTimingActivityinfo(bean.data)
		if req.callBack then
			req.callBack()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("不在活动时间内")
	end
end

--定时活动信息
function i3k_sbean.regular_task_sync.handler(bean)
	g_i3k_game_context:setTimingActivityinfo(bean.data)
end

--诗词活动
function i3k_sbean.regular_game_notice_task_finished(taskType, times)
	local data = i3k_sbean.regular_task_notice.new()
	data.taskType = taskType
	data.cnt = times
	i3k_game_send_str_cmd(data)
end
function i3k_sbean.regular_pray_open(cb)
	local bean = i3k_sbean.regular_pray_open_req.new()
	bean.cb = cb
	i3k_game_send_str_cmd(bean, "regular_pray_open_res")
end
function i3k_sbean.regular_pray_open_res.handler(bean, req)
	if bean.info then
		g_i3k_game_context:setTimingActivityPrayInfo(bean.info)
		if req.cb then
			req.cb(bean.info)
		end
	end
end
function i3k_sbean.regular_pray(str)
	local bean = i3k_sbean.regular_pray_req.new()
	bean.content = str
	i3k_game_send_str_cmd(bean, "regular_pray_res")
end
function i3k_sbean.regular_pray_res.handler(bean, req)
	if bean.ok > 0 then
		-- req.content
		g_i3k_game_context:setTimingActivityPrayTxt(req.content)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_TimingActivity, "ModifySelfContent", req.content)
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivityPray)
		-- i3k_sbean.regular_pray_open(function()
		-- 	g_i3k_ui_mgr:InvokeUIFunction(eUIID_TimingActivity, "updateRightBtnState", 3)
  --   	end)
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17191))
	elseif bean.ok == -404 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1566))
	end
end
function i3k_sbean.regular_pray_take_reward()
	local bean = i3k_sbean.regular_pray_take_reward_req.new()
	i3k_game_send_str_cmd(bean, "regular_pray_take_reward_res")
end
function i3k_sbean.regular_pray_take_reward_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:updateTimingActivityTakeAwardTime()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_TimingActivity, "updateReturnWish")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_TimingActivity, "refreshRed")
		g_i3k_ui_mgr:OpenUI(eUIID_TimingActivityTakeReward)
		g_i3k_ui_mgr:RefreshUI(eUIID_TimingActivityTakeReward, bean.fixDrops, bean.randomDrops)
	end
end
