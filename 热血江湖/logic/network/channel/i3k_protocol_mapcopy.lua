------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/network/channel/i3k_channel");
local TIMER = require("i3k_timer");
local i3k_game_slow_timer = i3k_class("i3k_game_timer", TIMER.i3k_timer);

------------------------------------------------------
function i3k_sbean.normalmap_start(mapId)
print("------- send normalmap_start mapId=" .. mapId .. "-------------------\n")
	if i3k_check_resources_downloaded(mapId) then
		local data = i3k_sbean.normalmap_start_req.new()
		data.mapId = mapId
		i3k_game_send_str_cmd(data, "normalmap_start_res")
	end
end

-- 开始进入标准副本请求
-- Packet:normalmap_start_res
function i3k_sbean.normalmap_start_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:ClearFindWayStatus()
		local mapID = req.mapId
		g_i3k_ui_mgr:CloseUI(eUIID_FBLB);
		g_i3k_ui_mgr:CloseUI(eUIID_DailyTask)
		g_i3k_ui_mgr:CloseUI(eUIID_Main)
		local cfg = i3k_db_new_dungeon[mapID]
		g_i3k_game_context:UseVit(cfg.consume,AT_COMMON_MAPCOPY_ONSTART)
		g_i3k_game_context:UpdateMainTaskValue(g_TASK_ENTER_FUBEN,mapID)
		g_i3k_game_context:UpdateEpicTaskValue(g_TASK_ENTER_FUBEN,mapID)
		g_i3k_game_context:UpdateAdventureTaskValue(g_TASK_ENTER_FUBEN,mapID)
		g_i3k_game_context:updateSwordsmanTaskValue(g_TASK_ENTER_FUBEN, mapID)
	else
		local logic = i3k_game_get_logic()
		logic:OnQuitDungeon()
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(73))
	end
	return true
end

function i3k_sbean.activitymap_start(mapId, tili)
	local data = i3k_sbean.activitymap_start_req.new()
	data.mapId = mapId
	data.tili = tili
	i3k_game_send_str_cmd(data, "activitymap_start_res")
end

-- 开始进入活动副本响应
-- Packet:activitymap_start_res
function i3k_sbean.activitymap_start_res.handler(bean, req)
	if bean.ok==1 then
		local cfg = i3k_db_activity_cfg[req.mapId]
		g_i3k_game_context:ClearFindWayStatus()
		g_i3k_game_context:UseVit(req.tili,AT_START_CLIMB_TOWER_COPY)
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_ACT, cfg.groupId)

	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s", "进入活动失败"))
	end
end

-- 活动副本杀怪计数同步
-- Packet:role_activitymap_sync
function i3k_sbean.role_activitymap_sync.handler(bean, res)
	g_i3k_game_context:setKillCount(bean.killMonsters)
	g_i3k_ui_mgr:RefreshUI(eUIID_KillCount,bean.mapId)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_KillCount, "showInfo",bean.killMonsters)
end

------------------------------------------------------
-- 主动离开副本响应
-- Packet:mapcopy_leave_res
function i3k_sbean.mapcopy_leave_res.handler(bean, res)
	local is_ok = bean.ok
	if is_ok == 1 then
		g_i3k_game_context:ClearFindWayStatus()
		local logic = i3k_game_get_logic();
		if logic then
			logic:OnQuitDungeon();
			local hero = i3k_game_get_player_hero()
			hero:SetAutoFight(false)
			hero:StopMove();
			hero:ClearMoveState();
			if res.uiid then
				g_i3k_ui_mgr:CloseUI(res.uiid);
			end
			g_i3k_ui_mgr:CloseUI(eUIID_DungeonBonus)
			g_i3k_ui_mgr:CloseUI(eUIID_FactionDungeonBattleOver)
			g_i3k_ui_mgr:CloseUI(eUIID_BattleFuben)
			if res.func then
				res.func()
			end
		end
	elseif is_ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1310))
	end

	return true;
end

