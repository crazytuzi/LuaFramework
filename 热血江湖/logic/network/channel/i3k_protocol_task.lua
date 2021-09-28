------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/network/channel/i3k_channel");

-----------------------------------

--使用道具协议
function i3k_sbean.task_useitem_res.handler(bean,res)
	local is_ok = bean.ok
	if is_ok == 1 then
		if res.taskCat == TASK_CATEGORY_MAIN then
			local mId = g_i3k_game_context:getMainTaskIdAndVlaue()
			g_i3k_game_context:setMainTaskIdAndValue(mId,1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateMainTask",mId, 1, true)
		elseif res.taskCat == TASK_CATEGORY_LIFE then
			local taskId, value = g_i3k_game_context:getPetLifeTskIdAndValueById(g_i3k_game_context:GetLifeTaskRecorkPetID())
			g_i3k_game_context:setOnePetLifeTask(g_i3k_game_context:GetLifeTaskRecorkPetID(),taskId,1,0)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenshiBattle,"onShowData",g_i3k_game_context:GetLifeTaskRecorkPetID())
		elseif res.taskCat == TASK_CATEGORY_OUT_CAST then 
			local taskId, value = g_i3k_game_context:getOutCastTskIdAndValueById()
			local info = g_i3k_game_context:getOutCastInfo()
			info.curTaskValue = 1 
			info.curTaskReward = 0
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_OutCastBattle,"onShowData")
		elseif res.taskCat == TASK_CATEGORY_SUBLINE then
			g_i3k_game_context:UpdateSubLineTaskValue(g_TASK_USE_ITEM_AT_POINT,res.ItemId)
		elseif res.taskCat == i3k_get_MrgTaskCategory() then
			--local data = g_i3k_game_context:GetMarriageTaskData()
			g_i3k_game_context:AddMarriageTaskValue(1)
			--g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateMrgTask",data.id, data.groupID, 1,true)
		elseif res.taskCat == TASK_CATEGORY_EPIC then
			g_i3k_game_context:addCurrEpicTaskValue(1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateEpicTask", true)
		elseif res.taskCat == TASK_CATEGORY_ADVENTURE then
			g_i3k_game_context:setAdventureTask(1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateAdventureTask", true)
		elseif res.taskCat == TASK_CATEGORY_CHESS then
			local data = g_i3k_game_context:getChessTask()
			g_i3k_game_context:updateChessTaskValue(g_TASK_USE_ITEM_AT_POINT, i3k_db_chess_task[data.curTaskID].args1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateChessTask", true)
		elseif res.taskCat == TASK_CATEGORY_FESTIVAL then
			g_i3k_game_context:updateFestivalTaskValue(g_TASK_USE_ITEM_AT_POINT, res.ItemId)
		elseif res.taskCat == TASK_CATEGORY_JUBILEE then
			g_i3k_game_context:updateJubileeTaskValue(g_TASK_USE_ITEM_AT_POINT, res.ItemId)
		elseif res.taskCat == TASK_CATEGORY_BIOGRAPHY then
			g_i3k_game_context:updateBiographyTaskValue(g_TASK_USE_ITEM_AT_POINT, res.ItemId)
		end
	end
end

--提交佣兵任务道具
function i3k_sbean.pettask_submititem_res.handler(res, req)
	local data = i3k_sbean.ptask_reward_req.new()
	data.petId = req.petId
	data.ItemId = req.ItemId
	data.ItemCount = req.ItemCount
	data.taskId = req.taskId
	i3k_game_send_str_cmd(data,i3k_sbean.ptask_reward_res.getName())
	--刷新背包道具
	g_i3k_game_context:UseCommonItem(data.ItemId,data.ItemCount,AT_TEST_LOG_TASK)
end

--提交道具协议
function i3k_sbean.task_submititem_res.handler(res,req)
	local is_ok = res.ok
	if is_ok == 1 then
		local taskCat = req.taskCat
		local ItemId = req.ItemId
		local ItemCount = req.ItemCount
		local taskID = req.taskId
		local petID = req.petId
		g_i3k_game_context:UseCommonItem(ItemId,ItemCount,AT_TEST_LOG_TASK)
		if taskCat == TASK_CATEGORY_MAIN then
			local mId = g_i3k_game_context:getMainTaskIdAndVlaue()
			g_i3k_game_context:setMainTaskIdAndValue(mId,1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateMainTask",mId, 1, true)
		elseif taskCat == TASK_CATEGORY_WEAPON then
			local id,loop = g_i3k_game_context:getWeaponTaskIdAndLoopType()
			local data = i3k_sbean.wtask_reward_req.new()
			data.taskId = id
			i3k_game_send_str_cmd(data,i3k_sbean.wtask_reward_res.getName())
		elseif taskCat == TASK_CATEGORY_PET then
			local data = i3k_sbean.ptask_reward_req.new()
			data.petId = petID
			data.taskId = taskID
			i3k_game_send_str_cmd(data,i3k_sbean.ptask_reward_res.getName())
			--刷新背包道具
		elseif taskCat == TASK_CATEGORY_SECT then
			local data = i3k_sbean.sect_task_finish_req.new()
			data.ownerId = roleID
			data.sid = guid
			data.taskID = taskID
			i3k_game_send_str_cmd(data,i3k_sbean.sect_task_finish_res.getName())
		elseif taskCat == TASK_CATEGORY_SUBLINE then
			local data = g_i3k_game_context:getSubLineIdAndValueBytype(req.groupID)
			g_i3k_game_context:setSubTaskOneGroupData(req.groupID,data.id,1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateSublineTask", req.groupID, data.id, true)
		elseif taskCat == TASK_CATEGORY_LIFE then
			local data = i3k_sbean.petlifetask_reward_req.new()
			data.petId = petId
			data.taskId = taskId
			i3k_game_send_str_cmd(data,i3k_sbean.petlifetask_reward_res.getName())
		elseif res.taskCat == TASK_CATEGORY_OUT_CAST then 
			
		elseif taskCat == TASK_CATEGORY_MRG then
		elseif taskCat == TASK_CATEGORY_MRG_LOOP then

		elseif taskCat == TASK_CATEGORY_EPIC then
			g_i3k_game_context:addCurrEpicTaskValue(1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateEpicTask", true)
		elseif taskCat == TASK_CATEGORY_DRAGON_HOLE then
			g_i3k_game_context:ChangeAcceptDragonTaskValue(req.groupID, ItemCount)
		elseif taskCat == TASK_CATEGORY_ADVENTURE then
			g_i3k_game_context:setAdventureTask(1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateAdventureTask", true)
		elseif taskCat == TASK_CATEGORY_FCBS then
			g_i3k_game_context:setFactionBusinessTask(nil, 1, nil)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateFCBSTask", true)
		elseif taskCat == TASK_CATEGORY_FESTIVAL then
			local groupId, taskId = g_i3k_db.i3k_db_get_festival_task_real_id(req.groupID)
			g_i3k_game_context:setFestivalTaskValue(groupId, 1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateFestivalTask", groupId, taskId, true)
		elseif taskCat == TASK_CATEGORY_JUBILEE then
			g_i3k_game_context:SetJubileeStep2TaskValue(1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateJubileeTask", true)
		elseif taskCat == TASK_CATEGORY_SWORDSMAN then
			g_i3k_game_context:setSwordsmanCircleTaskValue(1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "udpateSwordsmanTask", true)
		end
	end
end

--帮派npc对话
function i3k_sbean.task_dialog_res.handler(res,req)
	local is_ok = res.ok
	if is_ok == 1 then
		if req.__callback then
			req.__callback()
		end
		local taskCat = req.taskCat

		if taskCat == TASK_CATEGORY_MAIN then
			local taskID  = g_i3k_game_context:getMainTaskIdAndVlaue()
			g_i3k_game_context:setMainTaskIdAndValue(taskID, 1, 1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateMainTask",taskID, 1, true)
		elseif taskCat == TASK_CATEGORY_SUBLINE then
			g_i3k_game_context:setSubTaskOneGroupData(req.petId, req.taskID, 1, 1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateSublineTask", req.petId, req.taskID, true)
		elseif taskCat == TASK_CATEGORY_WEAPON then

		elseif taskCat == TASK_CATEGORY_PET then
		elseif taskCat == TASK_CATEGORY_LIFE then
			local taskId, value = g_i3k_game_context:getPetLifeTskIdAndValueById(req.petId)
			g_i3k_game_context:setOnePetLifeTask(req.petId,taskId,1,0)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenshiBattle,"onShowData",req.petId, true, true)
		elseif taskCat == TASK_CATEGORY_OUT_CAST then 
			local info = g_i3k_game_context:getOutCastInfo()
			info.curTaskValue = 1 
			info.curTaskReward = 0
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_OutCastBattle,"onShowData")
		elseif taskCat == TASK_CATEGORY_SECT then

			local roleID = g_i3k_game_context:getFactionTaskRoleId()
			local guid = g_i3k_game_context:getFactionTaskGuid()
			local taskID,value,receiveTime,roleName = g_i3k_game_context:getFactionTaskIdValueTime()
			local my_id = g_i3k_game_context:GetRoleId()
			value = 1

			g_i3k_game_context:setFactionCurrentTask(roleID,guid,value,taskID,roleName,receiveTime)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateFactionTask",guid, taskID, value,roleID,receiveTime,my_id, true)
		elseif taskCat == i3k_get_MrgTaskCategory() then
			local data = g_i3k_game_context:GetMarriageTaskData()
			g_i3k_game_context:AddMarriageTaskValue(1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateMrgTask",data.id, data.groupID, 1,true)
		elseif taskCat == TASK_CATEGORY_EPIC then
			g_i3k_game_context:addCurrEpicTaskValue(1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateEpicTask", true)
		elseif taskCat == TASK_CATEGORY_DRAGON_HOLE then
			local task = i3k_game_context:GetAcceptDragonHoleTask()
			for _, v in ipairs(task) do
				local cfg = g_i3k_db.i3k_db_get_dragon_task_cfg(v.id)
				if cfg.type == g_TASK_NEW_NPC_DIALOGUE and cfg.arg1 == req.npcId and cfg.arg2 == req.dialogId then
					g_i3k_game_context:ChangeAcceptDragonTaskValue(v.id, cfg.arg2)
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateDragonHoleTask", true, v.id)
				end
			end
		elseif taskCat == TASK_CATEGORY_ADVENTURE then
			g_i3k_game_context:setAdventureTask(1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateAdventureTask", true)
		elseif taskCat == TASK_CATEGORY_FCBS then
			local data = g_i3k_game_context:getFactionBusinessTask()
			g_i3k_game_context:UpdateFCBSTaskValue(g_TASK_NEW_NPC_DIALOGUE, i3k_db_factionBusiness_task[data.id].arg1)
		elseif taskCat == TASK_CATEGORY_CHESS then
			local data = g_i3k_game_context:getChessTask()
			g_i3k_game_context:updateChessTaskValue(g_TASK_NEW_NPC_DIALOGUE, i3k_db_chess_task[data.curTaskID].arg1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateChessTask", true)
		elseif taskCat == TASK_CATEGORY_POWER_REP then
			local tasks = g_i3k_game_context:getAllPowerRepTasks()
			for k, v in pairs(tasks) do
				local taskCfg = g_i3k_db.i3k_db_power_rep_get_taskCfg_by_hash(k)
				if taskCfg.taskConditionType == g_TASK_NEW_NPC_DIALOGUE and taskCfg.args[1] == req.npcId and taskCfg.args[2] == req.dialogId then
					g_i3k_game_context:updatePowerRepTaskValue(g_TASK_NEW_NPC_DIALOGUE, taskCfg.args[1])
				end
			end
		elseif taskCat == TASK_CATEGORY_JUBILEE then
			g_i3k_game_context:SetJubileeStep2TaskValue(1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateJubileeTask", true)
		elseif taskCat == TASK_CATEGORY_SWORDSMAN then
			g_i3k_game_context:updateSwordsmanTaskValue(g_TASK_NEW_NPC_DIALOGUE, i3k_db_swordsman_circle_tasks[req.taskID].arg1)
		elseif taskCat == TASK_CATEGORY_GLOBALWORLD then --赏金任务
			local data = g_i3k_game_context:GetGlobalWorldTaskDataCfgByNPCID(req.npcId)
			g_i3k_game_context:SetGlobalWorldTaskValue(data.id, 1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateGlobalWorldTask")
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_GlobalWorldMapTask,"refresh")
		elseif taskCat == TASK_CATEGORY_BIOGRAPHY then
			local careerId = g_i3k_game_context:getCurBiographyCareerId()
			g_i3k_game_context:updateBiographyTaskValue(g_TASK_NEW_NPC_DIALOGUE, i3k_db_wzClassLand_task[careerId][req.taskID].arg1)
			g_i3k_game_context:OpenFinishTaskDialogue(i3k_db_wzClassLand_task[careerId][req.taskID], TASK_CATEGORY_BIOGRAPHY)
		end

	end
end
-- 任务护送NPC协议
function i3k_sbean.task_conveynpc_res.handler(bean,req)
	local ok = bean.ok
	if ok == 1 then
		if req.taskCat == TASK_CATEGORY_MAIN then
			local taskID  = g_i3k_game_context:getMainTaskIdAndVlaue()
			g_i3k_game_context:setMainTaskIdAndValue(taskID,1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateMainTask",taskID, 1, true)
		elseif req.taskCat == i3k_get_MrgTaskCategory() then
			local data = g_i3k_game_context:GetMarriageTaskData()
			g_i3k_game_context:AddMarriageTaskValue(1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateMrgTask",data.id, data.groupID, 1,true)
		elseif req.taskCat == TASK_CATEGORY_EPIC then
			g_i3k_game_context:addCurrEpicTaskValue(1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateEpicTask", true)
		elseif req.taskCat == TASK_CATEGORY_ADVENTURE then
			g_i3k_game_context:setAdventureTask(1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateAdventureTask", true)
		elseif req.taskCat == TASK_CATEGORY_SWORDSMAN then
			g_i3k_game_context:updateSwordsmanTaskValue(g_TASK_SHAPESHIFTING, req.npcId)
		elseif req.taskCat == TASK_CATEGORY_BIOGRAPHY then
			g_i3k_game_context:updateBiographyTaskValue(g_TASK_SHAPESHIFTING, req.npcId)
		end
	end
end

-- 任务护送物件协议
function i3k_sbean.task_conveyitem_res.handler(bean,req)
	local ok = bean.ok
	if ok == 1 then
		local mId = g_i3k_game_context:getMainTaskIdAndVlaue()
		local main_task_cfg = g_i3k_db.i3k_db_get_main_task_cfg(mId)
		local taskType = main_task_cfg.type
		g_i3k_game_context:setMainTaskIdAndValue(mId,1)
		--TODO刷新界面
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateMainTask",mId, 1, true)
--		g_i3k_game_context:updateMainTaskResponse()
	end
end

-- 任务文字答题协议
function i3k_sbean.task_answer_res.handler(bean,req)
	local ok = bean.ok
	if ok == 1 then
		local mId = g_i3k_game_context:getMainTaskIdAndVlaue()
		local main_task_cfg = g_i3k_db.i3k_db_get_main_task_cfg(mId)
		local taskType = main_task_cfg.type

		g_i3k_game_context:setMainTaskIdAndValue(mId,1)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateMainTask",mId, 1, true)
--		g_i3k_game_context:updateMainTaskResponse()
	end
end
------------------------------dtask_sync_req日常任务请求--------------------------------
function i3k_sbean.sync_dtask_info(state, jumpTo)
	local dailyTask = i3k_sbean.dtask_sync_req.new()
	dailyTask.state = state
	dailyTask.jumpTo = jumpTo
	i3k_game_send_str_cmd(dailyTask, i3k_sbean.dtask_sync_res.getName())
end

function i3k_sbean.dtask_sync_res.handler(bean, res)
	if bean.tasks then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Schedule, "clearScorll")--new add
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Schedule, "reloadTask", bean.tasks)
	end
end

-----------------------收取日常任务奖励--------------------------
function i3k_sbean.take_dtask_reward(tid, index,gifts)
	local takeAnnex = i3k_sbean.dtask_take_req.new()
	takeAnnex.id = tid
	takeAnnex.index = index
	takeAnnex.gifts = gifts
	i3k_game_send_str_cmd(takeAnnex, i3k_sbean.dtask_take_res.getName())
end

function i3k_sbean.dtask_take_res.handler(bean, res)
	local result = bean.ok
	local index = res.index
	if result==1 then
		DCTask.begin(res.id,DC_Daily)
		DCTask.complete(i3k_get_string(101428)..res.id)
		local map = {}
		map[i3k_get_string(101428)] = res.id
		DCEvent.onEvent(i3k_get_string(101429),map)
		g_i3k_ui_mgr:ShowGainItemInfo(res.gifts)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Schedule, "takeRewardUpdate", index)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(101430))
	end
end

function i3k_sbean.share_success.handler(res, req)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Schedule, "takeRewardUpdate")
end

------------------一键领取日常任务奖励------------------------------------
function i3k_sbean.batch_dtask_reward(tids, gifts)
	local batchAnnex = i3k_sbean.dtask_take_batch_req.new()
	batchAnnex.taskIds = tids
	batchAnnex.gifts = gifts
	i3k_game_send_str_cmd(batchAnnex, i3k_sbean.dtask_take_batch_res.getName())
end
function i3k_sbean.dtask_take_batch_res.handler(bean, res)
	local result = bean.ok
	if result == 1 then
		g_i3k_ui_mgr:ShowGainItemInfo(res.gifts)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Schedule, "takeRewardUpdate")
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(101430))
	end
end
-----------------------------------周常任务
function i3k_sbean.week_task_syncReq()
	local bean = i3k_sbean.week_task_sync_req.new()
	i3k_game_send_str_cmd(bean, i3k_sbean.week_task_sync_res.getName())
end

function i3k_sbean.week_task_sync_res.handler(res, req)
	--self.tasks:		vector[DBWeekTask]
	--self.reward:		set[int32]
	--self.score:		int32
	local data = res.data
	if req and data then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Schedule, "reloadWeekTask", data.tasks, data.reward, data.score, data, res.gaintBossOpenTime)
	end
end

function i3k_sbean.week_task_score_reward_takeReq(score)
	local bean = i3k_sbean.week_task_score_reward_take_req.new()
	bean.score = score
	i3k_game_send_str_cmd(bean, i3k_sbean.week_task_score_reward_take_res.getName())
end

function i3k_sbean.week_task_score_reward_take_res.handler(res, req)
	if res.ok > 0 then
		local rewardsTab = {}
		for k,v in pairs(res.drops) do
			table.insert( rewardsTab, {id = k,count = v} )
		end
		g_i3k_ui_mgr:ShowGainItemInfo(rewardsTab)
		i3k_sbean.week_task_syncReq()
	end
end

function i3k_sbean.week_task_finishReq(id)
	local bean = i3k_sbean.week_task_finish_req.new()
	bean.id = id
	i3k_game_send_str_cmd(bean, i3k_sbean.week_task_finish_res.getName())
end

function i3k_sbean.week_task_finish_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16942, i3k_db_weekTask.task[req.id].points))
		i3k_sbean.week_task_syncReq()
	end
end

------------------------------挑战任务任务--------------------------------
function i3k_sbean.sync_chtask_info(state, emojiId, emojiIndex)
	local challengeTask = i3k_sbean.chtask_sync_req.new()
	challengeTask.state = state
	challengeTask.emojiId = emojiId
	challengeTask.emojiIndex = emojiIndex
	i3k_game_send_str_cmd(challengeTask, i3k_sbean.chtask_sync_res.getName())
end

function i3k_sbean.chtask_sync_res.handler(bean, res)
	if bean.tasks then
		if res.emojiId then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_SelectBq, "setChallengeTaskData", bean.tasks, res.emojiId, res.emojiIndex)
		else
		if not g_i3k_ui_mgr:GetUI(eUIID_Main) then
			return
		end
		if not g_i3k_ui_mgr:GetUI(eUIID_DailyTask) then
			g_i3k_ui_mgr:OpenUI(eUIID_DailyTask)
				g_i3k_ui_mgr:RefreshUI(eUIID_DailyTask, res.state)
		end
			g_i3k_ui_mgr:CloseUI(eUIID_CardPacket)
		--保存成就点数
		g_i3k_game_context:setTaskAchPiont(bean.achPoints)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_DailyTask, "reloadChallengeTask", bean.tasks, bean.maxValues)
		end
	end
end

function i3k_sbean.take_chtask_reward(type, seq, index,task,achType,achPoint)
	local takeChTask = i3k_sbean.chtask_take_req.new()
	takeChTask.type = type
	takeChTask.seq = seq
	takeChTask.index = index
	takeChTask.task = task
	takeChTask.achType = achType
	takeChTask.achPoint = achPoint
	i3k_game_send_str_cmd(takeChTask, i3k_sbean.chtask_take_res.getName())
end

function i3k_sbean.chtask_take_res.handler(bean, req)
	local ok = bean.ok
	local type = req.type
	local seq = req.seq
	local index = req.index
	local achType = req.achType
	local achPoint = req.achPoint

	if ok == 1 then
		DCTask.begin(type,DC_Activity)
		DCTask.complete("挑战任务"..type)
		g_i3k_ui_mgr:ShowGainItemInfo(req.task)
		local achPointTab = g_i3k_game_context:getTaskAchPiont()
		achPointTab[achType] = achPointTab[achType] +achPoint
		g_i3k_game_context:setTaskAchPiont(achPointTab)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DailyTask, "setAchPoint")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DailyTask, "takeChTaskRewardHandle", type, seq, index)
	else
		g_i3k_ui_mgr:PopupTipMessage("收取失败，请重试")
	end
end

--一键领取
function i3k_sbean.chtask_batchtake(tasks, items) 
	local data = i3k_sbean.chtask_batchtake_req.new()
	data.tasks =tasks
	data.items = items
	i3k_game_send_str_cmd(data,"chtask_batchtake_res")
end
function i3k_sbean.chtask_batchtake_res.handler(bean, res)
	if bean.ok > 0 then
		for k, v in pairs(res.tasks) do
			DCTask.begin(k,DC_Activity)
			DCTask.complete("挑战任务"..k)
		end
		g_i3k_ui_mgr:ShowGainItemInfo(res.items)
		i3k_sbean.sync_chtask_info(1)
	end
end
------------------------------挑战任务任务end--------------------------------
--名望同步协议
function i3k_sbean.fame_sync_data(level)
	local req = i3k_sbean.fame_sync_req.new()
	req.level = level
	g_i3k_game_context:setTempFameIndex(level)
	i3k_game_send_str_cmd(req,i3k_sbean.fame_sync_res.getName())
end

function i3k_sbean.fame_sync_res.handler(res,req)
	res.info.level = req.level
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_DailyTask, "SetFameData",res.info)
	--g_i3k_game_context:SetFameLevel(res.info.level)
end

--名望进阶协议
function i3k_sbean.fame_promotion(level)
	local data =  i3k_sbean.fame_upgrade_req.new()
	data.level = level
	i3k_game_send_str_cmd(data,"fame_upgrade_res")
end

function i3k_sbean.fame_upgrade_res.handler(bean,req)
	if bean.ok > 0 then
		g_i3k_game_context:SetFameLevel( req.level)
		i3k_sbean.fame_sync_data(req.level)
		--g_i3k_ui_mgr:PopupTipMessage("名望晋阶成功")
		g_i3k_ui_mgr:OpenUI(eUIID_ProgressSuccess)
		g_i3k_ui_mgr:RefreshUI(eUIID_ProgressSuccess)
		for i,v in ipairs(i3k_db_fame) do
			if i == req.level then
				g_i3k_game_context:UseCommonItem(v.promotionUseId1, v.promotionUseCount1,AT_FAME_UPGRADE)
				g_i3k_game_context:UseCommonItem(v.promotionUseId2, v.promotionUseCount2,AT_FAME_UPGRADE)
				g_i3k_game_context:UseCommonItem(v.promotionUseId3, v.promotionUseCount3,AT_FAME_UPGRADE)
			end
		end
	end
end

--名望奖励协议
function i3k_sbean.fame_receive(level,gifts)
	local data =  i3k_sbean.fame_take_req.new()
	data.level = level
	data.gifts = gifts
	i3k_game_send_str_cmd(data,"fame_take_res")
end

function i3k_sbean.fame_take_res.handler(bean,req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:ShowGainItemInfo(req.gifts)
		i3k_sbean.fame_sync_data(g_i3k_game_context:getTempFameIndex())
	end
end






------------------------每日在线奖励同步在线奖励协议-------------------------
function i3k_sbean.sync_activities_onlinegift(percent)
	local bean = i3k_sbean.onlinegift_sync_req.new()
	bean.percent = percent
	i3k_game_send_str_cmd(bean, i3k_sbean.onlinegift_sync_res.getName())
end

function i3k_sbean.onlinegift_sync_res.handler(res, req)--info
	if res.info then
		--g_i3k_ui_mgr:OpenUI(eUIID_DailyActivity)
		--g_i3k_ui_mgr:RefreshUI(eUIID_DailyActivity, res.info,req.percent)
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_DailyActivity, "updateOnlineGiftInfo", res.info,req.percent)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli,"updateOnLineInfo",res.info,req.percent)
	end

end
-------------------------每日在线获取奖励-----------------------
function i3k_sbean.activities_onlinegift_take(minute,percent,gifts,index)
	local bean = i3k_sbean.onlinegift_take_req.new()
	bean.minute = minute
	bean.percent = percent
	bean.gifts = gifts
	bean.index = index
	i3k_game_send_str_cmd(bean, i3k_sbean.onlinegift_take_res.getName())
end

function i3k_sbean.onlinegift_take_res.handler(res, req)--只有ok
	if res.ok > 0 then
		g_i3k_ui_mgr:ShowGainItemInfo(req.gifts)
		i3k_sbean.sync_activities_onlinegift(req.percent)
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end
-------------------------------每日在线end--------------------------------------

------------------------全服答题活动同步协议-------------------------
function i3k_sbean.sync_activities_quizgift(state,item)
	local bean = i3k_sbean.quizgift_sync_req.new()
	bean.state = state
	--bean.item = item

	i3k_game_send_str_cmd(bean, i3k_sbean.quizgift_sync_res.getName())
end

function i3k_sbean.quizgift_sync_res.handler(res, req)
	local curtime = i3k_game_get_time()
	local openTime
	openTime = g_i3k_get_day_time(i3k_db_answer_questions_activity.startTime)
	local curtime1 =(curtime - openTime ) %  i3k_db_answer_questions_activity.limitTime
--	i3k_log("quizgift_sync_res  ==========",curtime1,openTime,res.info.startTime,i3k_db_answer_questions_activity.startTime,g_i3k_get_day_time(i3k_db_answer_questions_activity.startTime))----
	if res and res.info then--info(startTime,curSeq,curQuestion,data(bonus,expReward,doubleBonusUsed,continuousRightAnswer,lastAnsweredQuestionSeq,lastAnsweredQuestionResult))

		if res.info.curSeq  ~= res.info.data.lastAnsweredQuestionSeq then --同一题时显示上题的排名
			i3k_sbean.activities_quizgift_qrank(res.info.startTime)
		else

			if curtime1 >= i3k_db_answer_questions_activity.limitTime - i3k_db_answer_questions_activity.showAnswerlimitTime  then

				i3k_sbean.activities_quizgift_qrank(res.info.startTime)
			end
		end

		if req.state == 1 then
			g_i3k_ui_mgr:OpenUI(eUIID_AnswerQuestions)
			g_i3k_ui_mgr:RefreshUI(eUIID_AnswerQuestions, res.info)
			if res.info.startTime > 0 then
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_AnswerQuestions, "setCanUse", true,res.info.startTime)--中途进入
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_AnswerQuestions, "setCanMid", true,res.info.startTime)--中途进入
			end


		elseif req.state == 2 then

			g_i3k_ui_mgr:InvokeUIFunction(eUIID_AnswerQuestions, "updateQuizGiftMainInfo",res.info)--公布答案
		elseif req.state == 3 then

			local quizTimeSeq = math.modf((curtime - res.info.startTime) /  i3k_db_answer_questions_activity.limitTime)
			if res.info.curSeq == quizTimeSeq then--等待1秒再发
				g_i3k_coroutine_mgr:StartCoroutine(function ()
					g_i3k_coroutine_mgr.WaitForSeconds(1)
					i3k_sbean.sync_activities_quizgift(3)
				end)
			else
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_AnswerQuestions, "updateQuizGiftMainInfo",res.info)--切题
			end
		elseif req.state == 4 then
			if res.info.curSeq > i3k_db_answer_questions_activity.itemCount or res.info.curSeq <= 0 then
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_AnswerQuestions, "updateQuizGiftFinishInfo", res.info)--公布答案
			else
				g_i3k_coroutine_mgr:StartCoroutine(function ()
					g_i3k_coroutine_mgr.WaitForSeconds(1)
					i3k_sbean.sync_activities_quizgift(4)
				end)
			end

		else
			if res.info.startTime < openTime then --等待1秒再发
				g_i3k_coroutine_mgr:StartCoroutine(function ()
					g_i3k_coroutine_mgr.WaitForSeconds(1)
					i3k_sbean.sync_activities_quizgift()
				end)
			else
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_AnswerQuestions, "updateQuizGiftInfo", res.info)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_AnswerQuestions, "setCanUse", true,res.info.startTime)
			end

		end
	end
