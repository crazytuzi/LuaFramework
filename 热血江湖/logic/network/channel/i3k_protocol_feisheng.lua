------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

-- 领取飞升任务
function i3k_sbean.getRingMission(id, cb)
	local data = i3k_sbean.soaring_day_task_take_req.new()
	data.id = id
	data.cb = cb
	i3k_game_send_str_cmd(data, "soaring_day_task_take_res")
end

function i3k_sbean.soaring_day_task_take_res.handler(res, req)
	req.cb(res.ok)
end

--完成飞升环任务
function i3k_sbean.finishRingMission(id)
	local data = i3k_sbean.soaring_day_task_finish_req.new()
	data.id = id
	i3k_game_send_str_cmd(data, "soaring_day_task_finish_res")
end

function i3k_sbean.soaring_day_task_finish_res.handler(res, req)
	if res.ok > 0 then
		local info = g_i3k_game_context:getFSRTaskInfo()
		local rwds = g_i3k_db.i3k_db_get_FSR_rewards(req.id)
		g_i3k_game_context:setFeishengExp(i3k_db_ring_mission[req.id].giveExp)
		g_i3k_ui_mgr:ShowGainItemInfo(rwds)
		g_i3k_game_context:addFeishengDailyTimes()
		if info.id == req.id then
			if info.value ~= 0 then
				g_i3k_game_context:removeTaskData(TASK_CATEGORY_RING)
			end
			g_i3k_ui_mgr:RefreshUI(eUIID_BattleTask)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("完成飞升环任务失败, 错误码："..res.ok)
	end
end

--快速完成飞升环任务
function i3k_sbean.quickFinishRingMission(id)
	local data = i3k_sbean.soaring_day_task_quick_finish_req.new()
	data.id = id
	i3k_game_send_str_cmd(data, "soaring_day_task_quick_finish_res")
end

function i3k_sbean.soaring_day_task_quick_finish_res.handler(res, req)
	if res.ok > 0 then
		local QFTinfo = g_i3k_db.i3k_db_get_quick_finish_task_cfg(g_QUICK_FINISH_TASK_TYPE_RING)
		g_i3k_game_context:UseCommonItem(QFTinfo.needItemId, QFTinfo.needItemCount)
		g_i3k_game_context:addFeishengDailyTimes()
		local info = g_i3k_game_context:getFSRTaskInfo()
		local rwds = g_i3k_db.i3k_db_get_FSR_rewards(req.id)
		g_i3k_game_context:setFeishengExp(i3k_db_ring_mission[req.id].giveExp)
		g_i3k_ui_mgr:ShowGainItemInfo(rwds)
		if info.id == req.id then
			if g_i3k_game_context:getFeishengDailyTimes() >= g_i3k_game_context:getFeishengMaxRingMissionNum() then
				g_i3k_game_context:removeTaskData(TASK_CATEGORY_RING)
			end
			g_i3k_ui_mgr:RefreshUI(eUIID_BattleTask)
		end
	end
end

function i3k_sbean.soaring_day_task_next.handler(res)
	local feishengInfo = g_i3k_game_context:getFeishengInfo()
	if feishengInfo._level == -1 then
		g_i3k_game_context._beginRingMissionPush = res.id
	else
		g_i3k_game_context:setFSRTaskInfo(res.id, 0, 1)
	end
end