-- 通知客户端普通副本开始（不包括副本扫荡）
-- Packet:role_commonmap_start
function i3k_sbean.role_commonmap_start.handler(bean,res)
	local mapId = bean.mapId
	local cfg = i3k_db_activity_cfg[mapId]
	local endtime = g_i3k_game_context:getRoleSpecialCards(SUPER_MONTH_CARD).cardEndTime
	local nowtime  = i3k_game_get_time()
	local doubleTimesFlag = g_i3k_game_context:refineIsGroupTypeActivity(mapId) and endtime - nowtime > 0
	
	if cfg then
		local map = {}
		map["组"..cfg.groupId] = tostring(mapId)
		local eventId = "进入活动副本"
		DCEvent.onEvent(eventId, map)
		g_i3k_game_context:PlotCheck()
	else
		local map = {}
		local cfg = i3k_db_new_dungeon[mapId]
		if cfg then
			local scheduleType
			if not g_i3k_db.i3k_db_is_private_dungeon(mapId) then
				scheduleType = g_SCHEDULE_TYPE_GROUP
			elseif cfg.difficulty == 2 then
				scheduleType = g_SCHEDULE_TYPE_COMMON
			elseif cfg.difficulty == 3 then
				scheduleType = g_SCHEDULE_TYPE_HARD
			end
			if scheduleType then
				g_i3k_game_context:ChangeScheduleActivity(scheduleType, mapId)
				
				if doubleTimesFlag then
					g_i3k_game_context:ChangeScheduleActivity(scheduleType, mapId)
				end
			end

			map["D"..cfg.difficulty] = tostring(mapId)
			local goldAg = g_i3k_db.i3k_db_get_gold_or_ag_map(mapId)
			if goldAg then
			  DCEvent.onEvent(goldAg, map)
			else
				local eventId = g_i3k_db.i3k_db_is_private_dungeon(mapId) and "进入单人副本" or "进入组队副本"
				DCEvent.onEvent(eventId, map)
			end
		end
	end
	
	local count = 1
	
	if doubleTimesFlag then
		count = 2 
	end
	
	g_i3k_game_context:addDungeonEnterTimes(mapId, count)
	g_i3k_game_context:addActivityDayEnterTime(mapId)
	
	g_i3k_game_handler:RoleBreakPoint("Game_Role_Start_Map_Instance", tostring(mapId))
	DCLevels.begin(mapId)
	
	if i3k_db_climbing_tower_fb[mapId] then
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_TOWER, g_SCHEDULE_COMMON_MAPID)
	end
	
	if i3k_db_weapon_npc[mapId] then
		g_i3k_game_context:setWeaponNpcEnterTimesAdd()
	end

	--幻境试炼，不属于正义之心类型副本，但是日程表是正义之心类型
	if i3k_db_illusory_dungeon[mapId] then
		g_i3k_game_context:addNpcDungeonEnterTimes(i3k_db_illusory_dungeon[mapId].npcgroupId)
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_ZHENGYIZHIXIN_2, i3k_db_illusory_dungeon[mapId].npcgroupId)
	end

	if i3k_db_dungeon_base[mapId] and i3k_db_dungeon_base[mapId].openType == g_RIGHTHEART then -- 正义之心
		if i3k_db_rightHeart2[mapId].npcgroupId > 0 then
			g_i3k_game_context:addNpcDungeonEnterTimes(i3k_db_rightHeart2[mapId].npcgroupId)
			g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_ZHENGYIZHIXIN_2, i3k_db_rightHeart2[mapId].npcgroupId)
		else
			g_i3k_game_context:updateRightHeartEnterTimes()
			g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_ZHENGYIZHIXIN, g_SCHEDULE_COMMON_MAPID)
		end
	end
	if i3k_db_dungeon_practice_door[mapId] and i3k_db_dungeon_base[mapId].openType == g_DOOR_XIULIAN then --修炼之门
		g_i3k_game_context:addNpcDungeonEnterTimes(37)--修炼之门NPC_groupID
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_ZHENGYIZHIXIN_2, 37)
		g_i3k_game_context:ClearMapBuffFlagInPracticeGate()
	end
	--家园保卫战
	if i3k_db_homeland_guard_base[mapId] then
		g_i3k_game_context:addNpcDungeonEnterTimes(i3k_db_homeland_guard_cfg.groupId)
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_ZHENGYIZHIXIN_2, i3k_db_homeland_guard_cfg.groupId)
	end
	g_i3k_game_context:ResetPracticeGateData()--清空修炼之门数据
end

-- 势力战奖励副本开始
function i3k_sbean.role_forcewar_rewardmap_start.handler(bean)
	local mapId = bean.mapId
	if mapId == i3k_db_forcewar_base.otherData.AgFuben or mapId == i3k_db_forcewar_base.otherData.goldFuben then --黄金白银副本减奖励数
		g_i3k_game_context:reduceDungeonDayRewardTimes(mapId)
	end
end

-- 首次进入副本后或断线重登录后通知客户端副本的时间信息
-- Packet:role_mapcopy_timesync
function i3k_sbean.role_mapcopy_timesync.handler(bean,res)
	local world = i3k_game_get_world()
	if world then
		world:SetStartTime(bean.startTime)
	end
	return;
end