end
----
------------------------全服答题活动查询排行榜-------------------------
function i3k_sbean.activities_quizgift_qrank(startTime)
	local bean = i3k_sbean.quizgift_qrank_req.new()
	bean.startTime = startTime
	i3k_game_send_str_cmd(bean, i3k_sbean.quizgift_qrank_res.getName())
end

function i3k_sbean.quizgift_qrank_res.handler(res, req)
	if res.rank then--rank(bonus,roleId,roleName)

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_AnswerQuestions, "updateRankList", res.rank)
	end
end
----
------------------------全服答题活动答题协议-------------------------
function i3k_sbean.activities_quizgift_answer(startTime,seq,answer,useBoubleBonus,control)
	local bean = i3k_sbean.quizgift_answer_req.new()
	bean.startTime = startTime
	bean.seq = seq
	bean.answer = answer
	bean.useBoubleBonus = useBoubleBonus
	--bean.control = control
	i3k_game_send_str_cmd(bean, i3k_sbean.quizgift_answer_res.getName())
end

function i3k_sbean.quizgift_answer_res.handler(res, req)

	if res.ok > 0 then--ok表示 答题 改状态
		--答案正确 切下一题 有特效
		g_i3k_game_context:ChangeScheduleActivity( g_SCHEDULE_TYPE_ANSWER_QUE, g_SCHEDULE_COMMON_MAPID )
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_AnswerQuestions, "showQuizGiftMainInfo",req.control,req)
	else--未答题

		i3k_sbean.sync_activities_quizgift()
	end

	DCEvent.onEvent("科举答题", { seq = tostring(req.seq)})
end

------------------------同步幸运转盘信息协议-------------------------
function i3k_sbean.sync_activities_luckywheel()
	local bean = i3k_sbean.luckyroll_sync_req.new()

	i3k_game_send_str_cmd(bean, i3k_sbean.luckyroll_sync_res.getName())
end

function i3k_sbean.luckyroll_sync_res.handler(res, req)--info(totalDrawTimes,buyTimes,Id)
	if  res.ok == 1 and res.infos then
		--local freeTime = i3k_db_lucky_wheel.freeTime + req.times - res.info.totalDrawTimes
		--g_i3k_game_context:SetLuckyWheelFreeTime(freeTime)
		g_i3k_ui_mgr:OpenUI(eUIID_LuckyWheel)
		g_i3k_ui_mgr:RefreshUI(eUIID_LuckyWheel, res.infos)
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_LuckyWheel, "updateLuckyWheelMainInfo", res.info)
	else
		g_i3k_ui_mgr:PopupTipMessage("活动有误，稍后重试")
	end

end
------------------------幸运转盘抽奖协议-------------------------
function i3k_sbean.activities_luckywheel_take(time , id , cost)
	local bean = i3k_sbean.luckyroll_play_req.new()
	bean.effectiveTime = time
	bean.id = id
	bean.cost = cost
	i3k_game_send_str_cmd(bean, i3k_sbean.luckyroll_play_res.getName())
end

function i3k_sbean.luckyroll_play_res.handler(res, req)--pos(1~8)
	if res.ok > 0 then
		g_i3k_game_context:UseCommonItem(req.cost.id, req.cost.count, AT_LUCKY_WHEEL_ON_DRAW)--使用任何类型道具或货币
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LuckyWheel, "setRotateTo", res.ok)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LuckyWheel, "setStartState")
	elseif res.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
	else
		g_i3k_ui_mgr:PopupTipMessage("抽奖发生错误，稍后重试")
	end

end

------------------------幸运转盘抽奖协议(连抽)-------------------------
function i3k_sbean.activities_mul_luckywheel_take(time , id, cost)
	local bean = i3k_sbean.luckyroll_multiplay_req.new()
	bean.effectiveTime = time
	bean.id = id
	bean.cost = cost
	i3k_game_send_str_cmd(bean, i3k_sbean.luckyroll_multiplay_res.getName())
end

function i3k_sbean.luckyroll_multiplay_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:UseCommonItem(req.cost.id, req.cost.count, AT_MULPLAY_LUCKYROLL)  --使用任何类型道具或货币
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LuckyWheel, "popLuckyDrawGifts", res.rewards)
	elseif res.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
	else
		g_i3k_ui_mgr:PopupTipMessage("抽奖发生错误，稍后重试")
	end

end

------------------------购买幸运转盘抽奖次数协议-------------------------
function i3k_sbean.activities_luckywheel_buy(money_count)
	local bean = i3k_sbean.luckywheel_buydrawtimes_req.new()
	bean.money_count = money_count
	i3k_game_send_str_cmd(bean, i3k_sbean.luckywheel_buydrawtimes_res.getName())
end

