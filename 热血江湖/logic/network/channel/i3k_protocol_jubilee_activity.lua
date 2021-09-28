------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

----------------------------------------------------

-- 周年活动登陆同步
function i3k_sbean.jubilee_activity_login_sync.handler(bean)
	g_i3k_game_context:SetJubileeInfo(bean.info)
end

-- 周年活动进度同步
function i3k_sbean.jubilee_activity_process_sync()
	local data = i3k_sbean.jubilee_activity_process_sync_req.new()
	i3k_game_send_str_cmd(data, "jubilee_activity_process_sync_res")
end

function i3k_sbean.jubilee_activity_process_sync_res.handler(bean, req)
	g_i3k_game_context:SetJubileeStep1Activity(bean.step1Activity)
	g_i3k_game_context:SetJubileeStep2Info(bean.info)
	g_i3k_ui_mgr:OpenUI(eUIID_Jubilee)
	g_i3k_ui_mgr:RefreshUI(eUIID_Jubilee, bean.info)
end

-- 周年活动步骤一奖励
function i3k_sbean.jubilee_activity_step1_reward()
	local data = i3k_sbean.jubilee_activity_step1_reward_req.new()
	i3k_game_send_str_cmd(data, "jubilee_activity_step1_reward_res")
end

function i3k_sbean.jubilee_activity_step1_reward_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_JubileeStageOneAward)
		local awards = i3k_db_jubilee_base.stage1.awards
		g_i3k_ui_mgr:ShowGainItemInfoByCfg_safe(awards)
		g_i3k_game_context:SetJubileeStep1Reward(1)
	end
end

-- 周年活动步骤一活跃度达标推送
function i3k_sbean.jubilee_activity_point_push.handler(bean)
	g_i3k_game_context:SetJubileeStep1Activity(i3k_db_jubilee_base.stage1.needActivity)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Jubilee, "loadRedPoint")
	g_i3k_game_context:checkJubileeActivityState()
end

-- 周年活动步骤二奖励
function i3k_sbean.jubilee_activity_step2_reward(taskType)
	local data = i3k_sbean.jubilee_activity_step2_reward_req.new()
	data.type = taskType
	i3k_game_send_str_cmd(data, "jubilee_activity_step2_reward_res")
end

function i3k_sbean.jubilee_activity_step2_reward_res.handler(bean, req)
	if bean.ok > 0 then
		local awardsCfg = i3k_db_jubilee_base.stage2.taskAwards
		g_i3k_ui_mgr:ShowGainItemInfoByCfg_safe(awardsCfg[req.type])
		g_i3k_game_context:SetJubileeStep2TaskReward(req.type)
		if req.type == g_JUBILEE_TASK_FINISH then -- 设置任务为领取奖励状态
			g_i3k_ui_mgr:CloseUI(eUIID_JubileeStageTwoAward)
			g_i3k_ui_mgr:CloseUI(eUIID_Jubilee)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Jubilee, "loadRedPoint")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Jubilee, "loadStage2Widgets")
		local canReceive = false
		local info = g_i3k_game_context:GetJubileeStep2Info()
		local cfg = i3k_db_jubilee_base.stage2
		for i = 1, 3 do
			local activity = (info.taskNum[i] or 0) + (info.autoAddTaskNum[i] or 0)
			local percent = activity / cfg["task"..i.."Total"] * 100
			local isReceive = g_i3k_game_context:GetJubileeStep2TaskReward(i)
			if percent >= 100 and not isReceive then
				canReceive = true
				break
			end
		end
		g_i3k_game_context:SetJubileeStep2BoxState(canReceive)
		g_i3k_game_context:checkJubileeActivityState()
	end
end

-- 周年活动步骤二任务组选择
function i3k_sbean.jubilee_activity_step2_group_choose(taskType)
	local data = i3k_sbean.jubilee_activity_step2_group_choose_req.new()
	data.group = taskType
	i3k_game_send_str_cmd(data, "jubilee_activity_step2_group_choose_res")
end

function i3k_sbean.jubilee_activity_step2_group_choose_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_Jubilee)
		g_i3k_ui_mgr:CloseUI(eUIID_JubileeStageTwoAward)
		g_i3k_game_context:SetJubileeStep2TaskID(bean.ok) -- bean.ok 服务器随机出的任务ID
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateTaskInfo")
	end
end

-- 周年活动步骤二任务接取
function i3k_sbean.jubilee_activity_step2_task_take(taskID)
	local data = i3k_sbean.jubilee_activity_step2_task_take_req.new()
	data.id = taskID
	i3k_game_send_str_cmd(data, "jubilee_activity_step2_task_take_res")
end

function i3k_sbean.jubilee_activity_step2_task_take_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:SetJubileeStep2TaskState(g_TASK_STATE_ACESS)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateJubileeTask", false)
	end
end

-- 周年活动步骤二任务完成
function i3k_sbean.jubilee_activity_step2_task_finish(callback)
	local data = i3k_sbean.jubilee_activity_step2_task_finish_req.new()
	data.callback = callback
	i3k_game_send_str_cmd(data, "jubilee_activity_step2_task_finish_res")
end

function i3k_sbean.jubilee_activity_step2_task_finish_res.handler(bean, req)
	if bean.ok > 0 then
		if req.callback then
			req.callback()
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"removeJubileeTaskItem")
		g_i3k_game_context:removeTaskData(TASK_CATEGORY_JUBILEE)
		g_i3k_game_context:SetJubileeStep2TaskState(g_TASK_STATE_REWAEDED)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateTaskInfo")
	end
end

-- 周年活动步骤三矿物传送
function i3k_sbean.jubilee_activity_step3_teleport()
	local data = i3k_sbean.jubilee_activity_step3_teleport_req.new()
	i3k_game_send_str_cmd(data, "jubilee_activity_step3_teleport_res")
end

function i3k_sbean.jubilee_activity_step3_teleport_res.handler(bean, req)
	if bean.ok > 0 then
		if g_i3k_game_context:IsTransNeedItem() then
			local needId = i3k_db_common.activity.transNeedItemId
			g_i3k_game_context:UseTrans(needId, 1, AT_THUMB_TACK)
		end
	end
end

-- 周年活动步骤三矿物采集
function i3k_sbean.jubilee_activity_step3_take()
	local data = i3k_sbean.jubilee_activity_step3_take_req.new()
	i3k_game_send_str_cmd(data, "jubilee_activity_step3_take_res")
end

function i3k_sbean.jubilee_activity_step3_take_res.handler(bean, req)
	if bean.ok > 0 then
		local hero = i3k_game_get_player_hero()
		hero:SetDigStatus(0)
		g_i3k_game_context:AddJubileeStep3MineralTimes()
		--采矿矿奖励弹框
		g_i3k_ui_mgr:ShowGainItemInfo(bean.reward)
		if g_i3k_game_context:GetubileeStep3MineralTimes() == i3k_db_jubilee_base.stage3.dayLimitTimes then
			g_i3k_game_context:checkJubileeActivityState()
		end
	end
end
-- 阶段二宝箱红点
function i3k_sbean.jubilee_step2_point.handler(bean)
	g_i3k_game_context:SetJubileeStep2BoxState(true)
	g_i3k_game_context:checkJubileeActivityState()
end