-- 通知客户端结束副本（不包括副本扫荡，可能是boss死亡结束，可能是玩家死亡结束，可能是完成副本，也可能是未完成副本）socre <= 0未完成
--Packet:role_end_mapcopy
function i3k_sbean.role_commonmap_end.handler(bean, res)
	local mapID = bean.mapId
	local score = bean.score
	local world = i3k_game_get_world()
	if world then
		for k,v in pairs(world._entities[eGroupType_O]) do
			v._behavior:Set(eEBPrepareFight)
		end
		world:Exit()
	end
	g_i3k_game_handler:RoleBreakPoint("Game_Role_Finish_Map_Instance", tostring(mapID))
	if score > 0 or i3k_db_dungeon_practice_door[mapID] then
		DCLevels.complete(mapID)
		local map_cfg
		local slowflag = false
		if i3k_db_new_dungeon[mapID] and i3k_db_new_dungeon[mapID].condition == 1 then
			slowflag = true
			map_cfg = i3k_db_new_dungeon[mapID]
		end
		if i3k_db_activity_cfg[mapID] and i3k_db_activity_cfg[mapID].winCondition == 1 then
			slowflag = true
			map_cfg = i3k_db_activity_cfg[mapID]
		end
		if i3k_db_weapon_npc[mapID] and i3k_db_weapon_npc[mapID].winCondition == 1 then
			slowflag = true
			map_cfg = i3k_db_weapon_npc[mapID]
		end
		if i3k_db_dungeon_practice_door[mapID] then
			slowflag = true
			map_cfg = i3k_db_dungeon_practice_door[mapID]
			g_i3k_game_context:ClearMapBuffFlagInPracticeGate()
		end
		if slowflag then
			local Etime = 2000
			local animation = false
			if map_cfg then
				Etime = map_cfg.slowtime * 1000
				if i3k_db_new_dungeon[mapID] and i3k_db_new_dungeon[mapID].bossend ~= -1 then
					animation = true;
				end
			end
			local logic = i3k_game_get_logic()
			if logic then
				--i3k_log(" i3k_game_slow_timer " .. Etime)
				logic:RegisterTimer(i3k_game_slow_timer.new(Etime,true));
			end
			local world = i3k_game_get_world()
			if world then
				if animation and not world._sceneAni.bossend then
					world._sceneAni.bossend = true;
					i3k_game_play_scene_ani(i3k_db_new_dungeon[mapID].bossend)
					--g_i3k_game_context:playFlash(i3k_db_new_dungeon[mapID].bossend)
				else
					i3k_engine_set_frame_interval_scale(map_cfg.fuben_frame or 0.1);
				end
			end
		end
		local all,play = g_i3k_game_context:GetYongbingData()
		if i3k_db_faction_dungeon[mapID] then
			if play[FACTION_DUNGEON] then
				for k,v in pairs(play[FACTION_DUNGEON]) do
					g_i3k_game_context:AddPetDungeonData(v,mapID)
				end
			end
		elseif i3k_db_new_dungeon[mapID] and i3k_db_new_dungeon[mapID].openType == g_FIELD then
			if play[DUNGEON] then
				for k,v in pairs(play[DUNGEON]) do
					g_i3k_game_context:AddPetDungeonData(v,mapID)
				end
			end
		end
		g_i3k_game_context:SetTaskDataByTaskType(mapID,g_TASK_GET_TO_FUBEN)
		g_i3k_game_context:updateSwordsmanTaskValue(g_TASK_GET_TO_FUBEN, mapID)
	else
		--DCLevels.fail(mapID,"")
	end
	if score ~= 0 then
		if i3k_db_dungeon_base[mapID].openType == g_AT_ANY_MOMENT_DUNGEON then
			g_i3k_game_context:finishKnightlyDetectiveTask(mapID)
			g_i3k_game_context:SetTaskDataByTaskType(mapID, g_TASK_ANY_MOMENT_DUNGEON)
			if i3k_db_at_any_moment[mapID].flyingTips ~= "" then
			g_i3k_ui_mgr:PopupTipMessage(i3k_db_at_any_moment[mapID].flyingTips)
			end
			g_i3k_game_context:addFinishFlyingPos(mapID)
			if i3k_db_at_any_moment[mapID].flyingEffect ~= 0 then
			local hero = i3k_game_get_player_hero()
			if hero then
				hero:setPlayActionState(1)
				hero:PlayHitEffect(i3k_db_at_any_moment[mapID].flyingEffect)
				--hero:SetFaceDir(0, 1.57, 0)
				local logic = i3k_game_get_logic();
				local mainCamera = logic:GetMainCamera();
				local angle1 = i3k_vec3_angle1(mainCamera._right, i3k_vec3(0, 0, 0), i3k_vec3(1, 0, 0))
				local angle2 = i3k_vec3_angle1(i3k_vec3(1, 0, 1), i3k_vec3(0, 0, 0), i3k_vec3(1, 0, 0))
				local world = i3k_game_get_world();
				if world and world._cfg then
					local mcfg = i3k_db_combat_maps[world._cfg.mapID];
					if mcfg then
						local angle = angle2 - angle1 - mcfg.cameraRot + 90;
						hero:SetFaceDir(0, angle / 180 * math.pi, 0)
					end
				end
				local alist = {}
				table.insert(alist, {actionName = i3k_db_at_any_moment[mapID].flyingAction, actloopTimes = 1})
				table.insert(alist, {actionName = i3k_db_common.engine.defaultAttackIdleAction, actloopTimes = -1})
				hero:PlayActionList(alist, 1)
				end
			end
		end
	end
	g_i3k_game_context:setDungeonEndScore(mapID, score)
	return true