function i3k_sbean.luckywheel_buydrawtimes_res.handler(res, req)--ok
	if res.ok > 0 then
		i3k_sbean.sync_activities_luckywheel()
		g_i3k_game_context:UseDiamond(req.money_count,false,AT_LUCKY_WHEEL_ON_DRAW)--使用绑定元宝 自动
		g_i3k_ui_mgr:CloseUI(eUIID_LuckyWheel_buy_count)
	else
		g_i3k_ui_mgr:PopupTipMessage("购买次数失败")
	end

end
----

------------------------热血夺宝活动同步协议-------------------------
function i3k_sbean.activities_goldenEgg()
	local bean = i3k_sbean.goldenegg_sync_req.new()
	i3k_game_send_str_cmd(bean, i3k_sbean.goldenegg_sync_res.getName())
end

function i3k_sbean.goldenegg_sync_res.handler(res, req)
	--对界面进行刷新
	if res.ok > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_GoldenEgg)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_GoldenEgg, "firstOpen", res.info)
	else
		g_i3k_ui_mgr:PopupTipMessage("活动有误，稍后重试")
	end
end

------------------------热血夺宝活动砸蛋协议-------------------------
function i3k_sbean.activities_goldenEgg_smash(effectiveTime, id, curtimes, playtimes, costId, cost, recordEgg, num, leftTimes)
	local bean = i3k_sbean.goldenegg_play_req.new()
	bean.effectiveTime = effectiveTime
	bean.id = id
	bean.curtimes = curtimes
	bean.playtimes = playtimes
	bean.costId = costId
	bean.cost = cost
	bean.useEggs = recordEgg
	bean.num = num
	bean.leftTimes = leftTimes
	i3k_game_send_str_cmd(bean, i3k_sbean.goldenegg_play_res.getName())
end

function i3k_sbean.goldenegg_play_res.handler(res, req)
	if res.ok > 0 then
		if req.playtimes == req.leftTimes then
			if req.playtimes == 1 then
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_GoldenEgg, "afterClickSmash", req.useEggs, res.gifts, req.playtimes, req.num, true)
			else
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_GoldenEgg, "afterClickGetAll", res.gifts, req.playtimes)
			end
		else
		     g_i3k_ui_mgr:InvokeUIFunction(eUIID_GoldenEgg, "afterClickSmash", req.useEggs, res.gifts, req.playtimes, req.num)
		end
		g_i3k_game_context:UseCommonItem(req.costId, req.cost,AT_SMASH_GOLDENEGG)
	elseif res.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15586))
	else
	    g_i3k_ui_mgr:PopupTipMessage("夺宝发生错误，稍后重试")
	end
end

------------------------热血夺宝活动刷新协议-------------------------
function i3k_sbean.activities_goldenEgg_refresh(effectiveTime, id, curtimes, cost)
	local bean = i3k_sbean.goldenegg_refresh_req.new()
	bean.effectiveTime = effectiveTime
	bean.id = id
	bean.curtimes = curtimes
	bean.cost = cost
	i3k_game_send_str_cmd(bean, i3k_sbean.goldenegg_refresh_res.getName())
end

function i3k_sbean.goldenegg_refresh_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:UseDiamond(req.cost,true,AT_REFRESH_GOLDENEGG )
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_GoldenEgg, "afterClickRefresh", res.rewards)
	else
	   g_i3k_ui_mgr:PopupTipMessage("刷新发生错误，稍后重试")
	end
end


---------------------------------------------------------------
--新神兵任务领取奖励
function i3k_sbean.wtask_reward_res.handler(res,req)
	local nextTaskId = res.nextTaskId
	if nextTaskId == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16372))
		return
	end
	if req.__callback then
		req.__callback()
	end
	local is_loop = 0
	local dayLoopCount = g_i3k_game_context:getWeaponDayLoopCount()
	local id,loop = g_i3k_game_context:getWeaponTaskIdAndLoopType()
	local weapon_task_cfg = g_i3k_db.i3k_db_get_weapon_task_cfg(id,loop)
	local itemid = weapon_task_cfg.awardItemid
	local itemCount = weapon_task_cfg.awardItemCount
	local type1 = weapon_task_cfg.type1
	local type2 = weapon_task_cfg.type2
	local arg11 = weapon_task_cfg.arg11
	local arg12 = weapon_task_cfg.arg12
	local arg21 = weapon_task_cfg.arg21
	local arg22 = weapon_task_cfg.arg22
	if type1 == g_TASK_USE_ITEM then
		g_i3k_game_context:UseCommonItem(arg11,arg12,AT_TAKE_WEAPON_TASK_REWARD)
	end
	if type2 == g_TASK_USE_ITEM then
		g_i3k_game_context:UseCommonItem(arg21,arg22,AT_TAKE_WEAPON_TASK_REWARD)
	end
	if loop == 0 then
		local tmp_task_cfg = g_i3k_db.i3k_db_get_weapon_task_cfg(id+1,loop)
		if tmp_task_cfg then
			is_loop = loop
		else
			is_loop = 1
		end
	else
		is_loop = 1
	end

	local cfg = g_i3k_db.i3k_db_get_weapon_task_cfg(nextTaskId,is_loop)
	local tmp = {0,0}
	tmp[1] = g_i3k_game_context:InitTaskValue(cfg.type1, cfg.arg11, cfg.arg12)
	tmp[2] = g_i3k_game_context:InitTaskValue(cfg.type2, cfg.arg21, cfg.arg22)

	if loop ~= 0 then
		dayLoopCount = dayLoopCount + 1
	end
	g_i3k_game_context:AddTaskToDataList(TASK_CATEGORY_WEAPON, res.receiveTime)
	g_i3k_game_context:setWeaponTaskData(nextTaskId,is_loop,tmp,dayLoopCount)
	--DCAccount.removeTag("神兵任务", "")
	--DCAccount.addTag("神兵任务", nextTaskId)
	DCEvent.onEvent("神兵任务", {["任务ID"] = nextTaskId})
	local map = {}
	map["任务ID"] = id
	DCEvent.onEvent("神兵任务完成",map)
	DCTask.complete("神兵任务"..id)
	DCTask.begin(nextTaskId,DC_BranchLine)

--TODO刷新界面
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateWeaponTask",is_loop, nextTaskId, tmp[1], tmp[2], dayLoopCount)
	--i3k_log("wtask_reward_res", dayLoopCount, "task id", nextTaskId)
	if i3k_db_common.weapontask.Ctasktimes  <= dayLoopCount then
		g_i3k_ui_mgr:CloseUI(eUIID_Task)
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Task,"updateWeaponData")
	g_i3k_game_context:updateWeaponTaskResponse()
end

--快速完成神兵任务
function i3k_sbean.wtask_quick_finish_res.handler(res,req)
	if res.nextTaskId ~= 0 then
		local cfg = g_i3k_db.i3k_db_get_quick_finish_task_cfg(g_QUICK_FINISH_TASK_TYPE_SHENBING)
		g_i3k_game_context:UseCommonItem(cfg.needItemId, cfg.needItemCount, AT_WEAPON_TASK_QUICK_FINISH_TASK)
	end
	i3k_sbean.wtask_reward_res.handler(res,req)
end

--快速完成神兵任务请求
function i3k_sbean.quick_finish_weapon_task(taskID)
	local cfg = g_i3k_db.i3k_db_get_quick_finish_task_cfg(g_QUICK_FINISH_TASK_TYPE_SHENBING)
	if g_i3k_game_context:GetCommonItemCanUseCount(cfg.needItemId) >= cfg.needItemCount then
		local callfunc = function()
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"playTaskFinishEffect")
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"onUpdateBatterEquipShow")
	 		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17500))
		end
		local bean = i3k_sbean.wtask_quick_finish_req.new()
		bean.taskId = taskID
		bean.__callback = callfunc
		i3k_game_send_str_cmd(bean,i3k_sbean.wtask_quick_finish_res.getName())
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17498, g_i3k_db.i3k_db_get_common_item_name(cfg.needItemId)))
	end
end

function i3k_sbean.quick_finish_secrettask(taskId, gifts)
	local bean = i3k_sbean.onekey_finish_secrettask_req.new()
	bean.id = taskId
	bean.gifts = gifts
	i3k_game_send_str_cmd(bean, i3k_sbean.onekey_finish_secrettask_res.getName())
end
function i3k_sbean.onekey_finish_secrettask_res.handler(res, req)
	if res.ok > 0 then
		local cfg = g_i3k_db.i3k_db_get_quick_finish_task_cfg(g_QUICK_FINISH_FIVE_UNIQUE)
		g_i3k_game_context:UseCommonItem(cfg.needItemId, cfg.needItemCount)
		g_i3k_ui_mgr:ShowGainItemInfo(req.gifts)
		g_i3k_game_context:ResetDaySecretareaTask()
		g_i3k_game_context:setSecretareaTaskIdAndValue(0,0)
		g_i3k_game_context:setSecretareaTaskId(0,0,1)
		g_i3k_ui_mgr:CloseUI(eUIID_Secretarea)
	end
end
--新随从领取奖励
function i3k_sbean.ptask_reward_res.handler(res,req)
	--if nextTaskId ~= 0 then
		if req.isdiamond and req.isdiamond == 1 then
			if req.needDiamond > g_i3k_game_context:GetDiamondCanUse(false) then
				g_i3k_ui_mgr:PopupTipMessage("元宝不足，无法完成")
				return
			else
				g_i3k_game_context:UseDiamond(req.needDiamond, false,AT_TAKE_PET_TASK_REWARD)
			end
		end
		if req.__callback then
			req.__callback()
		end
		local nextTaskId = res.nextTaskId
		local id = req.petId
		local old_taskID = req.taskId
		local old_pet_task_cfg = g_i3k_db.i3k_db_get_pet_task_cfg(old_taskID)
		local friendValue = old_pet_task_cfg.firendValue
		g_i3k_game_context:AddYongBIngFriendExp(id,friendValue)
		g_i3k_game_context:setOnePetTask(id,nextTaskId,0)
		local times = g_i3k_game_context:GetDailyCompleteTask(id)

		if times == i3k_db_common.petBackfit.petTaskMax - 1 then
			g_i3k_game_context:setOnePetTask(id,0,0)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetTask,"updateAllPetData", true)
		else
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetTask, "updateAllPetData")
		end
		g_i3k_game_context:SetDailyCompleteTask(id, times+1)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetTask, "updatePetTaskData", id)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong, "onUpdatePetRedPoint")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong, "onShowBackfit")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updatePetNotice")
		--TODO刷新界面
		--DCAccount.removeTag("随从" .. id .. "合修任务", "")
		--DCAccount.addTag("随从" .. id .. "合修任务", tostring(nextTaskId))
		DCEvent.onEvent("随从" .. id .. "合修任务",{["任务ID"] = tostring(nextTaskId)})
		local map = {}
		map["随从".. id .."合修任务"] = old_taskID
		DCEvent.onEvent("随从" .. id .. "合修任务完成",map)
		DCTask.begin(old_taskID,DC_GuideLine)
		DCTask.complete("随从" .. id .. "合修任务".. old_taskID)
	--end

end

-----------------------------------
--接取主线任务
function i3k_sbean.mainTask_take(taskId, isAuto)
	local data = i3k_sbean.mtask_take_req.new()
	data.taskId = taskId
	data.isAuto = isAuto
	i3k_game_send_str_cmd(data,i3k_sbean.mtask_take_res.getName())
end

function i3k_sbean.mtask_take_res.handler(res, req)
	if res.ok > 0 then
		local taskId = req.taskId
		local cfg = g_i3k_db.i3k_db_get_main_task_cfg(taskId)
		local taskValue = g_i3k_game_context:InitTaskValue(cfg.type, cfg.arg1, cfg.arg2)
		g_i3k_game_context:setMainTaskIdAndValue(taskId, taskValue, 1)

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateMainTaskTag", req.isAuto)
	end
end

--放弃主线任务
function i3k_sbean.mtask_quit(taskId)
	local data = i3k_sbean.mtask_quit_req.new()
	data.taskId = taskId
	i3k_game_send_str_cmd(data,i3k_sbean.mtask_quit_res.getName())
end

function i3k_sbean.mtask_quit_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("重置任务成功")
		local cfg = g_i3k_db.i3k_db_get_main_task_cfg(req.taskId)

		local taskValue = g_i3k_game_context:InitTaskValue(cfg.type, cfg.arg1, cfg.arg2)
		g_i3k_game_context:setMainTaskIdAndValue(cfg.id, taskValue, 0)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateMainTask",req.taskId,nil,nil)
		i3k_sbean.mainTask_take(req.taskId, false)
	end
end

function i3k_sbean.dialogue_req(taskCat, npcId, dialogId, taskID, petID, callback)
	local data = i3k_sbean.task_dialog_req.new()
	data.taskCat = taskCat
	data.taskID = taskID
	data.petId = petID

	data.npcId = npcId
	data.dialogId = dialogId
	data.__callback = callback
	i3k_game_send_str_cmd(data,i3k_sbean.task_dialog_res.getName())
end
------------------------------------
--主线任务领取奖励
function i3k_sbean.mtask_reward_res.handler(res,req)
	local is_ok = res.ok
	if not req then
		return
	end

	if is_ok == 1 then
		if req.__callback then
			req.__callback()
		end
		local id = req.taskId
		local main_task_cfg = g_i3k_db.i3k_db_get_main_task_cfg(id)
		if main_task_cfg.type == g_TASK_SHAPESHIFTING then	--护送NPC
			g_i3k_game_context:setConvoyNpcState(false)
		end
		if main_task_cfg.isDressTitle == 1 and main_task_cfg.missionTitle > 0 then
			if g_i3k_game_context:GetNowEquipTitle() > 0 then
				i3k_sbean.goto_permanenttitle_set(main_task_cfg.missionTitle, 2, main_task_cfg.missionTitle) -- 装备永久称号(并卸下同一类型称号)
			elseif g_i3k_game_context:GetNowEquipTitle() == 0 then
				i3k_sbean.goto_permanenttitle_set(main_task_cfg.missionTitle, 1,main_task_cfg.missionTitle) -- 装备永久称号
			else
				i3k_sbean.goto_permanenttitle_set(0, 0, main_task_cfg.id, 1) -- 卸下永久称号
			end
		end
		if main_task_cfg.missionTitle ~= 0 then
			g_i3k_ui_mgr:OpenUI(eUIID_ShowRoleTitleTips)
			g_i3k_ui_mgr:RefreshUI(eUIID_ShowRoleTitleTips, main_task_cfg.missionTitle)
		end

		local _tmp = g_i3k_db.i3k_db_get_main_task_cfg(id)
		g_i3k_game_context:nextLimitTimeTask(_tmp.limitTaskIdStart, _tmp.limitTaskIdEnd)
		local task_type = _tmp.type
		DCTask.complete("主线任务"..id)

		--加经验
		local exp = _tmp.awardExp

		local nextid = _tmp.backID
		if nextid == 0 then
			if g_i3k_game_context:GetTransformBWtype() == 1 then
				nextid = _tmp.whiteID
			else
				nextid = _tmp.blackID
			end
		end
		local main_task_cfg = g_i3k_db.i3k_db_get_main_task_cfg(nextid)
		local taskType = main_task_cfg.type

		local taskValue = g_i3k_game_context:InitTaskValue(main_task_cfg.type, main_task_cfg.arg1, main_task_cfg.arg2)
		local state = main_task_cfg.getTaskNpcID == 0 and 1 or 0
		g_i3k_game_context:setMainTaskIdAndValue(nextid, taskValue, state)
		if main_task_cfg.getTaskNpcID == 0 then
			g_i3k_game_context:OpenGetTaskDialogue(main_task_cfg, TASK_CATEGORY_MAIN)
		end

		DCTask.begin(nextid,DC_MainLine)

		DCEvent.onEvent("主线任务" ,{["任务ID"] = nextid})
		local map = {}
		map["任务ID"] = id
		DCEvent.onEvent("主线任务完成",map)
		--TODO刷新界面
		if main_task_cfg.type == g_TASK_REACH_LEVEL and g_i3k_game_context:GetLevel() < main_task_cfg.arg1 then
			g_i3k_game_context:SetMainTaskIndex(2)
			--g_i3k_game_context:SetMainTaskIndex(1)
		else
			g_i3k_game_context:SetMainTaskIndex(1)
		end

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateMainTask",nextid)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Task,"onShow")

		g_i3k_game_context:ChangeNpcActName(main_task_cfg)
		g_i3k_game_context:RefreshMissionEffect()
		g_i3k_game_context:LeadCheck();
		g_i3k_game_context:PlotCheck();
		--判断支线任务解锁
		g_i3k_game_context:checkSubLineTaskIsLock(3)
		g_i3k_game_handler:RoleBreakPoint("Game_Role_Finish_Main_Task", tostring(id))
	else
		g_i3k_ui_mgr:PopupTipMessage("任务失败")
	end
end

-------支线任务------
--放弃任务
function i3k_sbean.branch_task_quit(groupId, taskid)
	local data = i3k_sbean.branch_task_quit_req.new()
	data.groupId = groupId
	data.taskId = taskid
	i3k_game_send_str_cmd(data,i3k_sbean.branch_task_quit_res.getName())
end

