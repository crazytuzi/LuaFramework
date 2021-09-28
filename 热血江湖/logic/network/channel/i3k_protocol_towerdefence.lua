
------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/network/channel/i3k_channel");

-----------------------------------
-- 开始挑战
function i3k_sbean.towerdefence_start(mapID)
	if i3k_check_resources_downloaded(mapID) then
	local data = i3k_sbean.towerdefence_start_req.new()
	data.mapID = mapID
	i3k_game_send_str_cmd(data, "towerdefence_start_res")
	end
end

function i3k_sbean.towerdefence_start_res.handler(bean, req)
	if bean.ok == 1 then
		--g_i3k_ui_mgr:PopupTipMessage(string.format("进入%s", i3k_db_defend_cfg[req.mapID].descName))
	end
end

-- 副本开始
function i3k_sbean.role_towerdefence_start.handler(bean)
	g_i3k_game_context:addTowerDefenceDayEnterTimes(bean.mapID) --进入次数
	g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_TOWER_DEFENCE, bean.mapID)
end

-- 副本结束
function i3k_sbean.role_towerdefence_end.handler(bean)
	
end

-- 副本结果
function i3k_sbean.role_towerdefence_result.handler(bean)
	g_i3k_ui_mgr:OpenUI(eUIID_DefendResult)
	g_i3k_ui_mgr:RefreshUI(eUIID_DefendResult, bean.score, bean.count, bean.useTime, bean.rewards)	
	local time = 0
	function update(dTime)
		time = time+dTime
		local closeTime
		closeTime = i3k_db_common.wipe.autoCloseTime+i3k_db_common.wipe.autoFlipCardTime
		if time>=closeTime then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(sc)
			g_i3k_ui_mgr:CloseUI(eUIID_DefendResult)
		else
			local haveTime = math.ceil(closeTime - time)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_DefendResult, "updateSchedule", haveTime)
		end
	end
	sc=cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0.1, false)
end

-- 翻牌抽奖
function i3k_sbean.towerdefence_selectcard(cardNO)
	if g_i3k_game_context:GetCurrMapCanReward() == 0 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15420))
	end
	local data = i3k_sbean.towerdefence_selectcard_req.new()
	data.cardNo = cardNO
	i3k_game_send_str_cmd(data, "towerdefence_selectcard_res")
end

-- 手动翻牌抽奖回应
function i3k_sbean.towerdefence_selectcard_res.handler(bean, req)
	local item = bean.item
	if item then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DefendResult, "openReward", item)
	else
		g_i3k_ui_mgr:PopupTipMessage("失败，再翻一次")
	end
end

-- 自动翻牌抽奖
function i3k_sbean.role_towerdefence_autocard.handler(bean)
	local item = bean.item
	if item then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DefendResult, "openRandom", item)
	else
		g_i3k_ui_mgr:PopupTipMessage("没有得到任何奖励")
	end
end

-- 同步守护副本信息
function i3k_sbean.role_towerdefence_info.handler(bean)
	g_i3k_game_context:setTowerDefenceTmpInfo(bean.score, bean.count)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_DefendSummary, "updatPercent")
end

-- 剩余多少血量喊话
function i3k_sbean.towerdefence_npc_pop.handler(bean)
	local mapID = g_i3k_game_context:GetWorldMapID()
	local txtID = i3k_db_defend_cfg[mapID].talkTxtID
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(txtID, bean.percent))
end

-- 死亡喊话
function i3k_sbean.towerdefence_npc_dead.handler(bean)
	local mapID = g_i3k_game_context:GetWorldMapID()
	local txtID = i3k_db_defend_cfg[mapID].deadTxtID
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(txtID))
end

-- 警告队友
function i3k_sbean.receive_towerdefence_alarm.handler(bean)
	local tips = {
		[g_DEFENCE_ALARM_BACK] = 15411, 
		[g_DEFENCE_ALARM_LEFT] = 15412, 
		[g_DEFENCE_ALARM_RIGHT] = 15413, 
	}
	local tipsId = tips[bean.type]
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(tipsId))
end

-- 刷怪提示
function i3k_sbean.towerdefence_spawn_monsters.handler(bean)
	g_i3k_ui_mgr:OpenUI(eUIID_DefendCount)
	g_i3k_ui_mgr:RefreshUI(eUIID_DefendCount, bean.count)
end

-- 通知队友
function i3k_sbean.send_towerdefence_tips(tipsType)
	local data = i3k_sbean.send_towerdefence_alarm.new()
	data.type = tipsType
	i3k_game_send_str_cmd(data)
end

-- 刷新守卫NPC血量
function i3k_sbean.towerdefence_npc_info.handler(bean)
	g_i3k_game_context:setTowerDefenceTargetHp(bean.curHP, bean.maxHP)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_DefendSummary, "updateTargetHP")
end