end

function i3k_game_slow_timer:Do(args)
	--i3k_log("i3k_game_timer");
	i3k_engine_set_frame_interval_scale(1);
	return true;
end
------------------------------------------------------
-- 通知客户端4v4竞技场副本结束
-- Packet:role_superarenamap_end
function i3k_sbean.role_superarenamap_end.handler(bean,res)
	local world = i3k_game_get_world()
	if world then
		for k,v in pairs(world._entities[eGroupType_O]) do
			v._behavior:Set(eEBPrepareFight)
		end
	end
end

-- 通知客户端开始副本翻盘奖励（不包括副本扫荡）
-- Packet:role_commonmap_result
function i3k_sbean.role_commonmap_result.handler(bean,res)
	local mapID = bean.mapId
	local score = bean.score
	local rewards = bean.rewards
	local finishTime = bean.finishTime
	local deadTimes = bean.deadTimes
	local killMonsters = bean.killMonsters

	local settlement = {}
	settlement.score = score
	settlement.finishTime = finishTime
	settlement.deadTimes = deadTimes
	settlement.killMonsters = killMonsters
	local uiid
	g_i3k_ui_mgr:CloseUI(eUIID_PlayerRevive)
	if i3k_db_dungeon_base[mapID].openType == g_AT_ANY_MOMENT_DUNGEON and i3k_db_at_any_moment[mapID].showFinish == 0 then
		i3k_sbean.mapcopy_leave()
		return
	end
	if i3k_db_dungeon_base[mapID].openType == g_FIVE_ELEMENTS then
		local function callBack()
			g_i3k_logic:OpenFiveElementsUI()
		end
		g_i3k_game_context:SetMapLoadCallBack(callBack)
	end
	if score>=0 and not i3k_db_homeland_guard_base[mapID] then --这里屏蔽掉家园守卫战
		if score==0 then
			if i3k_db_climbing_tower_fb[mapID] then
				uiid = eUIID_FiveUniqueFailed
				g_i3k_ui_mgr:OpenUI(eUIID_FiveUniqueFailed)
				g_i3k_ui_mgr:RefreshUI(eUIID_FiveUniqueFailed,  rewards, mapID, settlement)
			elseif i3k_db_new_dungeon[mapID] then
				uiid = eUIID_DungeonFailed
				g_i3k_ui_mgr:OpenUI(eUIID_DungeonFailed)
				g_i3k_ui_mgr:RefreshUI(eUIID_DungeonFailed, rewards, mapID, settlement)
			elseif i3k_db_dungeon_base[mapID] and (i3k_db_dungeon_base[mapID].openType == g_RIGHTHEART or i3k_db_dungeon_base[mapID].openType == g_ILLUSORY_DUNGEON or i3k_db_dungeon_base[mapID].openType == g_AT_ANY_MOMENT_DUNGEON or i3k_db_dungeon_base[mapID].openType == g_FIVE_ELEMENTS) then -- 单人闯关失败 or 幻境试炼失败
				uiid = eUIID_SingleChallengeFailed
				g_i3k_ui_mgr:OpenUI(eUIID_SingleChallengeFailed)
				g_i3k_ui_mgr:RefreshUI(eUIID_SingleChallengeFailed, rewards, mapID, settlement)
			end
		else
			uiid = eUIID_DungeonBonus
			g_i3k_ui_mgr:OpenUI(eUIID_DungeonBonus)
			g_i3k_ui_mgr:RefreshUI(eUIID_DungeonBonus, rewards, mapID, settlement)
		end
	elseif score == -1 then
		if i3k_db_climbing_tower_fb[mapID] then
			uiid = eUIID_FiveUniqueBonus
			g_i3k_ui_mgr:OpenUI(eUIID_FiveUniqueBonus)
			g_i3k_ui_mgr:RefreshUI(eUIID_FiveUniqueBonus, rewards, mapID, settlement)
		elseif i3k_db_activity_cfg[mapID] then
			uiid = eUIID_ActivityResult
			g_i3k_ui_mgr:OpenUI(eUIID_ActivityResult)
			g_i3k_ui_mgr:RefreshUI(eUIID_ActivityResult, rewards, mapID, settlement, bean.process)
		elseif i3k_db_weapon_npc[mapID] then
			uiid = eUIID_Weapon_NPC_RESULT
			g_i3k_ui_mgr:OpenUI(eUIID_Weapon_NPC_RESULT)
			g_i3k_ui_mgr:RefreshUI(eUIID_Weapon_NPC_RESULT, rewards, mapID, settlement, bean.process)
		elseif i3k_db_dungeon_base[mapID] and (i3k_db_dungeon_base[mapID].openType == g_RIGHTHEART or i3k_db_dungeon_base[mapID].openType == g_ILLUSORY_DUNGEON or i3k_db_dungeon_base[mapID].openType == g_AT_ANY_MOMENT_DUNGEON or i3k_db_dungeon_base[mapID].openType == g_FIVE_ELEMENTS) then -- 正义之心 or 单人闯关成功 or 幻境试炼成功 or 五行轮转成功
			uiid = eUIID_RightHeart_RESULT
			if i3k_db_dungeon_base[mapID].openType == g_FIVE_ELEMENTS then
				g_i3k_game_context:fiveElementsWin()
			end
			g_i3k_ui_mgr:CloseUI(eUIID_Dialogue1)
			g_i3k_ui_mgr:OpenUI(eUIID_RightHeart_RESULT)
			g_i3k_ui_mgr:RefreshUI(eUIID_RightHeart_RESULT, rewards, mapID, settlement, bean.process)
		end
	end
	--家园保卫战特殊结算逻辑
	if i3k_db_homeland_guard_base[mapID] then
		uiid = eUIID_DefendResult
		g_i3k_ui_mgr:OpenUI(eUIID_DefendResult)
		g_i3k_ui_mgr:RefreshUI(eUIID_DefendResult, -1, score, finishTime, rewards)
	end
	if i3k_db_dungeon_practice_door[mapID] then
		uiid = eUIID_DoorOfXiuLianResult
		g_i3k_ui_mgr:OpenUI(uiid)
		g_i3k_ui_mgr:RefreshUI(uiid, bean)
	end
	--i3k_log("role_commonmap_result------", bean.mapId,istower,score)
	local time = 0
	function update(dTime)
		time = time+dTime
		local closeTime
		if uiid==eUIID_DungeonBonus
			or uiid==eUIID_ActivityResult
			or uiid == eUIID_FiveUniqueBonus
			or uiid == eUIID_Weapon_NPC_RESULT
			or uiid == eUIID_RightHeart_RESULT
			or uiid == eUIID_DoorOfXiuLianResult
			or uiid == eUIID_DefendResult
				then
			closeTime = i3k_db_common.wipe.autoCloseTime+i3k_db_common.wipe.autoFlipCardTime
		else
			closeTime = i3k_db_common.wipe.autoCloseTime
		end
		local expectUI = g_i3k_ui_mgr:GetUI(uiid)
		if not expectUI then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(sc)
			return
		end
		if time>=closeTime then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(sc)
			g_i3k_ui_mgr:CloseUI(uiid)
		else
			local haveTime = math.ceil(closeTime - time)
			g_i3k_ui_mgr:InvokeUIFunction(uiid, "updateSchedule", haveTime)
		end
	end
	sc=cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0.1, false)