function i3k_sbean.branch_task_quit_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("重置任务成功")
		g_i3k_game_context:addSubLineData(req.groupId, req.taskId, 0, 0)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateSublineTask",req.groupId, req.taskId,nil)
	end
end

--接取任务请求
function i3k_sbean.branch_task_receive(id, isAuto, callback)
	--self.groupId:		int32
	local data = i3k_sbean.branch_task_take_req.new()
	data.groupId = id
	data.isAuto = isAuto
	data.callback = callback
	i3k_game_send_str_cmd(data,i3k_sbean.branch_task_take_res.getName())
end

function i3k_sbean.branch_task_take_res.handler(res,req)
	--self.ok:		int32
 	if res.ok >0 then
		if req.callback then
			req.callback()
		end
--		g_i3k_ui_mgr:PopupTipMessage("支线接取成功")
		local data = g_i3k_game_context:getSubLineIdAndValueBytype(req.groupId)
		local taskId = data.id

		g_i3k_game_context:addSubLineData(req.groupId,taskId,0,1)
		local cfg = g_i3k_db.i3k_db_get_subline_task_cfg(req.groupId, taskId)
		if taskId == 1 and cfg.isHide == 1 then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateSublineTask", req.groupId, taskId)
		else
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateSubLineTaskTag", req.groupId, req.isAuto)
		end
		DCEvent.onEvent("支线任务_".. req.groupId ,{["任务ID"] = taskId})
	else
		g_i3k_ui_mgr:PopupTipMessage("接取支线任务失败")
	end
end

--完成支线任务请求
function i3k_sbean.branch_task_finish(id)
	--self.groupId:		int32
	local data = i3k_sbean.branch_task_finish_req.new()
	data.groupId = id
	i3k_game_send_str_cmd(data,i3k_sbean.branch_task_finish_res.getName())
end

function i3k_sbean.branch_task_finish_res.handler(res,req)
	--self.ok:		int32
	if res.ok >0 then
		if req.__callback then
			req.__callback()
		end
		local data = g_i3k_game_context:getSubLineIdAndValueBytype(req.groupId)
		--
		local cfg = g_i3k_db.i3k_db_get_subline_task_cfg(req.groupId,data.id)
		if cfg.backid ~= 0 then
			local newCfg = g_i3k_db.i3k_db_get_subline_task_cfg(req.groupId,cfg.backid)
			local state = newCfg.getTaskNpcID == 0 and 1 or 0
			g_i3k_game_context:addSubLineData(req.groupId, cfg.backid, 0, state)
			if newCfg.getTaskNpcID == 0 then
				g_i3k_game_context:GetSubLineTaskDialogue(cfg.taskgroupid, cfg.backid)
			end
			-- g_i3k_game_context:AddTaskToDataList(req.groupId*1000)
			g_i3k_game_context:AddTaskToDataList(g_i3k_db.i3k_db_get_subline_task_hash_id(req.groupId))
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateSublineTask", cfg.taskgroupid, cfg.backid)
		else
			--判断支线任务解锁
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"removeSubTaskItem", req.groupId, data.id)
			-- g_i3k_game_context:removeTaskData(req.groupId*1000)
			--g_i3k_game_context:removeTaskData(req.groupId*1000)
			g_i3k_game_context:removeTaskData(g_i3k_db.i3k_db_get_subline_task_hash_id(req.groupId))
			g_i3k_game_context:setSubTaskOneGroupData(req.groupId, 0, 0, 0)
			g_i3k_game_context:checkSubLineTaskIsLock(4,req.groupId)
		end

		DCTask.begin(req.groupId * 1000 + data.id, DC_BranchLine)
		DCTask.complete("支线任务_"..(req.groupId * 1000 + data.id))
	else
		g_i3k_ui_mgr:PopupTipMessage("任务失败")
	end
end
-----------------------------------

---------------------------身世任务--------------------
--获取身世任务的奖励
function i3k_sbean.petlifetask_reward(petID, taskID)
	local data = i3k_sbean.petlifetask_reward_req.new()
	data.petId = petId
	data.taskId = taskId
	i3k_game_send_str_cmd(data,i3k_sbean.petlifetask_reward_res.getName())
end

function i3k_sbean.petlifetask_reward_res.handler(bean, req)
	if bean.ok ~= 0  then
		--获取任务奖励成功
		if req.__callback then
			req.__callback()
		end
		g_i3k_game_context:setOnePetLifeTask(req.petId,req.taskId,0,1)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenshiBattle,"onShowData",req.petId, true)
		--g_i3k_ui_mgr:PopupTipMessage("获取身世任务奖励")
	end
end

--通知客户端同步合修任务
function i3k_sbean.role_new_pet_task.handler(bean)
	if bean then
		--bean.petID
		--bean.taskID
		local petID = bean.petid
		local taskID = bean.taskid
		g_i3k_game_context:setOnePetTask(petID, taskID, 0)
		--DCAccount.removeTag("随从" .. petID .. "合修任务", "")
		--DCAccount.addTag("随从" .. petID .. "合修任务", tostring(taskID))
		DCEvent.onEvent("随从" .. petID .. "合修任务" ,{["任务ID"] = tostring(taskID)})
	end
end

--接取佣兵身世任务
function i3k_sbean.petlifetask_take(petID, taskId)
	local data = i3k_sbean.petlifetask_take_req.new()
	data.petId = petID
	data.taskId = taskId
	i3k_game_send_str_cmd(data,i3k_sbean.petlifetask_take_res.getName())
end

function i3k_sbean.petlifetask_take_res.handler(bean, req)
	if bean.ok ~= 0 then
		g_i3k_game_context:setOnePetLifeTask(req.petId,req.taskId,0,0)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenshiBattle,"onShowData",req.petId, true)
		DCEvent.onEvent("随从" .. req.petId .. "身世任务" ,{["任务ID"] = tostring(taskId)})
	end
end

--进入副本协议
function i3k_sbean.lifetaskmap_start(mapId,petId)
	local data = i3k_sbean.lifetaskmap_start_req.new()
	data.petId = petId
	data.mapId = mapId
	i3k_game_send_str_cmd(data,i3k_sbean.lifetaskmap_start_res.getName())
end

function i3k_sbean.lifetaskmap_start_res.handler(bean, req)
	if bean.ok ~= 0 then
		--g_i3k_ui_mgr:OpenUI(eUIID_ShenshiBattle)
		--g_i3k_ui_mgr:RefreshUI(eUIID_ShenshiBattle, req.petId)
	end
end

function i3k_sbean.task_randquestion_res.handler(bean, res)
	local is_ok = bean.ok
	if is_ok == 1 then
		if res.taskCat == TASK_CATEGORY_MAIN then
			local mId = g_i3k_game_context:getMainTaskIdAndVlaue()
			g_i3k_game_context:setMainTaskIdAndValue(mId,1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateMainTask",mId, 1, true)
		elseif res.taskCat == TASK_CATEGORY_LIFE then
		elseif res.taskCat == TASK_CATEGORY_OUT_CAST then 

		elseif res.taskCat == TASK_CATEGORY_SUBLINE then
		elseif res.taskCat == i3k_get_MrgTaskCategory() then
			local data = g_i3k_game_context:GetMarriageTaskData()
			g_i3k_game_context:AddMarriageTaskValue(1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateMrgTask",data.id, data.groupID, 1, true)
		elseif res.taskCat == TASK_CATEGORY_SWORDSMAN then
			g_i3k_game_context:setSwordsmanCircleTaskValue(1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "udpateSwordsmanTask", true)
		end
	end
end

-----------------姻缘任务----------------
function i3k_sbean.mrgseriestask_openReq()
	local req = i3k_sbean.mrgseriestask_open_req.new()
	i3k_game_send_str_cmd(req,i3k_sbean.mrgseriestask_open_res.getName())
end
local function createMrgTask(open)
	if open <= 0 then
		return g_i3k_ui_mgr:PopMgrCode(open)
	end
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(884))
	g_i3k_game_context:SetMarriageTaskOpen(open)
	local data = g_i3k_game_context:GetMarriageTaskData()
	if data.groupID >= 0 and data.id > 0 then
		local cfg = g_i3k_db.i3k_db_marry_task(data.id, data.groupID)
		if cfg.getTaskNpcID == 0 then
			g_i3k_game_context:SetMarriageTaskState(1)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateMrgTask")
	end
end
function i3k_sbean.mrgseriestask_open_res.handler(res,req)
	createMrgTask(res.ok)
end
function i3k_sbean.role_mrgseriestask_open.handler(bean)
	createMrgTask(bean.open)
end

function i3k_sbean.mrgseriestask_takeReq(taskID)
	if g_i3k_game_context:CoupleDoTask() then
		return
	end
	local req = i3k_sbean.mrgseriestask_take_req.new()
	req.taskID = taskID
	i3k_game_send_str_cmd(req,i3k_sbean.mrgseriestask_take_res.getName())
end

local function mrgseriestask_take(ok)
	if ok <= 0 then
		return g_i3k_ui_mgr:PopMgrCode(ok)
	end

	g_i3k_game_context:SetMarriageTaskState(1)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateMrgTaskTag", true)
end
function i3k_sbean.mrgseriestask_take_res.handler(res, req)
	mrgseriestask_take(res.ok)
end
function i3k_sbean.role_mrgseriestask_take.handler(bean)
	g_i3k_ui_mgr:CloseUI(eUIID_Dialogue1)
	g_i3k_ui_mgr:CloseUI(eUIID_Dialogue3)
	g_i3k_ui_mgr:CloseUI(eUIID_Dialogue4)
	mrgseriestask_take(bean.receiveTime)
end
local function mrgtask_reward(ok,nextid, groupId, last_cfg)
	if ok <= 0 then
		return g_i3k_ui_mgr:PopMgrCode(ok)
	end

	if last_cfg and last_cfg.type == g_TASK_SHAPESHIFTING then
		g_i3k_game_context:setConvoyNpcState(false)
	end
	if nextid ~= 0 then
		local cfg = g_i3k_db.i3k_db_marry_task(nextid, groupId)

		local taskValue = g_i3k_game_context:InitTaskValue(cfg.type, cfg.arg1, cfg.arg2)
		local state = cfg.getTaskNpcID == 0 and 1 or 0
		g_i3k_game_context:SetNextMarriageTaskData(nextid, taskValue, state)
		-- if cfg.getTaskNpcID == 0 then
		-- 	g_i3k_game_context:OpenGetTaskDialogue(cfg, i3k_get_MrgTaskCategory())
		-- end
		g_i3k_game_context:AddTaskToDataList(i3k_get_MrgTaskCategory())
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateMrgTask")

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateMrgTaskTag", true)
	else
		g_i3k_game_context:SetNextMarriageTaskData(0, 0, 0)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"removeMrgTask")
		g_i3k_game_context:removeTaskData(i3k_get_MrgTaskCategory())
	end
	g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_MAR,g_SCHEDULE_COMMON_MAPID)
	g_i3k_game_context:RefreshMissionEffect()
end

function i3k_sbean.mrgseriestask_rewardReq(taskID, callback)
	if g_i3k_game_context:CoupleDoTask() then
		return
	end
	local req = i3k_sbean.mrgseriestask_reward_req.new()
	req.taskID = taskID
	req.__callback = callback
	i3k_game_send_str_cmd(req,i3k_sbean.mrgseriestask_reward_res.getName())
end

local function getMrgLastTaskCfg()
	local data = g_i3k_game_context:GetMarriageTaskData()
	local cfg = g_i3k_db.i3k_db_marry_task(data.id, data.groupID)
	return cfg, data
end

function i3k_sbean.mrgseriestask_reward_res.handler(res, req)
	if req and res.ok > 0  and req.__callback then
		g_i3k_game_context:ChangeScheduleActivity( g_SCHEDULE_TYPE_MAR, g_SCHEDULE_COMMON_MAPID )
		req.__callback()
	end
	local last_cfg, data = getMrgLastTaskCfg()
	mrgtask_reward(res.ok, last_cfg.backid, data.groupID, last_cfg)
end
function i3k_sbean.role_mrgseriestask_reward.handler(bean)
	local last_cfg, data = getMrgLastTaskCfg()
	g_i3k_ui_mgr:CloseUI(eUIID_Dialogue1)
	g_i3k_ui_mgr:CloseUI(eUIID_Dialogue4)
	g_i3k_ui_mgr:CloseUI(eUIID_Task)
	mrgtask_reward(bean.receiveTime, last_cfg.backid, data.groupID, last_cfg)
end
---------------------婚姻 环任务
function i3k_sbean.mrglooptask_openReq()
	local req = i3k_sbean.mrglooptask_open_req.new()
	i3k_game_send_str_cmd(req,i3k_sbean.mrglooptask_open_res.getName())
end
function i3k_sbean.mrglooptask_open_res.handler(res, req)
	createMrgTask(res.ok)
end
function i3k_sbean.role_mrglooptask_open.handler(bean)
	createMrgTask(bean.open)
end

function i3k_sbean.mrglooptask_takeReq(taskID)
	if g_i3k_game_context:CoupleDoTask() then
		return
	end
	local req = i3k_sbean.mrglooptask_take_req.new()
	req.taskID = taskID
	i3k_game_send_str_cmd(req,i3k_sbean.mrglooptask_take_res.getName())
end
function i3k_sbean.mrglooptask_take_res.handler(res, req)
	g_i3k_game_context:setMrgTaskCount(res.curLoop)
	mrgseriestask_take(res.ok)
end
function i3k_sbean.role_mrglooptask_take.handler(bean)
	g_i3k_ui_mgr:CloseUI(eUIID_Dialogue1)
	g_i3k_ui_mgr:CloseUI(eUIID_Dialogue3)
	g_i3k_ui_mgr:CloseUI(eUIID_Dialogue4)
	g_i3k_game_context:setMrgTaskCount(bean.curLoop)
	mrgseriestask_take(bean.receiveTime)
end

function i3k_sbean.mrglooptask_rewardReq(taskID, callback)
	if g_i3k_game_context:CoupleDoTask() then
		return
	end
	local req = i3k_sbean.mrglooptask_reward_req.new()
	req.taskID = taskID
	req.__callback = callback
	i3k_game_send_str_cmd(req,i3k_sbean.mrglooptask_reward_res.getName())
end
function i3k_sbean.mrglooptask_reward_res.handler(res, req)
	if res.ok > 0 and req.__callback then
		req.__callback()
	end
	local last_cfg = getMrgLastTaskCfg()
	mrgtask_reward(res.ok, res.taskID, 0, last_cfg)
	g_i3k_game_context:updateMrgTaskCount(res.curLoop)
end
function i3k_sbean.role_mrglooptask_reward.handler(bean)
	local last_cfg = getMrgLastTaskCfg()
	g_i3k_ui_mgr:CloseUI(eUIID_Dialogue1)
	g_i3k_ui_mgr:CloseUI(eUIID_Dialogue4)
	g_i3k_ui_mgr:CloseUI(eUIID_Task)
	mrgtask_reward(bean.receiveTime, bean.nextTaskID, 0, last_cfg)
	g_i3k_game_context:updateMrgTaskCount(bean.curLoop)
end

-----mrg series------------

function i3k_sbean.role_mrgseriestask_update.handler(bean)
	g_i3k_game_context:LogMrgTask(bean.value)
end
-----mrg loop--------------
function i3k_sbean.role_mrglooptask_update.handler(bean)
	g_i3k_game_context:LogMrgTask(bean.value)
end

function i3k_sbean.role_marriage_level.handler(bean)
	if bean.level == 0 then
		--清空结婚数据
		local data = {marriageType = 1,marriageExp = 0,marriageLevel = 1,marriageSkill = {},marriageTime = 0,marriageStep = -1,marriageRole = {},marriageTask = {}}
		g_i3k_game_context:setMarryData(data)
		g_i3k_game_context:setRecordSteps(-1)
		g_i3k_game_context:SetNextMarriageTaskData(0, 0, 0)
		g_i3k_game_context:SetMarriageTaskOpen(0)
		g_i3k_game_context:setMarryRoleId(0)
		g_i3k_game_context:removeTaskData(i3k_get_MrgTaskCategory())
		g_i3k_game_context:DeleteMarriageTitle()
		g_i3k_game_context:ClearNotice(g_NOTICE_TYPE_MARRY_ACHIEVEMENT)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"removeMrgTask")
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(4121))
		for _,v in ipairs({eUIID_Task, eUIID_Marry_Marryed_Yinyuan, eUIID_Marry_Marryed_lihun, eUIID_Marry_Marryed_skills, eUIID_MarriageTitle, eUIID_MarriageCertificate, eUIID_ShareMarriageCard, eUIID_MarryAchievement}) do
			g_i3k_ui_mgr:CloseUI(v)
		end
	end
	g_i3k_game_context:setMarriageExp(bean)
end

function i3k_sbean.epic_task_takeReq(seriesID, groupID, isAuto)
	local req = i3k_sbean.epic_task_take_req.new()
	req.seriesID = seriesID
	req.groupID = groupID
	req.isAuto = isAuto
	i3k_game_send_str_cmd(req,i3k_sbean.epic_task_take_res.getName())
end

function i3k_sbean.epic_task_take_res.handler(res, req)
	if res.receiveTime > 0 then
		g_i3k_game_context:setCurrEpicTaskState(1,req.isAuto)
	end
