------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")
--------------------------------------------------------
-- 玩家回归信息同步
function i3k_sbean.request_role_back_sync_req()
	local data = i3k_sbean.role_back_sync_req.new()
	i3k_game_send_str_cmd(data, "role_back_sync_res")
end

function i3k_sbean.role_back_sync_res.handler(bean,req)
	--self.loginDay:		int32	
	--self.roleType:		int32	
	--self.dayCostNum:		int32	
	--self.dayLoginReward:		int32	
	--self.daySchduleReward:		int32	
	--self.dayPayReward:		int32	
	--self.backNumReward:		set[int32]	
	--self.activityTaskReward:		set[int32]
	g_i3k_ui_mgr:OpenUI(eUIID_CallBack)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_CallBack,"refreshTab1",bean.info)
end

-- 玩家世界数量同步
function i3k_sbean.request_role_back_world_num_sync_req()
	local data = i3k_sbean.role_back_world_num_sync_req.new()
	i3k_game_send_str_cmd(data, "role_back_world_num_sync_res")
end

function i3k_sbean.role_back_world_num_sync_res.handler(bean,req)
	--self.roleNum:		int32	
	--self.taskNum:		int32
	--self.roleNumReward:		set[int32]	
	--self.taskNumReward:		set[int32]	
	g_i3k_ui_mgr:OpenUI(eUIID_CallBack)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_CallBack,"refreshTab2",bean)
end

-- 玩家充值奖励领取
function i3k_sbean.request_role_back_pay_gift_take_req(callback)
	local data = i3k_sbean.role_back_pay_gift_take_req.new()
	data.callback = callback
	i3k_game_send_str_cmd(data, "role_back_pay_gift_take_res")
end

function i3k_sbean.role_back_pay_gift_take_res.handler(bean,req)
	if bean.ok == 1 then
		req.callback()
		i3k_sbean.request_role_back_sync_req()
	else
		g_i3k_ui_mgr:PopupTipMessage("操作失败")
	end
end

-- 玩家活跃奖励领取
function i3k_sbean.request_role_back_schdule_gift_take_req(callback)
	local data = i3k_sbean.role_back_schdule_gift_take_req.new()
	data.callback = callback
	i3k_game_send_str_cmd(data, "role_back_schdule_gift_take_res")
end

function i3k_sbean.role_back_schdule_gift_take_res.handler(bean,req)
	if bean.ok == 1 then
		i3k_sbean.request_role_back_sync_req()
		req.callback()
	else
		g_i3k_ui_mgr:PopupTipMessage("操作失败")
	end
end

-- 玩家每日奖励领取
function i3k_sbean.request_role_back_day_gift_take_req(callback)
	local data = i3k_sbean.role_back_day_gift_take_req.new()
	data.callback = callback
	i3k_game_send_str_cmd(data, "role_back_day_gift_take_res")
end

function i3k_sbean.role_back_day_gift_take_res.handler(bean,req)
	if bean.ok == 1 then
		i3k_sbean.request_role_back_sync_req()
		req.callback()
	else
		g_i3k_ui_mgr:PopupTipMessage("操作失败")
	end
end

-- 玩家回归人数奖励领取
function i3k_sbean.request_role_back_back_num_gift_take_req(roleNum,callback)
	local data = i3k_sbean.role_back_back_num_gift_take_req.new()
	data.roleNum = roleNum
	data.callback = callback
	i3k_game_send_str_cmd(data, "role_back_back_num_gift_take_res")
end

function i3k_sbean.role_back_back_num_gift_take_res.handler(bean,req)
	if bean.ok == 1 then
		i3k_sbean.request_role_back_world_num_sync_req()
		req.callback()
	else
		g_i3k_ui_mgr:PopupTipMessage("操作失败")
	end
end

-- 玩家每日任务数量奖励领取
function i3k_sbean.request_role_back_task_num_gift_take_req(taskNum,callback)
	local data = i3k_sbean.role_back_task_num_gift_take_req.new()
	data.taskNum = taskNum
	data.callback = callback
	i3k_game_send_str_cmd(data, "role_back_task_num_gift_take_res")
end

function i3k_sbean.role_back_task_num_gift_take_res.handler(bean,req)
	if bean.ok == 1 then
		i3k_sbean.request_role_back_world_num_sync_req()
		req.callback()
	else
		g_i3k_ui_mgr:PopupTipMessage("操作失败")
	end
end
function i3k_sbean.request_role_back_pay_sync_req()
	local data = i3k_sbean.role_back_pay_sync_req.new()
	i3k_game_send_str_cmd(data, "role_back_pay_sync_res")
end
function i3k_sbean.role_back_pay_sync_res.handler(res, req)
	g_i3k_ui_mgr:OpenUI(eUIID_CallBack)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_CallBack, "refreshTab3", res)
end
function i3k_sbean.request_role_back_pay_take_reward_req(id)
	local data = i3k_sbean.role_back_pay_take_reward_req.new()
	data.id = id
	i3k_game_send_str_cmd(data, "role_back_pay_take_reward_res")
end
function i3k_sbean.role_back_pay_take_reward_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:ShowGainItemInfo(i3k_db_call_back_pay_gift[req.id].items)
		i3k_sbean.request_role_back_pay_sync_req()
	end
end