end

-- 手动翻牌抽奖回应
function i3k_sbean.commonmap_selectcardReq(openTime)
	if g_i3k_game_context:GetCurrMapCanReward() == 0 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15420))
	end
	local copycard = i3k_sbean.commonmap_selectcard_req.new()
	copycard.cardNo = openTime
	i3k_game_send_str_cmd(copycard, i3k_sbean.commonmap_selectcard_res.getName())
end

--Packet:commonmap_selectcard_res
function i3k_sbean.commonmap_selectcard_res.handler(bean)
	local item = bean.item
	if item then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DungeonBonus, "openReward", item)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ActivityResult, "openReward", item)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FiveUniqueBonus, "openReward", item)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Weapon_NPC_RESULT, "openReward", item)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RightHeart_RESULT, "openReward", item)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DefendResult, "openReward", item)
	else
		g_i3k_ui_mgr:PopupTipMessage("失败，再翻一次")
	end
end

-- 自动翻牌抽奖
--Packet:role_commonmap_autocard
function i3k_sbean.role_commonmap_autocard.handler(bean)
	local item = bean.item
	if item then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DungeonBonus, "openRandom", item)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ActivityResult, "openRandom", item)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FiveUniqueBonus, "openRandom", item)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Weapon_NPC_RESULT, "openRandom", item)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RightHeart_RESULT, "openRandom", item)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DefendResult, "openRandom", item)
		--g_i3k_ui_mgr:PopupTipMessage("翻牌时间已过，无法继续翻牌")
	else
		g_i3k_ui_mgr:PopupTipMessage("没有得到任何奖励")
	end