end

function i3k_sbean.epic_task_rewardReq(seriesID, groupID)
	local req = i3k_sbean.epic_task_reward_req.new()
	req.seriesID = seriesID
	req.groupID = groupID
	i3k_game_send_str_cmd(req,i3k_sbean.epic_task_reward_res.getName())
end

function i3k_sbean.epic_task_reward_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:nextEpicTask()
	end
end

--放弃史诗任务
function i3k_sbean.epic_task_quitReq(seriesID, groupID)
	local data = i3k_sbean.epic_task_quit_req.new()
	data.seriesID = seriesID
	data.groupID = groupID
	i3k_game_send_str_cmd(data,i3k_sbean.epic_task_quit_res.getName())
end

function i3k_sbean.epic_task_quit_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("重置任务成功")
		g_i3k_game_context:resetEpicTaskValue()
		i3k_sbean.epic_task_takeReq(req.seriesID, req.groupID, false)
	end
end

------------找你妹-----------

--开始
function i3k_sbean.findMooncake_start(id)
	local data = i3k_sbean.finding_your_sister_start_req.new()
	data.id = id
	i3k_game_send_str_cmd(data,i3k_sbean.finding_your_sister_start_res.getName())
end

function i3k_sbean.finding_your_sister_start_res.handler(res,req)
	if res.result > 0 and res.info.useTimes < i3k_db_findMooncake[res.info.id].dayTimes then
		local db = i3k_db_findMooncake[req.id]
		local gameType = db.gameType
		if gameType == e_TYPE_MOONCAKE then
			g_i3k_ui_mgr:OpenUI(eUIID_FindMooncake)
			g_i3k_ui_mgr:RefreshUI(eUIID_FindMooncake, res.info)
			g_i3k_ui_mgr:OpenUI(eUIID_WaitToFind)
			g_i3k_ui_mgr:RefreshUI(eUIID_WaitToFind, e_TYPE_MOONCAKE)
		elseif gameType == e_TYPE_PROTECTMELON then
			g_i3k_ui_mgr:OpenUI(eUIID_ProtectMelon)
			g_i3k_ui_mgr:RefreshUI(eUIID_ProtectMelon, res.info)
			
			local fun = function() 
				g_i3k_ui_mgr:OpenUI(eUIID_WaitToFind)
				g_i3k_ui_mgr:RefreshUI(eUIID_WaitToFind, e_TYPE_PROTECTMELON)
			end
			
			g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(17297), fun)
		elseif gameType == e_TYPE_MEMORYCARD then
			g_i3k_ui_mgr:OpenUI(eUIID_MemoryCard)
			g_i3k_ui_mgr:RefreshUI(eUIID_MemoryCard, res.info)
			local fun = function()
				g_i3k_ui_mgr:OpenUI(eUIID_WaitToFind)
				g_i3k_ui_mgr:RefreshUI(eUIID_WaitToFind, e_TYPE_MEMORYCARD)
			end
			g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(17745), fun)
		elseif gameType == e_TYPE_KNIEFSHOOTING then
			g_i3k_ui_mgr:OpenUI(eUIID_KniefShooting)
			g_i3k_ui_mgr:RefreshUI(eUIID_KniefShooting, res.info)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_KniefShooting, "gameStart")
		else
			if res.info then
				g_i3k_game_context:setHitDiglettInfo(res.info)
			end
		end
	elseif res.info.useTimes >= i3k_db_findMooncake[res.info.id].dayTimes then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16391))
	end
end

--点击图片

function i3k_sbean.findMooncake_click(id, itemId, result, btn, index)
	local data = i3k_sbean.finding_your_sister_click_req.new()
	data.id = id
	data.itemId = itemId
	data.result = result
	data.btn = btn
	data.index = index
	i3k_game_send_str_cmd(data, i3k_sbean.finding_your_sister_click_res.getName())
end

function i3k_sbean.finding_your_sister_click_res.handler(res, req)
	if res.ok > 0 then
		if req.result == 0 then
			if i3k_db_findMooncake[req.id].gameType == e_TYPE_MOONCAKE then
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_FindMooncake, "afterChoseFalse", req.btn)
			else
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_HitDiglett, "addTimeLabel")
			end
		elseif req.result > 0 then
			if i3k_db_findMooncake[req.id].gameType == e_TYPE_MOONCAKE then
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_FindMooncake, "afterChoseRight", req.index, req.btn)
			else
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_HitDiglett, "addDiglettCount", req.itemId, 1)
			end
		end
	end
end


--奖励
function i3k_sbean.findMooncake_getItems(id)
	local data = i3k_sbean.finding_your_sister_get_rewards_req.new()
	data.id = id
	i3k_game_send_str_cmd(data,i3k_sbean.finding_your_sister_get_rewards_res.getName())
end

function i3k_sbean.finding_your_sister_get_rewards_res.handler(res, req)
	if res.result > 0 then
		if i3k_db_findMooncake[req.id].gameType == e_TYPE_MOONCAKE then
			g_i3k_ui_mgr:ShowGainItemInfo(i3k_db_findMooncake[req.id].rewardInfo)
			g_i3k_ui_mgr:CloseUI(eUIID_FindMooncake)
		elseif i3k_db_findMooncake[req.id].gameType == e_TYPE_PROTECTMELON then
			g_i3k_ui_mgr:ShowGainItemInfo(i3k_db_findMooncake[req.id].rewardInfo)
			g_i3k_ui_mgr:CloseUI(eUIID_ProtectMelon)
		elseif i3k_db_findMooncake[req.id].gameType == e_TYPE_MEMORYCARD then
			g_i3k_ui_mgr:ShowGainItemInfo(i3k_db_findMooncake[req.id].rewardInfo)
			g_i3k_ui_mgr:CloseUI(eUIID_MemoryCard)
		elseif i3k_db_findMooncake[req.id].gameType == e_TYPE_KNIEFSHOOTING then
			g_i3k_ui_mgr:ShowGainItemInfo(i3k_db_findMooncake[req.id].rewardInfo)
		else
			local callback = function ()
				i3k_sbean.mapcopy_leave()
			end
			g_i3k_ui_mgr:ShowGainItemInfo(i3k_db_findMooncake[req.id].rewardInfo, callback)
		end
	else
		g_i3k_ui_mgr:CloseUI(eUIID_ProtectMelon)
	end
end

function i3k_sbean.finding_your_sister_reconnect.handler(res)
	g_i3k_game_context:setHitDiglettInfo(res.infos[1])
end

---------------------------------------等级封印开启-------------------------------------

--同步
function i3k_sbean.breakSeal_start(npcId)
	local data = i3k_sbean.breaklevel_sync_req.new()
	data.npcId = npcId
	i3k_game_send_str_cmd(data, i3k_sbean.breaklevel_sync_res.getName())
end

function i3k_sbean.breaklevel_sync_res.handler(res, req)
	if req then
	local info = {daytTimes =res.dayDobateTimes, exp = res.exp, dayAddFame = res.dayAddFame, npcId = req.npcId }
	g_i3k_ui_mgr:OpenUI(eUIID_BreakSeal)
	g_i3k_ui_mgr:RefreshUI(eUIID_BreakSeal, info)
	end
end

--捐赠物品
function i3k_sbean.breakSeal_donate(itemID, count, npcId)
	local data = i3k_sbean.breaklevel_donate_req.new()
	data.itemID = itemID
	data.count = count
	data.npcId = npcId
	i3k_game_send_str_cmd(data, i3k_sbean.breaklevel_donate_res.getName())
end

function i3k_sbean.breaklevel_donate_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:UseCommonItem(req.itemID, req.count, AT_BREAK_LEVLE_DONATE)
		i3k_sbean.breakSeal_start(req.npcId)
	end
end

---------------------------------------龙穴任务-------------------------------------
--同步龙穴任务
function i3k_sbean.dragon_hole_task_sync()
	local data = i3k_sbean.dragon_hole_task_sync_req.new()
	i3k_game_send_str_cmd(data, "dragon_hole_task_sync_res")
end

function i3k_sbean.dragon_hole_task_sync_res.handler(bean, req)
	g_i3k_game_context:SetDragonHoleTask(bean.curTaskLib)
	g_i3k_ui_mgr:OpenUI(eUIID_FactionTask)
	g_i3k_ui_mgr:RefreshUI(eUIID_FactionTask)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionTask, "updateDrangonHoleTask", bean)
end

--接取龙穴任务
function i3k_sbean.dragon_hole_task_take(taskId, isClose)
	local data = i3k_sbean.dragon_hole_task_take_req.new()
	data.taskId = taskId
	data.isClose = isClose
	i3k_game_send_str_cmd(data, "dragon_hole_task_take_res")
end

function i3k_sbean.dragon_hole_task_take_res.handler(bean, req)
	if bean.ok > 0 then
		local timeStamp = i3k_game_get_time()
		g_i3k_game_context:AddAcceptDragonHoleTask(req.taskId, 0, timeStamp, 0)
		if req.isClose then
			g_i3k_logic:OpenBattleUI()
			g_i3k_ui_mgr:OpenUI(eUIID_BattleTXAcceptTask)
		else
			i3k_sbean.dragon_hole_task_sync()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("接取失败")
	end
end

--领取任务奖励
function i3k_sbean.dragon_hole_task_reward(taskId)
	local data = i3k_sbean.dragon_hole_task_reward_req.new()
	data.taskId = taskId
	i3k_game_send_str_cmd(data, "dragon_hole_task_reward_res")
end

function i3k_sbean.dragon_hole_task_reward_res.handler(bean, req)
	if bean.ok > 0 then
		local cfg = g_i3k_db.i3k_db_get_dragon_task_cfg(req.taskId)
		local item = {}
		local ctype = g_i3k_game_context:GetRoleType()
		table.insert(item, {id = 66896, count = cfg.partRate[ctype] * cfg.awardPoint})
		table.insert(item, {id = 67400, count = cfg.dragonCrystal})  --龙晶
		for i = 1, 6 do
			if cfg["awardID"..i] ~= 0 then
				table.insert(item, {id = cfg["awardID"..i], count = cfg["awardCount"..i]})
			end
		end
		g_i3k_ui_mgr:ShowGainItemInfo(item)
		g_i3k_game_context:DelAcceptDragonHoleTask(req.taskId)

		local fun = function()
			i3k_sbean.dragon_hole_task_sync()
		end
		local data = i3k_sbean.sect_sync_req.new()
		data.callBack = fun
		i3k_game_send_str_cmd(data,i3k_sbean.sect_sync_res.getName())
	else
		g_i3k_ui_mgr:PopupTipMessage("领奖失败")
	end
end

--快速完成龙穴任务
function i3k_sbean.dragon_hole_quick_finish_task_res.handler(bean,req)
	if bean.ok > 0 then
		local cfg = g_i3k_db.i3k_db_get_quick_finish_task_cfg(g_QUICK_FINISH_TASK_TYPE_LONGXUE)
		g_i3k_game_context:UseCommonItem(cfg.needItemId, cfg.needItemCount, AT_DRAGON_HOLE_QUICK_FINISH_TASK)
		i3k_sbean.dragon_hole_task_reward_res.handler(bean, req)
	else
		g_i3k_ui_mgr:PopupTipMessage("完成失败")
	end
end

--放弃龙穴任务
function i3k_sbean.dragon_hole_task_giveup(taskId)
	local data = i3k_sbean.dragon_hole_task_giveup_req.new()
	data.taskId = taskId
	i3k_game_send_str_cmd(data, "dragon_hole_task_giveup_res")
end

function i3k_sbean.dragon_hole_task_giveup_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:DelAcceptDragonHoleTask(req.taskId)
		i3k_sbean.dragon_hole_task_sync()
	else
		g_i3k_ui_mgr:PopupTipMessage("放弃失败")
	end
end

--刷新龙穴任务
function i3k_sbean.dragon_hole_task_refresh(item)
	local data = i3k_sbean.dragon_hole_task_refresh_req.new()
	data.time = item.time
	data.id = item.id
	data.count = item.count
	i3k_game_send_str_cmd(data, "dragon_hole_task_refresh_res")
end

function i3k_sbean.dragon_hole_task_refresh_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:UseCommonItem(req.id, req.count, AT_DRAGON_TASK_REFRESH)
		i3k_sbean.dragon_hole_task_sync()
	else
		g_i3k_ui_mgr:PopupTipMessage("刷新失败")
	end
end

-----------------奇遇任务
function i3k_sbean.adtask_takeReq(taskId)
	local bean = i3k_sbean.adtask_take_req.new()
	bean.taskId = taskId
	i3k_game_send_str_cmd(bean, i3k_sbean.adtask_take_res.getName())
end

function i3k_sbean.adtask_take_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:setAdventureTask(nil, 1)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateAdventureTaskTag", true)
	end
end

function i3k_sbean.adtask_quit_req(taskId)
	local bean = i3k_sbean.adtask_quit_req.new()
	bean.taskId = taskId
	i3k_game_send_str_cmd(bean, i3k_sbean.adtask_quit_res.getName())
end

function i3k_sbean.adtask_quit_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:setAdventureTask(0, 0)
	end
end

function i3k_sbean.adtask_rewardReq(taskId)
	local bean = i3k_sbean.adtask_reward_req.new()
	bean.taskId = taskId
	i3k_game_send_str_cmd(bean, i3k_sbean.adtask_reward_res.getName())
end

function i3k_sbean.adtask_reward_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:nextAdventureTask()
	end
end


function i3k_sbean.role_trig_adventure.handler(bean)
	--self.trigID:		int32
	g_i3k_game_context:AddTaskToDataList(TASK_CATEGORY_ADVENTURE)
	g_i3k_game_context:setAdventureId(bean.trigID)
	local head = i3k_db_adventure.head[bean.trigID]
	g_i3k_ui_mgr:OpenUI(head.uiId)
	g_i3k_ui_mgr:RefreshUI(head.uiId, bean.trigID, head.force)
	if head.force > 0 then
		g_i3k_game_context:InitAdventureTask(head.firstTaskId)
	else
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateAdventureTask")
	end
end

function i3k_sbean.role_add_adventure.handler(bean)
	--self.adventure:		int32
	--self.reason:		int32
	g_i3k_game_context:addAdventureValue(bean.adventure)
end

function i3k_sbean.role_adventure.handler(bean)
	--self.adventureValue:		int32
	--self.trigID:		int32
	--self.trigEndTime:		int32
	--self.task:		DBAdventureTask
	--self.finished:		map[int32, DBAdventureReward]
	g_i3k_game_context:setAdventure(bean)
	if bean.trigID > 0 then
		g_i3k_game_context:AddTaskToDataList(TASK_CATEGORY_ADVENTURE)
	end
end

-- 接受奇遇任务(第一次触发, taskId: 0 表示拒绝)
function i3k_sbean.adtask_acceptReq(taskId)
	local bean = i3k_sbean.adtask_accept_req.new()
	bean.taskId = taskId
	i3k_game_send_str_cmd(bean, i3k_sbean.adtask_accept_res.getName())
end

function i3k_sbean.adtask_accept_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:InitAdventureTask(req.taskId)
	end
end

function i3k_sbean.adtask_selectReq(taskId)
	local bean = i3k_sbean.adtask_select_req.new()
	bean.taskId = taskId
	i3k_game_send_str_cmd(bean, i3k_sbean.adtask_select_res.getName())
end

function i3k_sbean.adtask_select_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:InitAdventureTask(req.taskId)
	end
end

function i3k_sbean.adtask_total_rewardReq(trigID)
	local bean = i3k_sbean.adtask_total_reward_req.new()
	bean.trigID = trigID
	i3k_game_send_str_cmd(bean, i3k_sbean.adtask_total_reward_res.getName())
end

function i3k_sbean.adtask_total_reward_res.handler(res, req)
	if res.ok > 0 then
		local data = g_i3k_game_context:getAdventure()
		local items = {}
		for k, v in pairs(data.finished[req.trigID].rewards) do
			table.insert(items, {id = k, count = v})
		end
		g_i3k_ui_mgr:ShowGainItemInfo(items)
		g_i3k_game_context:finishAdventureTask(req.trigID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DailyTask,"updateAdventureState", req.trigID)
	end
end

function i3k_sbean.tmtask_get.handler(bean)
	--self.taskID
	--self.receiveTime
	g_i3k_game_context:setLimitTimeTask(bean)
end

-- 重新激活限时任务
function i3k_sbean.tmtask_reactiveReq()
	local bean = i3k_sbean.tmtask_reactive_req.new()
	i3k_game_send_str_cmd(bean, i3k_sbean.tmtask_reactive_res.getName())
end

function i3k_sbean.tmtask_reactive_res.handler(res)
	--self.ok:		int32
	if res.ok then
		--self.taskID:		int32
		--self.receiveTime:		int32
		g_i3k_game_context:setLimitTimeTask(res)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "resetLimitTaskTimer")
	end
end

function i3k_sbean.tmtask_finish.handler(bean)
	if bean.taskID > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17012))
	end
end

--帮派商路任务
function i3k_sbean.sect_trade_routeReq()
	local bean = i3k_sbean.sect_trade_route_sync_req.new()
	i3k_game_send_str_cmd(bean, i3k_sbean.sect_trade_route_sync_res.getName())
