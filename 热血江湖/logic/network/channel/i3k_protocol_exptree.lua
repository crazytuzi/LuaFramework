------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")
--------------------------------------------------------
--登录同步
function i3k_sbean.role_exp_tree_times.handler(bean, res)
	if bean.info then
		g_i3k_game_context:setWatchingTimes(bean.info.watchingTimes)
		g_i3k_game_context:setWateringTimes(bean.info.wateringTimes)
		g_i3k_game_context:setHarvestTimes(bean.info.harvestTimes)
	end
end
-- 进入地图同步经验果树等级
function i3k_sbean.exp_tree_enter_sync.handler(bean)
	g_i3k_game_context:setExpTreeLevel(bean.level)
	g_i3k_game_context:UpdateExpTreeState()
end
--更新状态
function i3k_sbean.request_exp_tree_sync_req(callback)
	local syncTemp = i3k_sbean.exp_tree_sync_req.new()
	syncTemp.callback = callback
	i3k_game_send_str_cmd(syncTemp, "exp_tree_sync_res")
end

function i3k_sbean.exp_tree_sync_res.handler(bean, req)
	local info = bean.info;
	if info then
		g_i3k_game_context:setExpTreeInfo(info)
		g_i3k_game_context:UpdateExpTreeState()
		if req.callback then
			req.callback()
		else
			g_i3k_ui_mgr:RefreshUI(eUIID_ExpTreeWater);
			g_i3k_ui_mgr:RefreshUI(eUIID_ExpTreeFlower);
		end
	end
end
--摇一摇
function i3k_sbean.request_exp_tree_get_drop_req(callback)
	local syncTemp = i3k_sbean.exp_tree_get_drop_req.new()
	syncTemp.callback = callback
	i3k_game_send_str_cmd(syncTemp, "exp_tree_get_drop_res")
end

function i3k_sbean.exp_tree_get_drop_res.handler(bean, req)
	if bean.ok == 1 and bean.drop and req.callback then
		req.callback(bean.drop)
	end
end
--浇水
function i3k_sbean.request_exp_tree_watering_req(callback)
	local syncTemp = i3k_sbean.exp_tree_watering_req.new()
	syncTemp.callback = callback
	i3k_game_send_str_cmd(syncTemp, "exp_tree_watering_res")
end

function i3k_sbean.exp_tree_watering_res.handler(bean, req)
	if bean.ok == 1 then
		req.callback()
	else
		i3k_sbean.request_exp_tree_sync_req()
	end
end
--丰收
function i3k_sbean.request_exp_tree_mature_reward_req(callback)
	local syncTemp = i3k_sbean.exp_tree_mature_reward_req.new()
	syncTemp.callback = callback
	i3k_game_send_str_cmd(syncTemp, "exp_tree_mature_reward_res")
end

function i3k_sbean.exp_tree_mature_reward_res.handler(bean, req)
	if bean.ok == 1 then
		req.callback()
	else
		i3k_sbean.request_exp_tree_sync_req()
	end
end