end

function i3k_sbean.mapcopy_leave(uiid, func)
	local leave = i3k_sbean.mapcopy_leave_req.new()
	if uiid then
		leave.uiid = uiid
	end
	leave.func = func
	--leave.mapId = g_i3k_game_context:GetWorldMapID()
	i3k_game_send_str_cmd(leave, "mapcopy_leave_res");
end

function i3k_sbean.normalmap_buytimes(mapId, count, callback)
	local data = i3k_sbean.normalmap_buytimes_req.new()
	data.mapId = mapId
	data.count = count
	data.callback = callback
	i3k_game_send_str_cmd(data, "normalmap_buytimes_res")
end

-- 购买进入标准副本次数的响应
--Packet:normalmap_buytimes_res
function i3k_sbean.normalmap_buytimes_res.handler(bean, req)
	if bean.ok == 1 then
		if req.callback then
			req.callback()
		end
		g_i3k_game_context:AddNormalMapBuyTimes(req.mapId, req.count)
		g_i3k_ui_mgr:CloseUI(eUIID_BuyDungeonTimes)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FBLB, "updateDungeonData")
	end
end

-- 新手关(现在改为不保存进度，只在结束的时候发送0，这时候服务器会发送changeMap协议)
function i3k_sbean.save_playerLead_mapcopy(step)
	local data = i3k_sbean.save_guide_mapcopy_req.new()
	data.step = step
	if step == 0 then
		-- 恢复摄像机视角
		local percent = i3k_get_load_cfg():GetCameraInter() * 100
		g_i3k_game_context:setCameraDistance(percent / 100);
		i3k_game_send_str_cmd(data, "save_guide_mapcopy_res")
	end
end

function i3k_sbean.save_guide_mapcopy_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:clearPlayLeadFlag()
		g_i3k_game_context:leavePlayerLeadImpl()
	end
end

-- 同步引导关步骤
--Packet:sync_guide_mapcopy_step
function i3k_sbean.sync_guide_mapcopy_step.handler(bean)
	local step = bean.step
	if step == 1 and g_i3k_game_context:getPlayLeadFlag() then  -- 在最后一个boss时候发生断线重连
		i3k_sbean.save_playerLead_mapcopy(0)
		return
	end
	if not g_i3k_game_context:getPlayerLeadSyncFlag() then
		g_i3k_game_context:setPlayerLeadStage(step)
	end
	g_i3k_game_context:setPlayerLeadSyncFlag()
end

-- 2秒请求一次
function i3k_sbean.queryMapCopyDamageRank()
	local data = i3k_sbean.query_map_damage_rank.new()
	i3k_game_send_str_cmd(data)
end

--角色伤害排行
function i3k_sbean.map_copy_damage_rank.handler(bean)
	g_i3k_game_context:SetMapCopyDamageRank(bean.damageRank)
	local mapId = g_i3k_game_context:GetWorldMapID()
	if i3k_db_new_dungeon[mapId] and i3k_db_new_dungeon[mapId].openType == 1 then --组队副本
		g_i3k_ui_mgr:OpenUI(eUIID_MapCopyDamageRank)
		g_i3k_ui_mgr:RefreshUI(eUIID_MapCopyDamageRank)
	else --活动副本 单机副本 帮派副本
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleFuben, "updateOutPut")
	end
end
--副本技能
function i3k_sbean.sync_role_mapskill.handler(bean)
	local mapId = g_i3k_game_context:GetWorldMapID()
	local skillGroup = i3k_db_rightHeart2[mapId].dungeonSkill
	if i3k_db_rightHeart2[mapId] and i3k_db_rightHeart2[mapId].dungeonSkill > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_FuBen_Skill)
		local skillUseTime = bean.skillInfo and bean.skillInfo.skillUseTimes or {}
		local skillLastUseTime = bean.skillInfo and bean.skillInfo.skillLastUseTime or {}
		local skillCommonUseTime = bean.skillInfo and bean.skillInfo.skillCommonUseTime or 0
		g_i3k_ui_mgr:RefreshUI(eUIID_FuBen_Skill, skillUseTime, skillCommonUseTime, skillLastUseTime, i3k_db_rightHeart2[mapId].dungeonSkill)
	end