end

function i3k_sbean.sect_trade_route_sync_res.handler(res)
	--self.lvl:		int32
	--self.curRefreshTasks:		vector[int32]
	--self.curStar:		int32
	--self.curTask:		int32
	--self.curValue:		int32
	--self.curReceiveTime:		int32
	--self.lastRefreshTasksTime:		int32
	--self.refreshTime:		int32
	g_i3k_ui_mgr:OpenUI(eUIID_factionBusiness)
	g_i3k_ui_mgr:RefreshUI(eUIID_factionBusiness, res.sectTradRoute)
end

function i3k_sbean.sect_trade_route_cancelReq(taskID)
	local bean = i3k_sbean.sect_trade_route_cancel_req.new()
	bean.taskID = taskID
	i3k_game_send_str_cmd(bean, i3k_sbean.sect_trade_route_cancel_res.getName())
end

function i3k_sbean.sect_trade_route_cancel_res.handler(res)
	if res.ok > 0 then
		g_i3k_game_context:setFactionBusinessTask(0, 0, 0)
		g_i3k_game_context:removeTaskData(TASK_CATEGORY_FCBS)
		i3k_sbean.sect_trade_routeReq()
	end
end

function i3k_sbean.sect_trade_route_receiveReq(taskID)
	local bean = i3k_sbean.sect_trade_route_receive_req.new()
	bean.taskID = taskID
	i3k_game_send_str_cmd(bean, i3k_sbean.sect_trade_route_receive_res.getName())
end

function i3k_sbean.sect_trade_route_receive_res.handler(res, req)
	if res.receiveTime > 0 then
		g_i3k_game_context:initFactionBusinessTask(req.taskID)
		g_i3k_logic:OpenBattleUI(function( )
			g_i3k_ui_mgr:OpenUI(eUIID_BattleTXAcceptTask)
		end)
	end
end

--帮派商路快速完成
function i3k_sbean.sect_trade_route_one_key_finish(taskID)
	local data = i3k_sbean.sect_trade_route_one_key_finish_req.new()
	data.taskID = taskID
	i3k_game_send_str_cmd(data, "sect_trade_route_one_key_finish_res")
end
function i3k_sbean.sect_trade_route_one_key_finish_res.handler(res, req)
	if res.ok > 0 then
		local cfg = g_i3k_db.i3k_db_get_quick_finish_task_cfg(g_QUICK_FINISH_TASK_TYPE_BUSINESS)
		g_i3k_game_context:UseCommonItem(cfg.needItemId, cfg.needItemCount)
		local data = g_i3k_game_context:getFactionBusinessTask()
		if data.id > 0 and data.id == req.taskID then
			g_i3k_game_context:setFactionBusinessTask(0, 0, 0)
			g_i3k_game_context:removeTaskData(TASK_CATEGORY_FCBS)
		end
		local cfg = i3k_db_factionBusiness_task[req.taskID]
		local tmp_items = {}

		if cfg.exp ~= 0 then
			table.insert(tmp_items,{id = g_BASE_ITEM_EXP,count = cfg.exp})
		end

		for i=1,6 do
			local tmp_id =  string.format("awardID%s",i)
			local awardID = cfg[tmp_id]
			local tmp_count = string.format("awardCount%s",i)
			local awardCount = cfg[tmp_count]
			if awardID ~= 0 then
				local t = {id = awardID,count = awardCount}
				table.insert(tmp_items,t)
			end
		end
		g_i3k_ui_mgr:ShowGainItemInfo(tmp_items)
		i3k_sbean.sect_trade_routeReq()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5487))
	end
end
function i3k_sbean.sect_trade_route_finishReq(taskID)
	local bean = i3k_sbean.sect_trade_route_finish_req.new()
	bean.taskID = taskID
	i3k_game_send_str_cmd(bean, i3k_sbean.sect_trade_route_finish_res.getName())
end

function i3k_sbean.sect_trade_route_finish_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:setFactionBusinessTask(0, 0, 0)
		g_i3k_game_context:removeTaskData(TASK_CATEGORY_FCBS)

		local cfg = i3k_db_factionBusiness_task[req.taskID]
		local tmp_items = {}

		if cfg.exp ~= 0 then
			table.insert(tmp_items,{id = g_BASE_ITEM_EXP,count = cfg.exp})
		end

		for i=1,6 do
			local tmp_id =  string.format("awardID%s",i)
			local awardID = cfg[tmp_id]
			local tmp_count = string.format("awardCount%s",i)
			local awardCount = cfg[tmp_count]
			if awardID ~= 0 then
				local t = {id = awardID,count = awardCount}
				table.insert(tmp_items,t)
			end
		end
		g_i3k_ui_mgr:ShowGainItemInfo(tmp_items)

		i3k_sbean.sect_trade_routeReq()
	end
end

function i3k_sbean.sect_trade_route_buy_starReq(buyCnt)
	local bean = i3k_sbean.sect_trade_route_buy_star_req.new()
	bean.buyCnt = buyCnt
	i3k_game_send_str_cmd(bean, i3k_sbean.sect_trade_route_buy_star_res.getName())
end

function i3k_sbean.sect_trade_route_buy_star_res.handler(res, req)
	if res.ok > 0 then
		local items = {}
		for _, v in ipairs(i3k_db_factionBusiness.cfg.oneStarAward) do
			table.insert(items, {id = v.id, count = v.count * req.buyCnt})
		end
		table.insert(items, {id = g_BASE_ITEM_EXP, count = req.buyCnt * i3k_db_factionBusiness.cfg.expRate * i3k_db_exp[g_i3k_game_context:GetLevel()].businessExp})
		g_i3k_ui_mgr:ShowGainItemInfo(items)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17122))
		g_i3k_game_context:UseBaseItem(-g_BASE_ITEM_DIAMOND, req.buyCnt*i3k_db_factionBusiness.cfg.oneStarCost, AT_FCBS_Task)
		i3k_sbean.sect_trade_routeReq()
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_factionBusiness, "updateBuystar")
	end
end

function i3k_sbean.sect_trade_route_curtask.handler(bean)
	g_i3k_game_context:setFactionBusinessHonor(bean.lvl)
	if bean.taskID > 0 then
		g_i3k_game_context:setFactionBusinessTask(bean.taskID, bean.curValue, bean.receiveTime)
		g_i3k_game_context:AddTaskToDataList(TASK_CATEGORY_FCBS, bean.receiveTime)
	else
		g_i3k_game_context:removeTaskData(TASK_CATEGORY_FCBS)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateTaskInfo")
	end
end

--百万答题同步
function i3k_sbean.million_answer_sync()
	local bean = i3k_sbean.million_answer_sync_req.new()
	i3k_game_send_str_cmd(bean, i3k_sbean.million_answer_sync_res.getName())
end

function i3k_sbean.million_answer_sync_res.handler(res, req)
	if res.ok > 0 then
		local info = {allPlayer = res.allPlayer, roleInfo = res.roleInfo}
		if g_i3k_ui_mgr:GetUI(eUIID_MillionsAnswer) then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_MillionsAnswer, "refreshInfoData", info)
		else
			g_i3k_ui_mgr:OpenUI(eUIID_MillionsAnswer)
			g_i3k_ui_mgr:RefreshUI(eUIID_MillionsAnswer, info)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("活动失效")
	end
end

--百万答题预约
function i3k_sbean.million_answer_reserve()
	local bean = i3k_sbean.million_answer_reserve_req.new()
	i3k_game_send_str_cmd(bean, i3k_sbean.million_answer_reserve_res.getName())
end

function i3k_sbean.million_answer_reserve_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_MillionsAnswer, "updateAdvanceBtnState")

		local usercfg = g_i3k_game_context:GetUserCfg()
		usercfg:SetIsShowAnswerResult(false)  --重置状态
		g_i3k_ui_mgr:PopupTipMessage("预约成功")
	end
end

--百万答题点击
function i3k_sbean.million_answer_click(questionID, answer)
	local bean = i3k_sbean.million_answer_click_req.new()
	bean.questionID = questionID
	bean.answer = answer
	i3k_game_send_str_cmd(bean, i3k_sbean.million_answer_click_res.getName())
end

function i3k_sbean.million_answer_click_res.handler(res, req)

end

--百万答题获取获胜玩家姓名
function i3k_sbean.million_answer_name(callback)
	local bean = i3k_sbean.million_answer_name_req.new()
	bean.callback = callback
	i3k_game_send_str_cmd(bean, i3k_sbean.million_answer_name_res.getName())
end

function i3k_sbean.million_answer_name_res.handler(res, req)
	if req.callback then
		req.callback(res.names, res.allFinishNum)
	end
end

--珍珑棋局
function i3k_sbean.chess_game_sync.handler(bean)
	if bean.chessGame then
		g_i3k_game_context:setChessTask(bean.chessGame, 1)
		if bean.chessGame.loopLvl == 1 and bean.chessGame.curTaskID == 0 and bean.chessGame.needUpLoopLvl == 0 then
			g_i3k_game_context:removeTaskData(TASK_CATEGORY_CHESS)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateTaskInfo")
		else
			if bean.chessGame.isLoopOver == 1 then
				g_i3k_game_context:removeTaskData(TASK_CATEGORY_CHESS)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateTaskInfo")
			else
				g_i3k_game_context:AddTaskToDataList(TASK_CATEGORY_CHESS, bean.chessGame.curReceiveTime ~= 0 and bean.chessGame.curReceiveTime or i3k_game_get_time())
			end
		end
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateTaskInfo")
	end
end

--珍珑棋局接取
function i3k_sbean.chess_game_receive()
	local bean = i3k_sbean.chess_game_receive_req.new()
	bean.taskID = 0
	i3k_game_send_str_cmd(bean, "chess_game_receive_res")
end

function i3k_sbean.chess_game_receive_res.handler(res, req)
	if res.ok > 0 then
		--播放成功特效
		g_i3k_ui_mgr:CloseUI(eUIID_ChessTaskAccept)
		g_i3k_game_context:updateChessTask(res.taskID, res.receiveTime, 1)
		g_i3k_game_context:removeTaskData(TASK_CATEGORY_CHESS)
		
		g_i3k_game_context:AddTaskToDataList(TASK_CATEGORY_CHESS, res.receiveTime)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateTaskInfo")
		g_i3k_game_context:CheckSceneTriggerEffect(i3k_db_chess_task[res.taskID], 1)
		i3k_sbean.auto_chess_game_trans()
		--[[local chess = g_i3k_game_context:getChessTask()
		if chess.loopLvl == 1 then
			g_i3k_ui_mgr:OpenUI(eUIID_ChessTaskCross)
			g_i3k_ui_mgr:RefreshUI(eUIID_ChessTaskCross)
		else
			i3k_sbean.auto_chess_game_trans()
		end--]]
	else
		g_i3k_ui_mgr:PopupTipMessage("接取失败")
	end
end

--珍珑棋局取消
function i3k_sbean.chess_game_cancel(taskId)
	local bean = i3k_sbean.chess_game_cancel_req.new()
	bean.taskID = taskId
	i3k_game_send_str_cmd(bean, "chess_game_cancel_res")
end

function i3k_sbean.chess_game_cancel_res.handler(res, req)
	g_i3k_game_context:deleteChessTask()
	--g_i3k_game_context:setChessTask()
end

--珍珑棋局完成
function i3k_sbean.chess_game_finish(taskId)
	local bean = i3k_sbean.chess_game_finish_req.new()
	bean.taskID = taskId
	i3k_game_send_str_cmd(bean, "chess_game_finish_res")
end

function i3k_sbean.chess_game_finish_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:setChessTask(res.chessGame, 0)
		g_i3k_game_context:updateChessTaskFinishTimes(1)
		--g_i3k_ui_mgr:PopupTipMessage(string.format("loop = %s, isLoopOver = %s", res.chessGame.loopLvl, res.chessGame.isLoopOver))
		if res.chessGame.isLoopOver ~= 1 then
			if res.chessGame.needUpLoopLvl > 0 then
				g_i3k_game_context:removeTaskData(TASK_CATEGORY_CHESS)
				g_i3k_game_context:AddTaskToDataList(TASK_CATEGORY_CHESS, res.receiveTime)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateTaskInfo")
			else
				i3k_sbean.chess_game_receive()
			end
		else
			g_i3k_game_context:removeTaskData(TASK_CATEGORY_CHESS)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateTaskInfo")
			g_i3k_ui_mgr:OpenUI(eUIID_ChessTaskEnd)
			g_i3k_ui_mgr:RefreshUI(eUIID_ChessTaskEnd, 1)
		end
	end
end

--珍珑棋局解困
function i3k_sbean.chess_game_uplooplvl(id, consume)
	local bean = i3k_sbean.chess_game_uplooplvl_req.new()
	bean.costPer = id
	bean.consume = consume
	i3k_game_send_str_cmd(bean, "chess_game_uplooplvl_res")
end

function i3k_sbean.chess_game_uplooplvl_res.handler(res, req)
	if res.ok > 0 then
		local useChess = math.floor(req.consume * i3k_db_chess_board_cfg.usePersent[req.costPer] / 10000)
		g_i3k_game_context:setChessTask(res.chessGame, 0)
		if res.chessGame.needUpLoopLvl == 1 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17276, useChess))
			g_i3k_ui_mgr:RefreshUI(eUIID_ChessTaskThink)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateChessTask")
		else
			g_i3k_ui_mgr:OpenUI(eUIID_ChessTaskAnimate)
			g_i3k_ui_mgr:CloseUI(eUIID_ChessTaskThink)
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17275, useChess))
			--i3k_sbean.chess_game_receive()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("思考失败")
	end
end

--珍珑棋局通知服务器完成任务
function i3k_sbean.chess_game_notice_task_finished(isExtraReward)
	local data = i3k_sbean.chess_game_notice_task_finish.new()
	data.isExtraReward = isExtraReward
	i3k_game_send_str_cmd(data)
end

--珍珑棋局接取后自动传送
function i3k_sbean.auto_chess_game_trans()
	local data = i3k_sbean.chess_game_trans.new()
	i3k_game_send_str_cmd(data)
end

--珍珑棋局排行榜
function i3k_sbean.chess_game_rank_get()
	local data = i3k_sbean.chess_game_rank_get_req.new()
	i3k_game_send_str_cmd(data, "chess_game_rank_get_res")
end

function i3k_sbean.chess_game_rank_get_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_ChessTaskRank)
		g_i3k_ui_mgr:RefreshUI(eUIID_ChessTaskRank, res)
	end
end

--记录任务访问点
function i3k_sbean.task_log_point(taskPointId, index)
	local data = i3k_sbean.task_log_point_req.new()
	data.taskPointId = taskPointId
	data.index = index
	i3k_game_send_str_cmd(data, "task_log_point_res")
end

function i3k_sbean.task_log_point_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetTaskDataByTaskType(req.taskPointId, g_TASK_SCENE_MINE, req.index)
		g_i3k_game_context:playSceneMineAction(req.taskPointId, req.index)
		g_i3k_game_context:clearMineTaskInfo()
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
		g_i3k_ui_mgr:PopupTipMessage("布置成功")
	else
		g_i3k_ui_mgr:PopupTipMessage("布置失败")
	end
end

---------------------------- <外传> --------------------------
--外传副本解锁外传
function i3k_sbean.biography_unlock(biographyID, nodeData)
	if nodeData.info.allOk then 
		local data = i3k_sbean.biography_unlock_req.new()
		data.biographyID = biographyID
		i3k_game_send_str_cmd(data, "biography_unlock_res")
		-- i3k_sbean.biography_unlock_res.handler({ok = 1}, data)
	else 
		g_i3k_ui_mgr:PopupTipMessage("解锁条件不满足")
	end
end

function i3k_sbean.biography_unlock_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:setOutCastCurUnlockID(req.biographyID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_UnlockOutcastTips, "onUnlock", req.biographyID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DailyTask, "updateOutCastScroll")
	end
end

--外传副本开始副本
function i3k_sbean.biography_start_mapcopy(cfg)
	if g_i3k_game_context:checkEnterOutCast(true) then 
		local data = i3k_sbean.biography_start_mapcopy_req.new()
		data.mapID = cfg.dungeonID
		data.cfg = cfg
		i3k_game_send_str_cmd(data, "biography_start_mapcopy_res")
		-- i3k_sbean.biography_start_mapcopy_res.handler({ok = 1}, data)
	end 
end

function i3k_sbean.biography_start_mapcopy_res.handler(res, req)
	if res.ok > 0 then
	end
end

--外传副本接任务
function i3k_sbean.biography_take_task(taskID)
	local data = i3k_sbean.biography_take_task_req.new()
	data.taskID = taskID
	i3k_game_send_str_cmd(data, "biography_take_task_res")
end

function i3k_sbean.biography_take_task_res.handler(res, req)
	if res.ok > 0 then
		local outCastInfo = g_i3k_game_context:getOutCastInfo()
		local cfg = i3k_db_out_cast_task[req.taskID]
		outCastInfo.curTaskID = req.taskID
		outCastInfo.curTaskValue = g_i3k_game_context:InitTaskValue(cfg.taskType, cfg.arg1, cfg.arg2)
		outCastInfo.curTaskReward = 0
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_OutCastBattle,"onShowData")
	end
end

--外传副本任务提交物品
function i3k_sbean.biography_submit_item(itemID, itemCnt)
	local data = i3k_sbean.biography_submit_item_req.new()
	data.itemID = itemID
	data.itemCnt = itemCnt
	i3k_game_send_str_cmd(data, "biography_submit_item_res")
end

function i3k_sbean.biography_submit_item_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("-- debug 外传副本任务提交物品 --")
	end
end

--外传副本完成任务
function i3k_sbean.biography_finish_task(taskID, callfunc)
	local data = i3k_sbean.biography_finish_task_req.new()
	data.taskID = taskID
	data.callfunc = callfunc
	i3k_game_send_str_cmd(data, "biography_finish_task_res")
end

function i3k_sbean.biography_finish_task_res.handler(res, req)
	if res.ok > 0 then
		local cfg = i3k_db_out_cast_task[req.taskID]
		local outCastInfo = g_i3k_game_context:getOutCastInfo()
		outCastInfo.curTaskValue = 0 
		outCastInfo.curTaskReward = 1 -- 任务奖励已领取
		-- outCastInfo.curTaskID = cfg.afterTaskID
		if cfg.afterTaskID == 0 then -- 这个副本没有后续任务了
			outCastInfo.lastUnlockID = outCastInfo.curUnlockID -- 当前副本已完成
			outCastInfo.curUnlockID = 0
		else 
			g_i3k_ui_mgr:ShowGainItemInfoByCfg_safe(cfg.awards)
		end
		if req.callfunc then 
			req.callfunc()
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_OutCastBattle,"onShowData")
	end
end

--外传副本领取完成奖励
function i3k_sbean.biography_take_reward(nodeData)
	local data = i3k_sbean.biography_take_reward_req.new()
	data.bID = nodeData.cfg.id
	data.nodeData = nodeData
	i3k_game_send_str_cmd(data, "biography_take_reward_res")
end

function i3k_sbean.biography_take_reward_res.handler(res, req)
	if res.ok > 0 then
		local cfg = i3k_db_out_cast[req.bID]
		g_i3k_ui_mgr:ShowGainItemInfoByCfg_safe(cfg.awards)
		g_i3k_game_context:setOutCastReward(req.bID, true)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DailyTask, "updateOutCastScroll")
	end
end

--外传副本同步条件
function i3k_sbean.biography_sync_conditions(nodeData)
	local data = i3k_sbean.biography_sync_conditions_req.new()
	data.level = nodeData.cfg.id
	data.nodeData = nodeData
	i3k_game_send_str_cmd(data, "biography_sync_conditions_res")
end

function i3k_sbean.biography_sync_conditions_res.handler(res, req)
	--self.con:		map[int32, int32]	
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_DailyTask, "onOutCastCondition", req.nodeData, res.con)
end

-- 外传副本登陆同步
function i3k_sbean.biography_login_sync.handler(res)
	g_i3k_game_context:setOutCastInfo(res.biography)
	g_i3k_game_context:clearOutCastReward()
	for index, id in ipairs(res.biography.rewards) do 
		g_i3k_game_context:setOutCastReward(id, true)
	end	
end

---------------------------- </外传> --------------------------

--通知服务器对话npc
function i3k_sbean.notify_adventure_npc_chat(npcID)
	local data = i3k_sbean.adventure_npc_chat.new()
	data.npcID = npcID
	i3k_game_send_str_cmd(data)
end

--节日限时任务
--登陆同步节日限时任务
function i3k_sbean.role_festival_tasks.handler(res)
	g_i3k_game_context:setFestivalLimitTask(res.tasks)
end

--节日限时任务开始
function i3k_sbean.festival_task_enter(festivalId, index)
	local data = i3k_sbean.festival_task_enter_req.new()
	data.festivalId = festivalId
	data.index = index
	i3k_game_send_str_cmd(data, "festival_task_enter_res")
end

function i3k_sbean.festival_task_enter_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:startFestivalSeries(req.festivalId, req.index)
		local groupId = i3k_db_festival_cfg[req.festivalId].taskGroupId[req.index]
		g_i3k_game_context:GetFestivalTaskDialogue(groupId, i3k_db_festival_task[groupId][1].taskId)
	else
		--g_i3k_ui_mgr:PopupTipMessage("fail start")
	end
end

--节日限时任务接取
function i3k_sbean.festival_task_accept(festivalId, groupId, taskId)
	local data = i3k_sbean.festival_task_accept_req.new()
	data.festivalId = festivalId
	data.groupId = groupId
	data.taskId = taskId
	i3k_game_send_str_cmd(data, "festival_task_accept_res")
end

function i3k_sbean.festival_task_accept_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:addFestivalLimitTask(req.festivalId, {groupId = req.groupId, index = req.taskId, value = 0, state = 1})
		g_i3k_game_context:AddTaskToDataList(g_i3k_db.i3k_db_get_festival_task_hash_id(req.groupId, req.taskId))
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateTaskInfo")
		local npcId = i3k_db_festival_cfg[req.festivalId].npcId
		if req.taskId == 1 and not g_i3k_game_context:getFestivalNpcHeadIcon(i3k_db_npc[npcId], "npcIconPath") then
			g_i3k_logic:ChangePowerRepNpcTitleVisible(npcId, false)
		end
	else
		--g_i3k_ui_mgr:PopupTipMessage("fail get")
	end
end

--节日限时任务完成
function i3k_sbean.festival_task_finish(festivalId, groupId, taskId, callback)
	local data = i3k_sbean.festival_task_finish_req.new()
	data.festivalId = festivalId
	data.groupId = groupId
	data.taskId = taskId
	data.callback = callback
	i3k_game_send_str_cmd(data, "festival_task_finish_res")
end

function i3k_sbean.festival_task_finish_res.handler(res, req)
	if res.ok > 0 then
		if req.callback then
			req.callback()
		end
		g_i3k_game_context:removeTaskData(g_i3k_db.i3k_db_get_festival_task_hash_id(req.groupId, req.taskId))
		if #i3k_db_festival_task[req.groupId] > req.taskId then
			g_i3k_game_context:addFestivalLimitTask(req.festivalId, {groupId = req.groupId, index = req.taskId + 1, value = 0, state = 0})
			g_i3k_game_context:AddTaskToDataList(g_i3k_db.i3k_db_get_festival_task_hash_id(req.groupId, req.taskId + 1))
		else
			g_i3k_game_context:addFestivalLimitTask(req.festivalId)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateTaskInfo")
	else
		--g_i3k_ui_mgr:PopupTipMessage("fail finish")
	end
end

--通知服务器任务完成
function i3k_sbean.client_log_task(taskType, param1, param2, addValue)
	local data = i3k_sbean.client_log_task_req.new()
	data.taskType = taskType
	data.param1 = param1
	data.param2 = param2
	data.addValue = addValue
	i3k_game_send_str_cmd(data, "client_log_task_res")
end

function i3k_sbean.client_log_task_res.handler(bean, req)
	if bean.ok then
		if req.callback then
			req.callback()
		end
	else
		--g_i3k_ui_mgr:PopupTipMessage("fail finish")
	end
end

----------------------------五绝争霸-----------------------------

-- 五绝争霸信息同步
function i3k_sbean.five_hegemony_sync(state, callback)
	local data = i3k_sbean.five_hegemony_sync_info_req.new()
	data.state = state
	data.callback = callback
	i3k_game_send_str_cmd(data, "five_hegemony_sync_info_res")
end

-- 选择npc
function i3k_sbean.five_hegemony_choose_npc(npcID)
	local data = i3k_sbean.five_hegemony_choose_npc_req.new()
	data.npcID = npcID
	i3k_game_send_str_cmd(data, "five_hegemony_choose_npc_res")
end

-- 选择npc技能
function i3k_sbean.five_hegemony_choose_skill(npcID, skillID)
	local data = i3k_sbean.five_hegemony_choose_skill_req.new()
	data.npcID = npcID
	data.skillID = skillID	
	i3k_game_send_str_cmd(data, "five_hegemony_choose_skill_res")
end

-- 请求回合争斗结果
function i3k_sbean.five_hegemony_round_result(round)
	local data = i3k_sbean.five_hegemony_round_result_req.new()
	data.round = round
	i3k_game_send_str_cmd(data, "five_hegemony_round_result_res")
end

-- 请求弹幕
function i3k_sbean.five_hegemony_barrage(barrageID)
	local data = i3k_sbean.sync_five_hegemony_barrages.new()
	data.barrageID = barrageID
	i3k_game_send_str_cmd(data)
end

-- 发送弹幕
function i3k_sbean.five_hegemony_send_barrage(msg, npcID)
	local data = i3k_sbean.five_hegemony_send_barrage_req.new()
	data.npcID = npcID
	data.msg = msg
	i3k_game_send_str_cmd(data, "five_hegemony_send_barrage_res")
end	

-- 五绝争霸信息同步
	--managerInfo	
		--self.curRound:		int32	
		--self.roleInfo:		FiveHegemonyRoleInfo	
		--self.npcInfo:		vector[FiveHegemonyNpcInfo]	
		--self.chooseResults:		vector[FiveHegemonyFightResult]	
		--self.barrages:		FiveHegemonyBarrageInfo	
		--self.roleInfo:		FiveHegemonyRoleInfo	
			--self.npcID:		int32	
			--self.tempSkillID:		int32	
			--self.skillRound:		int32	
			--self.lastSendTime:		int32	
			--self.rightCnt:		set[int32]	
function i3k_sbean.five_hegemony_sync_info_res.handler(res, req)

	if res.managerInfo and #res.managerInfo.npcInfo > 0 then
		local state = g_i3k_db.i3k_db_get_five_Contend_hegemony_state()
		if state == g_FIVE_CONTEND_HEGEMONY_SHOW then
			g_i3k_game_context:setFiveHegemonyManagerInfo(res.managerInfo)
			g_i3k_ui_mgr:OpenUI(eUIID_FiveHegemonyShow)
			g_i3k_ui_mgr:RefreshUI(eUIID_FiveHegemonyShow)
			return 
		end
		if req.state == g_HEGEMONY_PROTOCOL_STATE_SYNC then
			g_i3k_game_context:setFiveHegemonyManagerInfo(res.managerInfo)
			g_i3k_ui_mgr:OpenUI(eUIID_FiveHegemony)
			g_i3k_ui_mgr:RefreshUI(eUIID_FiveHegemony, res.managerInfo)
		elseif req.state == g_HEGEMONY_PROTOCOL_STATE_CHOOSE then
			g_i3k_game_context:setFiveHegemonyManagerInfo(res.managerInfo)
			if req.callback then
				req.callback()
			end
		else
			local cfg = i3k_db_five_contend_hegemony.cfg
			local hegemonyInfo = g_i3k_game_context:getFiveHegemonyManagerInfo()
			if res.managerInfo.curRound <= 0 or (hegemonyInfo and res.managerInfo.curRound == hegemonyInfo.curRound and res.managerInfo.curRound ~= cfg.roundCount) then
				g_i3k_coroutine_mgr:StartCoroutine(function ()
					g_i3k_coroutine_mgr.WaitForSeconds(1)
					i3k_sbean.five_hegemony_sync(req.state)
				end)
			else
				g_i3k_game_context:setFiveHegemonyManagerInfo(res.managerInfo)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_FiveHegemony,"updateRound", res.managerInfo)
			end
			
		end
		if res.managerInfo.roleInfo then
			g_i3k_game_context:setHegemonyShootMsgSentTime(res.managerInfo.roleInfo.lastSendTime)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17832))
	end
end
	
-- 选择npc
function i3k_sbean.five_hegemony_choose_npc_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_ANSWER_QUE, 1)
		callback = function()
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_FiveHegemony,"selectNpc", req.npcID)
		end
		i3k_sbean.five_hegemony_sync(g_HEGEMONY_PROTOCOL_STATE_CHOOSE, callback)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17833))
	end
end

-- 选择npc技能
function i3k_sbean.five_hegemony_choose_skill_res.handler(res, req)	
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FiveHegemony,"chooseSkillResult", req.skillID)
	else
		g_i3k_ui_mgr:PopupTipMessage("选择错误")
	end
	
end

-- 请求回合争斗结果
--self.result:		FiveHegemonyFightResult	
	--self.round:		int32	
	--self.skillInfo:		vector[FiveHegemonySkillResult]	
function i3k_sbean.five_hegemony_round_result_res.handler(res, req)	
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FiveHegemony,"updateRound", res.result)	
end

-- 请求弹幕
--self.barrages:		vector[FiveHegemonyBarrageInfo]	
function i3k_sbean.notice_five_hegemony_barrages.handler(bean)
	local barrage = bean.barrages
	g_i3k_game_context:setHegemonyShootMsgData(barrage.id, barrage.barrages)
	for i, v in ipairs(barrage.barrages) do
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FiveHegemony,"showOneShootMsg", v)	
	end
end

-- 发送弹幕
function i3k_sbean.five_hegemony_send_barrage_res.handler(res, req)
	g_i3k_ui_mgr:CloseUI(eUIID_ShootMsg)
	if res.ok > 0 then
		i3k_sbean.five_hegemony_barrage(g_i3k_game_context:getHegemonyShootMsgId())
		g_i3k_game_context:setHegemonyShootMsgSentTime(i3k_game_get_time())
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17834))
	end
end

----------------------------五绝争霸end--------------------------
--挑战任务提交道具
function i3k_sbean.chtask_give_items(groupId, index)
	local bean = i3k_sbean.chtask_give_items_req.new()
	bean.type = groupId
	bean.seq = index
	i3k_game_send_str_cmd(bean, "chtask_give_items_res")
end
function i3k_sbean.chtask_give_items_res.handler(res, req)
	if res.ok > 0 then
		local cfg = i3k_db_challengeTask[req.type][req.seq]
		for k, v in ipairs(cfg.param2) do
			g_i3k_game_context:SetUseItemData(v.id, v.count, nil, AT_USE_SWORN_GIFT_ITEM)
		end
		g_i3k_ui_mgr:CloseUI(eUIID_ChallengeSubmitItems)
		i3k_sbean.sync_chtask_info(1)
	end
end
----------------------------江湖侠探-----------------------
-- 江湖侠探同步
function i3k_sbean.spy_sync.handler(bean)
	g_i3k_game_context:setKnightlyDetectiveData(bean.spy)
	if g_i3k_game_context:isKnightlyDetectiveOpen() then
		local taskId, isMember = g_i3k_game_context:getKnightlyDetectiveTaskId()
		if taskId >= 0 then
			g_i3k_game_context:AddTaskToDataList(TASK_CATEGORY_DETECTIVE, i3k_game_get_time())
		end
	end
end
-- 江湖侠探开启活动
function i3k_sbean.spy_open()
	local bean = i3k_sbean.spy_open_req.new()
	i3k_game_send_str_cmd(bean, "spy_open_res")
end
function i3k_sbean.spy_open_res.handler(res, req)
	g_i3k_game_context:setKnightlyDetectiveData(res.spy)
	g_i3k_ui_mgr:OpenUI(eUIID_KnightlyDetectiveMember)
	g_i3k_ui_mgr:RefreshUI(eUIID_KnightlyDetectiveMember)
	g_i3k_ui_mgr:OpenUI(eUIID_KnightlyDetectiveTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_KnightlyDetectiveTips)
end
-- 江湖侠探调查
function i3k_sbean.spy_survey(memberId)
	local bean = i3k_sbean.spy_survey_req.new()
	bean.memberId = memberId
	i3k_game_send_str_cmd(bean, "spy_survey_res")
end
function i3k_sbean.spy_survey_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_KnightlyDetectiveSurvey)
		g_i3k_game_context:spySurveySuccess(req.memberId)
	end
end
-- 江湖侠探追击
function i3k_sbean.spy_chasing(memberId)
	local bean = i3k_sbean.spy_chasing_req.new()
	bean.memberId = memberId
	i3k_game_send_str_cmd(bean, "spy_chasing_res")
end
function i3k_sbean.spy_chasing_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:spyChasingSuccess(req.memberId)
	end
end
-- 江湖侠探揭露BOSS
function i3k_sbean.spy_finding_boss()
	local bean = i3k_sbean.spy_finding_boss_req.new()
	i3k_game_send_str_cmd(bean, "spy_finding_boss_res")
end
function i3k_sbean.spy_finding_boss_res.handler(res, req)
	if res.ok == 1 then
		g_i3k_game_context:spyExposeBoss(true)
	elseif res.ok == 2 then
		g_i3k_game_context:spyExposeBoss(false)
	end
end
--江湖侠探追击boss
function i3k_sbean.spy_chasing_boss(bossID)
	local bean = i3k_sbean.spy_chasing_boss_req.new()
	bean.bossID = bossID
	i3k_game_send_str_cmd(bean, "spy_chasing_boss_res")
end
function i3k_sbean.spy_chasing_boss_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:spyChasingBoss()
	end