end

function i3k_sbean.role_usemapskill_ok.handler(bean)
	if g_i3k_game_context:IsInHomeLandGuardMap() then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandSkill, "ChangeSkillCount", bean.skillId, bean.success)
	else
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FuBen_Skill, "ChangeSkillCount", bean.skillId, bean.success)
	end
end

--特殊试炼副本记录
function i3k_sbean.activity_instance_logs_sync(id, name, flag)
	local data = i3k_sbean.activity_instance_logs_sync_req.new()
	data.id = id
	data.name = name
	data.flag = flag -- 是否为了获取批量试炼数据
	i3k_game_send_str_cmd(data, "activity_instance_logs_sync_res")
end

function i3k_sbean.activity_instance_logs_sync_res.handler(res, req)
	if not req.flag then
		g_i3k_ui_mgr:OpenUI(eUIID_ActivityDetail)
		g_i3k_ui_mgr:RefreshUI(eUIID_ActivityDetail, req.id, req.name, res.logs)
		return
	end
	
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "initDailyActivitySpecials", res.logs)
end

--试炼副本扫荡
function i3k_sbean.activity_instance_sweep_sync(selectTable, record)
	local data = i3k_sbean.activity_multi_sweep_req.new()
	data.maps = selectTable
	data.record = record
	i3k_game_send_str_cmd(data, "activity_multi_sweep_res")
end

function i3k_sbean.activity_multi_sweep_res.handler(res, req)
	if res.ok > 0 then  
		g_i3k_ui_mgr:CloseUI(eUIID_sweepActivity)
		local all = res.summaries
		
		if not all then
			return
		end
		
		local count = 0
		local totlaNormal = {}
		local totlCard = {}
		local coin = {}
		local exp = {}
		local name = {}
		local sweepCounts = {}
		
		for _,v in ipairs(all) do
			count = count + 1
			coin[count] = 0
			exp[count] = 0
			totlaNormal[count] = {}
			totlCard[count] = {}
			name[count] = {}
			sweepCounts[count] = 0
			local _t = v.mapSummary
		
			local mapID = v.mapId
			local times = v.times
			local extraCard = v.extraCard
			local diamondNeed = i3k_db_common.wipe.ingot
			local dungeon_data = i3k_db_activity_cfg[mapID]
			
			sweepCounts[count] = times
			name[count] = i3k_db_activity_cfg[mapID].desc
		
			if dungeon_data then
				local consume = dungeon_data.needTili
				g_i3k_game_context:UseVit(consume * times,AT_SWEEP_PRIVATE_MAP)
		
				-- if extraCard ~= 0 then
				-- 	g_i3k_game_context:UseCommonItem(g_BASE_ITEM_DIAMOND,diamondNeed * times, AT_SWEEP_PRIVATE_MAP)
				-- end
				
				--每个购买次数 和元宝消耗
				if req.record ~= nil and req.record[mapID] ~= nil then
					g_i3k_game_context:UseCommonItem(g_BASE_ITEM_DIAMOND, req.record[mapID].cost, AT_SWEEP_PRIVATE_MAP)
					g_i3k_game_context:addActivityDayBuyTimes(i3k_db_activity_cfg[mapID].groupId, req.record[mapID].buyTimes)
				end
				
				for i = 1, times do
					g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_ACT, dungeon_data.groupId)
				end
			end
			
			local normalData = {}
			local cardData = {}
			local temTable1 = {}
			local temTable2 = {}
			
			for i,j in pairs(_t.rewards) do			
				coin[count] = coin[count] + j.coin
				exp[count] = exp[count] + j.exp
							
				for a,b in pairs(j.normalRewards) do
					if temTable1[b.id] ~= nil then
						for	_, s in ipairs(normalData) do
							if s.id == b.id then
								s.count = s.count + b.count
							end
						end
					else
						temTable1[b.id] = b.count
						local temp = {}
						temp.id = tonumber(b.id)
						temp.count = tonumber(b.count)
						table.insert(normalData,temp)
					end				
				end
											
				for a,b in pairs(j.cardRewards) do
					if temTable2[b.id] ~= nil then
						for	_, s in ipairs(cardData) do
							if s.id == b.id then
								s.count = s.count + b.count
							end
						end
					else
						temTable2[b.id] = b.count
						local temp = {}
						temp.id = tonumber(b.id)
						temp.count = tonumber(b.count)
						table.insert(cardData,temp)
					end
				end
			end
			
			totlaNormal[count] = normalData
			totlCard[count] = cardData

			g_i3k_game_context:UseCommonItem(SWEEP_COUPON, times, AT_SWEEP_PRIVATE_MAP)
			g_i3k_game_context:addActivityDayEnterTime(mapID, times)

			for k, s in ipairs(i3k_db_mercenaries) do
				local taskID, value = g_i3k_game_context:getPetTskIdAndValueById(k)
				local pet_task_cfg = g_i3k_db.i3k_db_get_pet_task_cfg(taskID)
				
				if pet_task_cfg then
					local taskType = pet_task_cfg.type
					
					if taskType == g_TASK_GET_TO_FUBEN then
						g_i3k_game_context:UpdatePetTaskValue(taskType, mapID)
						break
					end
				end
			end
		end
 
		g_i3k_ui_mgr:OpenUI(eUIID_WIPEAward)
		g_i3k_ui_mgr:RefreshUI(eUIID_WIPEAward, coin, exp, totlaNormal, totlCard, count, name, sweepCounts)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "updateDailyActivity")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ActivityDetail, "updateWipeWidget")
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17226))
	end