end
----------------------------江湖侠探end---------------------
----------------------------大侠朋友圈----------------------
-- 登陆同步
function i3k_sbean.friend_circle_sync.handler(bean)
	g_i3k_game_context:setSwordsmanCircleData(bean.friendCircle)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "setSwordsmanCircleInfo")
	if bean.friendCircle and bean.friendCircle.curTaskId ~= 0 then
		g_i3k_game_context:AddTaskToDataList(TASK_CATEGORY_SWORDSMAN)
	else
		g_i3k_game_context:removeTaskData(TASK_CATEGORY_SWORDSMAN)
	end
end
-- 打开试炼请求
function i3k_sbean.friend_circle_open()
	local bean = i3k_sbean.friend_circle_open_req.new()
	i3k_game_send_str_cmd(bean, "friend_circle_open_res")
end
function i3k_sbean.friend_circle_open_res.handler(res, req)
	g_i3k_game_context:setSwordsmanCircleData(res.friendCircle)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "loadSwordsmanCircle")
end
-- 接取任务 (status 0=是界面点接取, 1是在NPC对话点接取)
function i3k_sbean.friend_circle_take_task(taskId, status)
	local bean = i3k_sbean.friend_circle_take_task_req.new()
	bean.taskId = taskId
	bean.status = status
	i3k_game_send_str_cmd(bean, "friend_circle_take_task_res")
end
function i3k_sbean.friend_circle_take_task_res.handler(res, req)
	if res.ok > 0 then
		local cfg = i3k_db_swordsman_circle_tasks[req.taskId]
		local value = g_i3k_game_context:InitTaskValue(cfg.type, cfg.arg1, cfg.arg2)
		g_i3k_game_context:setSwordsmanCircleTask(req.taskId, value, req.status)
		if req.status == 0 then
			g_i3k_game_context:AddTaskToDataList(TASK_CATEGORY_SWORDSMAN)
			--g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "changeSwordsmanTasks")
			g_i3k_logic:OpenBattleUI()
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18292))
		else
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateSwordsmanTaskTag")
		end
	end
end
-- 完成任务
function i3k_sbean.friend_circle_finish_task(taskId)
	local bean = i3k_sbean.friend_circle_finish_task_req.new()
	bean.taskId = taskId
	i3k_game_send_str_cmd(bean, "friend_circle_finish_task_res")
end
function i3k_sbean.friend_circle_finish_task_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:removeTaskData(TASK_CATEGORY_SWORDSMAN)
		g_i3k_game_context:setSwordsmanCircleTask(0, 0, 0)
		g_i3k_game_context:addSwordsmanTaskFinish(req.taskId)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateTaskInfo")
		local cfg = i3k_db_swordsman_circle_tasks[req.taskId]
		if cfg.type == g_TASK_SHAPESHIFTING then
			g_i3k_game_context:setConvoyNpcState(false)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "addSwordsmanExp", cfg.friendShip)
	end
end
-- 放弃任务
function i3k_sbean.friend_circle_cancel_task(taskId)
	local bean = i3k_sbean.friend_circle_cancel_task_req.new()
	bean.taskId = taskId
	i3k_game_send_str_cmd(bean, "friend_circle_cancel_task_res")
end
function i3k_sbean.friend_circle_cancel_task_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:removeTaskData(TASK_CATEGORY_SWORDSMAN)
		g_i3k_game_context:setSwordsmanCircleTask(0, 0, 0)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateTaskInfo")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "changeSwordsmanTasks")
		g_i3k_ui_mgr:RefreshUI(eUIID_Task)
		local cfg = i3k_db_swordsman_circle_tasks[req.taskId]
		if cfg.type == g_TASK_SHAPESHIFTING then
			g_i3k_game_context:setConvoyNpcState(false)
		end
	end
end
-- 购买任务次数
function i3k_sbean.friend_circle_buy_task_cnt(cost)
	local bean = i3k_sbean.friend_circle_buy_task_cnt_req.new()
	bean.cost = cost
	i3k_game_send_str_cmd(bean, "friend_circle_buy_task_cnt_res")
end
function i3k_sbean.friend_circle_buy_task_cnt_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:addSwordsmanCircleTaskBuy(1)
		g_i3k_game_context:UseCommonItem(g_BASE_ITEM_DIAMOND, req.cost)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "updateSwordsmanBuyTimes", true)
	end
end
-- 领取每日奖励
function i3k_sbean.friend_circle_take_day_reward(rewards)
	local bean = i3k_sbean.friend_circle_take_day_reward_req.new()
	bean.rewards = rewards
	i3k_game_send_str_cmd(bean, "friend_circle_take_day_reward_res")
end
function i3k_sbean.friend_circle_take_day_reward_res.handler(res, req)
	if res.ok > 0 then
		local info = g_i3k_game_context:getSwordsmanCircleData()
		info.dayTakeReward = 1
		g_i3k_game_context:setSwordsmanCircleData(info)
		local rewards = i3k_clone(req.rewards)
		table.insert(rewards, {id = g_BASE_ITEM_EXP, count = i3k_db_exp[info.refreshLvl].swordsmanCircle * i3k_db_swordsman_circle_cfg.expRate})
		g_i3k_ui_mgr:ShowGainItemInfo(rewards)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "updateSwordsmanReward", true)
	end
end
-- 领取情义值奖励
function i3k_sbean.friend_circle_take_friendship_reward(friendshipLvl, rewards)
	local bean = i3k_sbean.friend_circle_take_friendship_reward_req.new()
	bean.friendshipLvl = friendshipLvl
	bean.rewards = rewards
	i3k_game_send_str_cmd(bean, "friend_circle_take_friendship_reward_res")
end
function i3k_sbean.friend_circle_take_friendship_reward_res.handler(res, req)
	if res.ok > 0 then
		local info = g_i3k_game_context:getSwordsmanCircleData()
		table.insert(info.friendshipRewards, req.friendshipLvl)
		g_i3k_game_context:setSwordsmanCircleData(info)
		g_i3k_ui_mgr:ShowGainItemInfo(req.rewards)
		g_i3k_ui_mgr:RefreshUI(eUIID_SwordsmanFriendship)
	end
end
-- 任务跟多个NPC对话 送信
function i3k_sbean.task_talk_mul_npc(specialId, index)
	local bean = i3k_sbean.task_talk_mul_npc_req.new()
	bean.specialId = specialId
	bean.index = index
	i3k_game_send_str_cmd(bean, "task_talk_mul_npc_res")
end
function i3k_sbean.task_talk_mul_npc_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetTaskDataByTaskType(req.specialId, g_TASK_DELIVER_LETTERS, req.index)
	end
end
-- 任务交换物品
function i3k_sbean.task_exchange_item(taskCategory, itemId, specialId)
	local bean = i3k_sbean.task_exchange_item_req.new()
	bean.taskCategory = taskCategory
	bean.specialId = specialId
	bean.itemId = itemId
	i3k_game_send_str_cmd(bean, "task_exchange_item_res")
end
function i3k_sbean.task_exchange_item_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_SwordsmanCommit)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18296))
		g_i3k_game_context:SetTaskDataByTaskType(req.specialId, g_TASK_CHANGE_ITEM)
	end
end
-----------------------------------大侠朋友圈end-------------------------
-------------------------黄金海岸：赏金任务-------------------------------
function i3k_sbean.takeGlobalWorldTaskReward(taskId, isSpecial, items)
	local bean = i3k_sbean.global_world_task_take_reward_req.new()
	bean.taskId = taskId
	bean.isSpecial = isSpecial
	bean.items = items
	i3k_game_send_str_cmd(bean, "global_world_task_take_reward_res")
end
function i3k_sbean.global_world_task_take_reward_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_GlobalWorldTaskTake)
		g_i3k_game_context:SetGlobalWorldTaskComplete(req.taskId)
		if req.isSpecial ~= 0 then
			local cfg = i3k_db_war_zone_map_task[req.taskId]
			g_i3k_game_context:SetUseItemData(cfg.superItemId, cfg.superItemCount, nil, AT_USE_WAR_ZONE_CARD_ITEM)
		end
		g_i3k_ui_mgr:ShowGainItemInfo(req.items)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Task,"updateShangJinTaskData")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_GlobalWorldMapTask, "refresh")
	end
end
-- 同步外传职业信息
function i3k_sbean.sync_biography_class_info.handler(res)
	g_i3k_game_context:setBiographyCareerInfo(res.info.data)
	g_i3k_game_context:setBiographyCareerLog(res.info.log)
end
-- 开始外传职业副本
function i3k_sbean.biography_class_map_start(classType)
	local bean = i3k_sbean.biography_class_map_start_req.new()
	bean.classType = classType
	i3k_game_send_str_cmd(bean, "biography_class_map_start_res")
end
function i3k_sbean.biography_class_map_start_res.handler(res, req)
	if res.ok > 0 then
	end
end
-- 外传职业副本装备技能
function i3k_sbean.biography_class_skill_select(skills)
	local bean = i3k_sbean.biography_class_skill_select_req.new()
	bean.skills = skills
	i3k_game_send_str_cmd(bean, "biography_class_skill_select_res")
end
function i3k_sbean.biography_class_skill_select_res.handler(res, req)
	if res.ok > 0 then
		for k, v in pairs(req.skills) do
			g_i3k_game_context:changeBiographyCareerEquipSkills(k, v)
		end
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(572))
	end
end
-- 外传职业副本装备心法
function i3k_sbean.biography_class_spirit_install(spiritId)
	local bean = i3k_sbean.biography_class_spirit_install_req.new()
	bean.spiritId = spiritId
	i3k_game_send_str_cmd(bean, "biography_class_spirit_install_res")
end
function i3k_sbean.biography_class_spirit_install_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:changeBiographyCareerEquipQigong(req.spiritId, true)
	end
end
-- 接取外传职业副本任务
function i3k_sbean.biography_class_take_task(classType, taskId)
	local bean = i3k_sbean.biography_class_take_task_req.new()
	bean.classType = classType
	bean.taskId = taskId
	i3k_game_send_str_cmd(bean, "biography_class_take_task_res")
end
function i3k_sbean.biography_class_take_task_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:setBiographyTaskState(1)
		g_i3k_ui_mgr:RefreshUI(eUIID_BiographyTask)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BiographyTask, "doTask")
	end
end
-- 领取外传职业副本任务奖励
function i3k_sbean.biography_class_task_reward(classType, taskId)
	local bean = i3k_sbean.biography_class_task_reward_req.new()
	bean.classType = classType
	bean.taskId = taskId
	i3k_game_send_str_cmd(bean, "biography_class_task_reward_res")
end
function i3k_sbean.biography_class_task_reward_res.handler(res, req)
	if res.ok > 0 then
		local taskCfg = i3k_db_wzClassLand_task[req.classType][req.taskId]
		g_i3k_game_context:setBiographyTaskId(taskCfg.backid)
		g_i3k_game_context:setBiographyTaskValue(0)
		g_i3k_game_context:setBiographyTaskState(0)
		if taskCfg.backid > 0 then
			local state = i3k_db_wzClassLand_task[req.classType][taskCfg.backid].getTaskNpcID == 0 and 1 or 0
			g_i3k_game_context:setBiographyTaskState(state)
			if i3k_db_wzClassLand_task[req.classType][taskCfg.backid].getTaskNpcID == 0 then
				g_i3k_game_context:OpenGetTaskDialogue(i3k_db_wzClassLand_task[req.classType][taskCfg.backid], TASK_CATEGORY_BIOGRAPHY)
			end
			local changeClassID = i3k_db_wzClassLand_task[req.classType][taskCfg.backid].changeClassID
			local hero = i3k_game_get_player_hero()
			if hero then
				hero:updateBiographyCareerProp()
				local equips = {}
				equips = {[eEquipWeapon] = i3k_db_wzClassLand_prop[changeClassID].weapon, [eEquipClothes] = i3k_db_wzClassLand_prop[changeClassID].chest}
				for k, v in pairs(equips) do
					hero:changeEquipSkin(k, v)
				end
			end
			if next(i3k_db_wzClassLand_prop[changeClassID].skills) then
				local skills = {}
				local count = 1
				local equipSkills = g_i3k_game_context:getBiographyCareerEquipSkills()
				for k, v in ipairs(equipSkills) do
					if v == 0 then
						if i3k_db_wzClassLand_prop[changeClassID].skills[count] then
							skills[k] = i3k_db_wzClassLand_prop[changeClassID].skills[count]
							count = count + 1
						else
							break
						end
					end
				end
				if next(skills) then
					i3k_sbean.biography_class_skill_select(skills)
				end
				g_i3k_game_context:addBiographyCareerSkills(i3k_db_wzClassLand_prop[changeClassID].skills)
			end
			if next(i3k_db_wzClassLand_prop[changeClassID].xinfa) then
				g_i3k_game_context:addBiographyCareerQigong(i3k_db_wzClassLand_prop[changeClassID].xinfa)
			end
			if next(i3k_db_wzClassLand_prop[changeClassID].skills) or next(i3k_db_wzClassLand_prop[changeClassID].xinfa) then
				g_i3k_ui_mgr:OpenUI(eUIID_BiographySkillsUnlock)
				g_i3k_ui_mgr:RefreshUI(eUIID_BiographySkillsUnlock, i3k_db_wzClassLand_prop[changeClassID].skills, i3k_db_wzClassLand_prop[changeClassID].xinfa)
			end
			local world = i3k_game_get_world()
			if world then
				world:RefreshBiographyNpc()
			end
		else
			--todo倒计时退出副本
			g_i3k_ui_mgr:OpenUI(eUIID_BiographyMapExit)
			g_i3k_ui_mgr:RefreshUI(eUIID_BiographyMapExit)
			g_i3k_game_context:setBiographyFinished(req.classType)
		end
		g_i3k_ui_mgr:RefreshUI(eUIID_BiographyTask)
		g_i3k_game_context:CheckSceneTriggerEffect(taskCfg, SCENE_EFFECT_CONDITION.finish)
	end
end
-- 外传职业副本卸载心法
function i3k_sbean.biography_class_spirit_uninstall(spiritId)
	local bean = i3k_sbean.biography_class_spirit_uninstall_req.new()
	bean.spiritId = spiritId
	i3k_game_send_str_cmd(bean, "biography_class_spirit_uninstall_res")
end
function i3k_sbean.biography_class_spirit_uninstall_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:changeBiographyCareerEquipQigong(req.spiritId, false)
	end
end
-- 外传副本变更职业
function i3k_sbean.biography_class_change_profession(classType, tlvl, bwType, hair, face)
	local bean = i3k_sbean.biography_class_change_profession_req.new()
	bean.classType = classType
	bean.tlvl = tlvl
	bean.bwType = bwType
	bean.hair = hair
	bean.face = face
	i3k_game_send_str_cmd(bean, "biography_class_change_profession_res")
end
function i3k_sbean.biography_class_change_profession_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:clearItemCheckList()
		i3k_sbean.role_logout()
	end
end
-- 外传变更职业反悔
function i3k_sbean.biography_class_regret_profession(classType, tlvl, bwType, hair, face)
	local bean = i3k_sbean.biography_class_regret_profession_req.new()
	bean.classType = classType
	bean.tlvl = tlvl
	bean.bwType = bwType
	bean.hair = hair
	bean.face = face
	i3k_game_send_str_cmd(bean, "biography_class_regret_profession_res")
end
function i3k_sbean.biography_class_regret_profession_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:clearItemCheckList()
		i3k_sbean.role_logout()
	end
end
-- 领取宝箱奖励
function i3k_sbean.biography_class_receive_box_reward(classType)
	local bean = i3k_sbean.biography_class_receive_box_reward_req.new()
	bean.classType = classType
	i3k_game_send_str_cmd(bean, "biography_class_receive_box_reward_res")
end
function i3k_sbean.biography_class_receive_box_reward_res.handler(res, req)
	if res.ok > 0 then
		local data = g_i3k_game_context:getBiographyCareerInfo()
		local rewards = i3k_db_wzClassLand[req.classType].rewards
		data[req.classType].boxReward = 1
		g_i3k_game_context:setBiographyCareerInfo(data)
		local gift = {}
		for i, v in ipairs(rewards) do
			gift[i] = { id = v.rewordBox, count = v.rewordCountBox}
		end 
		g_i3k_ui_mgr:ShowGainItemInfo(gift)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_OutCareerPractice,"updateBoxState")
	end
end
-- 进入地图同步职业
function i3k_sbean.sync_biography_class_class_type.handler(bean)
	g_i3k_game_context:setCurBiographyCareerId(bean.classType)
	local world = i3k_game_get_world();
	local player = i3k_game_get_player()
	local hero = i3k_game_get_player_hero()
	if player and not hero._inBiographyCareer then
		world:OnPlayerEnterWorld(nil);
		player:SetBiographyCareerEntity(bean.classType)
		world:OnPlayerEnterWorld(player);
		world:RefreshBiographyNpc()
	end
end
--通知服务器完成任务
function i3k_sbean.task_complete_notice_gs(condition, id, callback)
	local data = i3k_sbean.task_complete_notice_gs_req.new()
	data.condType = condition
	data.addParam1 = id
	data.callback = callback
	i3k_game_send_str_cmd(data, "task_complete_notice_gs_res")
end
function i3k_sbean.task_complete_notice_gs_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetTaskDataByTaskType(req.addParam1, req.condType)
		if req.callback then
			req.callback()
		end
	end
end