end
-------------修炼之门
function i3k_sbean.practicegate_map_info.handler(bean)
	g_i3k_game_context:SetPracticeGateData(bean)
	g_i3k_ui_mgr:RefreshUI(eUIID_DoorOfXiuLianFuBen)
end
--随时副本进入请求
function i3k_sbean.anywhere_map_enter(taskType, groupId, taskId)
	local data = i3k_sbean.anywhere_map_enter_req.new()
	data.taskType = taskType
	data.groupId = groupId
	data.taskId = taskId
	i3k_game_send_str_cmd(data, "anywhere_map_enter_res")
end
function i3k_sbean.anywhere_map_enter_res.handler(res, req)
	if res.ok > 0 then
		--[[if req.taskType == TASK_CATEGORY_MAIN then
			local cfg = g_i3k_db.i3k_db_get_main_task_cfg(req.taskId)
			g_i3k_ui_mgr:OpenUI(eUIID_AtAnyMomentAnimate)
			g_i3k_ui_mgr:RefreshUI(eUIID_AtAnyMomentAnimate, i3k_db_at_any_moment[cfg.arg1].effects)
		elseif req.taskType == TASK_CATEGORY_SUBLINE then
			local cfg = g_i3k_db.i3k_db_get_subline_task_cfg(req.groupId, req.taskId)
			g_i3k_ui_mgr:OpenUI(eUIID_AtAnyMomentAnimate)
			g_i3k_ui_mgr:RefreshUI(eUIID_AtAnyMomentAnimate, i3k_db_at_any_moment[cfg.arg1].effects)
		end--]]
		g_i3k_ui_mgr:OpenUI(eUIID_AnyTimeAnimate)
		g_i3k_ui_mgr:RefreshUI(eUIID_AnyTimeAnimate)
		g_i3k_game_context:ClearFindWayStatus()
	else
		g_i3k_game_context:setIsNeedLoading()
	end
end
--传送到某坐标点
function i3k_sbean.anywhere_map_point_transfer(anywhereMapId)
	local data = i3k_sbean.anywhere_map_point_transfer_req.new()
	data.anywhereMapId = anywhereMapId
	i3k_game_send_str_cmd(data, "anywhere_map_point_transfer_res")
end
function i3k_sbean.anywhere_map_point_transfer_res.handler(res, req)
	if res.ok > 0 then
		local needId = i3k_db_common.activity.transNeedItemId
		g_i3k_game_context:UseTrans(needId, 1, AT_TELEPORT_MONSTER)
		releaseSchedule()
		g_i3k_ui_mgr:CloseUI(eUIID_SceneMap)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleMiniMap)
	else
	end
end
-- 进入御灵鬼岛请求
function i3k_sbean.ghost_island_enter()
	local data = i3k_sbean.ghost_island_enter_req.new()
	i3k_game_send_str_cmd(data, "ghost_island_enter_res")
end
function i3k_sbean.ghost_island_enter_res.handler(res, req)
	if res.ok > 0 then
	end
end
function i3k_sbean.ghost_island_enter_info.handler(bean)
	--self.points:		set[int32]	
	--self.pointCD:		map[int32, int32]	
	--self.bosses:		map[int32, int32]	
	g_i3k_game_context:setCatchSpiritPoint(bean.points)
	g_i3k_game_context:setCatchSpiritPointCD(bean.pointCD)
	g_i3k_game_context:setCatchSpiritBoss(bean.bosses)
	local world = i3k_game_get_world()
	if world then
		world:createCatchSpiritEntities(bean.points, bean.pointCD)
	end
	local hero = i3k_game_get_player_hero()
	if hero then
		hero:bindCatchSpiritSkills()
	end
end
