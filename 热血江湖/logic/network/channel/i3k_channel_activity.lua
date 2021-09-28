------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")



	--self.nextTransTime:		int32
	--self.bosses:		map[int32, BossState]
function i3k_sbean.bosses_sync_res.handler(bean, res)
	local nextTransTime = bean.nextTransTime
	local info = res.info
	local bosses = bean.bosses
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "importBossData", info, bosses[info.id])
end

function i3k_sbean.transtoboss_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_game_context:StartTransCoolTime(i3k_db_common.activity.transCoolTime)
		local userCfg = g_i3k_game_context:GetUserCfg()
		userCfg:SetActTransCoolTime(math.floor(g_i3k_get_GMTtime(i3k_game_get_time())))
		if not res.newWorld then
			g_i3k_logic:OpenBattleUI()
		end
		local id = i3k_db_common.activity.transNeedItemId
		-- g_i3k_game_context:UseBagItem(id, res.needCount,AT_CHECK_CAN_TRANS_TO_BOSS)
		g_i3k_game_context:UseTrans(id, res.needCount, AT_CHECK_CAN_TRANS_TO_BOSS)
	elseif bean.ok==4 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(180))
	else
		local tips = string.format("%s", "服务器资讯：请重试")
		g_i3k_ui_mgr:PopupTipMessage(tips)
	end
end

function i3k_sbean.walktoboss_res.handler(bean, res)
	if bean.ok==4 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(180))
	else
--		g_i3k_game_context:SeachBestPathWithMap(res.mapId, res.pos)
		--g_i3k_game_context:SeachPathWithMap(res.mapId, res.pos,nil,nil,nil,nil,0)
		g_i3k_game_context:findPathChangeLine(res.mapId, res.pos, 1)
		-- g_i3k_ui_mgr:CloseAllOpenedUI()
		g_i3k_logic:OpenBattleUI()
	end
end


--boss的排名数据
function i3k_sbean.sync_boss_record(bossId, isLast)
	local sync = i3k_sbean.boss_reward_req.new()
	sync.bossID = bossId
	sync.last = isLast --0是本次，1是上次
	i3k_game_send_str_cmd(sync, "boss_reward_res")
end

function i3k_sbean.boss_reward_res.handler(bean, res)
	local records = bean.records
	local selfReward = bean.selfReward
	if not g_i3k_ui_mgr:GetUI(eUIID_BossRecords) then
		g_i3k_ui_mgr:OpenUI(eUIID_BossRecords)
	end
	g_i3k_ui_mgr:RefreshUI(eUIID_BossRecords, res.bossID, records, res.last, selfReward)
end

--boss被攻击时主界面数据
function i3k_sbean.boss_damage_rank.handler(bean)
	local bossID = bean.bossID
	local selfDamage = bean.selfDamage
	g_i3k_game_context:SyncBossDamageData(bean.rank, bean.bossID, selfDamage)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateBossDamage", true)
end

function i3k_sbean.boss_damage_close.handler(bean)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateBossDamage", false)
	g_i3k_game_context:ClearBossDamageData()
end

function i3k_sbean.role_touch_boss.handler(bean)
	g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_WORldBOSS, g_SCHEDULE_COMMON_MAPID)
end



function i3k_sbean.reset_transtime_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BossSelect, "resetData")
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s", "服务器资讯：重置失败"))
	end
end




function i3k_sbean.buy_act_times(groupId, count, callback)
	local buy = i3k_sbean.activitymap_buytimes_req.new()
	buy.groupId = groupId
	buy.count = count
	buy.callback = callback
	i3k_game_send_str_cmd(buy, "activitymap_buytimes_res")
end

function i3k_sbean.activitymap_buytimes_res.handler(bean, res)
	if bean.ok == 1 then
		if res.callback then
			res.callback()
		end
		g_i3k_game_context:addActivityDayBuyTimes(res.groupId, res.count)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "reloadDailyActivity")
	else
		g_i3k_ui_mgr:PopupTipMessage("服务器错误资讯："..res.groupId)
	end
end





function i3k_sbean.world_boss_pop.handler(bean)
	local world = i3k_game_get_world()
	if world then
		local bossEntity = world._entities[eGroupType_E]["i3k_monster|"..bean.monsterID];
		local hero = i3k_game_get_player_hero()
		if bossEntity and hero then
			local dist = i3k_vec3_len(i3k_vec3_sub1(hero._curPos, bossEntity._curPos))
			if dist<i3k_db_common.filter.FilterMonsterRadius then
				g_i3k_ui_mgr:CloseUI(eUIID_MonsterPop)
				g_i3k_ui_mgr:OpenUI(eUIID_MonsterPop)
				local textId = i3k_db_world_boss[bean.bossID].popTextId[bean.index]
				local dialogue = i3k_db_dialogue[textId][1].txt
				g_i3k_ui_mgr:RefreshUI(eUIID_MonsterPop, dialogue, bossEntity)
			end
		end
	end
end




function i3k_sbean.role_activity_map_cur_process.handler(bean)
	g_i3k_game_context:SetActivityPercent(bean.process)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleFuben, "updateActivityPercent", bean.process)
end

--试炼补做
function i3k_sbean.role_activity_last.handler(bean)
	local info = bean.info
	if info then
		g_i3k_game_context:SetRetrieveActData(info)
	end
end

function i3k_sbean.activity_last_quick_doneReq(mapId,seq,cost, groupId)
	local req = i3k_sbean.activity_last_quick_done_req.new()
	req.mapId = mapId
	req.seq = seq
	req.cost = cost
	req.groupId = groupId
	i3k_game_send_str_cmd(req, i3k_sbean.activity_last_quick_done_res.getName())
end

function i3k_sbean.activity_last_quick_done_res.handler(res, req)
	if res.ok > 0 then
		local count = 1
		local totlaNormal = {res.rewards.normalRewards}
		local totlCard = {res.rewards.cardRewards}

		local coin = {res.rewards.coin}
		local exp = {res.rewards.exp}

		-- for i,j in pairs(res.rewards) do
		-- 	count = count + 1
		-- 	local index = #coin
		-- 	coin[index+1] = j.coin
		-- 	local index = #exp
		-- 	exp[index + 1] = j.exp
		-- 	local normalData = {}
		-- 	for a,b in pairs(j.normalRewards) do
		-- 		local temp = {}
		-- 		temp.id = tonumber(b.id)
		-- 		temp.count = tonumber(b.count)
		-- 		table.insert(normalData,temp)
		-- 	end
		-- 	local index = #totlaNormal
		-- 	totlaNormal[index + 1] = normalData
		-- 	local cardData = {}
		-- 	for a,b in pairs(j.cardRewards) do
		-- 		local temp = {}
		-- 		temp.id = tonumber(b.id)
		-- 		temp.count = tonumber(b.count)
		-- 		table.insert(cardData,temp)
		-- 	end
		-- 	local index = #totlCard
		-- 	totlCard[index +1] = cardData
		-- end
		g_i3k_game_context:UseCommonItem(g_BASE_ITEM_DIAMOND,req.cost,AT_SWEEP_PRIVATE_MAP)
		g_i3k_ui_mgr:OpenUI(eUIID_WIPEAward)
		g_i3k_ui_mgr:RefreshUI(eUIID_WIPEAward,coin,exp,totlaNormal,totlCard,count)

		g_i3k_game_context:ChangeRetrieveActData(req.groupId)
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_Schedule,"changeRetrieveActState")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RetrieveActivity,"GetCost",req.groupId)
	elseif res.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage("错误的序号")
	elseif res.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage("补做次数不足")
	elseif res.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage("错误的序号")
	elseif res.ok == -4 then
		g_i3k_ui_mgr:PopupTipMessage("地图未参与或未通关过")
	end
end

function i3k_sbean.teleportToStela(type, index)
	local bean = i3k_sbean.stele_teleport_req.new()
	bean.type = type
	bean.index = index
	i3k_game_send_str_cmd(bean, "stele_teleport_res")
end

function i3k_sbean.stele_teleport_res.handler(res, req)
	if res.ok~=1 then

		g_i3k_ui_mgr:PopupTipMessage("传送失败")
	else
		local needId = i3k_db_common.activity.transNeedItemId
		-- g_i3k_game_context:UseCommonItem(needId, 1,AT_TELEPORT_STELE)
		g_i3k_game_context:UseTrans(needId, 1, AT_TELEPORT_STELE)
		releaseSchedule()
		-- g_i3k_ui_mgr:CloseUI(eUIID_SceneMap)
		-- g_i3k_ui_mgr:RefreshUI(eUIID_BattleMiniMap)
	end
end

function i3k_sbean.stele_sync_req_send()
	local bean = i3k_sbean.stele_sync_req.new()
	i3k_game_send_str_cmd(bean, "stele_sync_res")
end

function i3k_sbean.stele_sync_res.handler(res, req)
	if res.info.allFinish == 1 or (res.remainTimes[res.info.index] and res.remainTimes[res.info.index] <= 0) then
		g_i3k_game_context:NotCanMineralStela()
	end
	g_i3k_game_context:setStelaData(res.info, res.type)
	g_i3k_ui_mgr:OpenUI(eUIID_Stela)
	g_i3k_ui_mgr:RefreshUI(eUIID_Stela, res.type, res.info, res.remainTimes)
end

function i3k_sbean.stele_join_req_send()
	local bean = i3k_sbean.stele_join_req.new()
	i3k_game_send_str_cmd(bean, "stele_join_res")
end

function i3k_sbean.stele_join_res.handler(res, req)
	if res.receiveTime > 0 then
		g_i3k_game_context:AddTaskToDataList(TASK_CATEGORY_STELA)
		g_i3k_game_context:addStelaMineCount()

		local stlData = g_i3k_game_context:getStelaActivityData()
		stlData.receiveTime = res.remianTimes
		local stlCfg = g_i3k_game_context:getStelaActivityDB()
		if stlCfg then
			g_i3k_game_context:SeachPathWithMap(stlCfg.mapId, stlCfg.pos)
		end
	end
end

function i3k_sbean.stele_rank_req_send()
	local bean = i3k_sbean.stele_rank_req.new()
	i3k_game_send_str_cmd(bean, "stele_rank_res")
end

function i3k_sbean.stele_rank_res.handler(res, req)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Stela,"lookRanklist",res.ranks, res.selfRank)
end

--江湖告急活动
function i3k_sbean.emergency_sync_req_send(flag)
	local bean = i3k_sbean.emergency_sync_req.new()
	bean.flag = flag
	i3k_game_send_str_cmd(bean, "emergency_sync_res")
end

function i3k_sbean.emergency_sync_res.handler(res, req)
	if not req.flag then
		g_i3k_ui_mgr:OpenUI(eUIID_Annunciate)
	end
	g_i3k_ui_mgr:RefreshUI(eUIID_Annunciate, res.infos)
end

function i3k_sbean.emergency_rank_req_send()
	local bean = i3k_sbean.emergency_rank_req.new()
	i3k_game_send_str_cmd(bean, "emergency_rank_res")
end

function i3k_sbean.emergency_rank_res.handler(res, req)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Annunciate,"lookRanklist",res.ranks, res.selfRank)
end

function i3k_sbean.emergency_enter_req_send(actId)
	local bean = i3k_sbean.emergency_enter_req.new()
	bean.activityId = actId
	i3k_game_send_str_cmd(bean, "emergency_enter_res")
end

function i3k_sbean.emergency_enter_res.handler(res, req)
	if res.ok > 0 then

	elseif res.ok == 0 then
	elseif res.ok == -1 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(911))
	elseif res.ok == -2 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(912))
	elseif res.ok == -3 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(341,i3k_db_annunciate.cfg.limitLvl))
	elseif res.ok == -4 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(913))
	end
end
--同步声望
function i3k_sbean.sync_prestige_num.handler(bean)
	g_i3k_game_context:SetAnnunciatePrestige(bean.prestige)
	if bean.prestige > 0 then
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_ANNUNCIATE, g_SCHEDULE_COMMON_MAPID)
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleFuben, "updateAnnunciatePrestige",bean.prestige)
end

function i3k_sbean.role_emergency_map_end.handler()
	local callback = function(ok)
		if ok then
			i3k_sbean.mapcopy_leave()
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(910), callback)
end
--同步祈愿活动次数
function i3k_sbean.role_day_npc_pray_times.handler( bean )
	for i,v in pairs(bean.times) do
		g_i3k_game_context:SetPrayTimes( i,v )
	end
end

--祈愿
function i3k_sbean.join_npc_pray_req_send( prayId, dropId )
	local bean = i3k_sbean.join_npc_pray_req.new()
	bean.prayId = prayId
	bean.dropId = dropId
	i3k_game_send_str_cmd(bean, "join_npc_pray_res")
end

function i3k_sbean.join_npc_pray_res.handler(bean,req)
	if bean.ok > 0 then
		local times = g_i3k_game_context:GetPrayTimes(req.prayId) + 1
        g_i3k_game_context:SetPrayTimes(req.prayId, times)
        local prayData = i3k_db_pray_activity[req.prayId]
        for _,v in ipairs(prayData.needItems) do
            g_i3k_game_context:UseCommonItem(v[1], v[2], AT_NPC_PRAY)
        end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PrayActivityTurntable,"showResult",bean.ok, bean.drop, times)
	end
end

--五绝秘藏
function i3k_sbean.five_goals_syncReq()
	local bean = i3k_sbean.five_goals_sync_req.new()
	i3k_game_send_str_cmd(bean, "five_goals_sync_res")
end
function i3k_sbean.five_goals_sync_res.handler(res, req)
	local info = res.info
	if res.type == 0 then
		if res.isOpen == 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15560))
			g_i3k_game_context:setFiveEndActState(0)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleEntrance, "RefreshAllItem")
			g_i3k_ui_mgr:CloseUI(eUIID_FiveEndActivity)
			return
		end
		g_i3k_ui_mgr:OpenUI(eUIID_FiveEndActivity)
		g_i3k_ui_mgr:RefreshUI(eUIID_FiveEndActivity, info)
	elseif res.type == 1 then
		g_i3k_game_context:setFiveEndActState(res.isOpen)
	end
end

function i3k_sbean.five_goals_isopen.handler(bean)
	g_i3k_game_context:setFiveEndActState(bean.isOpen)
end

function i3k_sbean.five_goals_take_rewardReq(rtype, goalid, items)
	local bean = i3k_sbean.five_goals_take_reward_req.new()
	bean.type = rtype
	bean.goalid = goalid
	bean.items = items
	i3k_game_send_str_cmd(bean, "five_goals_take_reward_res")
end
function i3k_sbean.five_goals_take_reward_res.handler(res, req)
	if res.ok > 0 then
		i3k_sbean.five_goals_syncReq()
		local t = {}
		for k,v in pairs(req.items) do
			t[#t + 1] = {id = k, count = v}
		end

		g_i3k_ui_mgr:ShowGainItemInfo(t)
	else
		g_i3k_ui_mgr:PopupTipMessage("领取奖励失败"..res.ok)
	end
end

--------------------大富翁begin------------------------
function i3k_sbean.syncDice(groupID)
	local data = i3k_sbean.rich_sync_req.new()
	data.groupId = groupID
	i3k_game_send_str_cmd(data, "rich_sync_res")
end
function i3k_sbean.rich_sync_res.handler(res, req)
	local diceInfo = res.rich -- DBRoleRich
	if diceInfo then
		g_i3k_ui_mgr:OpenUI(eUIID_Dice)
		g_i3k_ui_mgr:RefreshUI(eUIID_Dice, diceInfo)
	end
end

function i3k_sbean.throwDice(groupID)
	local data = i3k_sbean.rich_go_req.new()
	data.groupId = groupID
	i3k_game_send_str_cmd(data, "rich_go_res")
end
function i3k_sbean.rich_go_res.handler(res, req)
	if res.ok > 0 then
		local num = res.number
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Dice, "clearDiceEventCount")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Dice, "throwDice", num)
	elseif res.ok == -100 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16390)) -- 背包满了
	else
		g_i3k_ui_mgr:PopupTipMessage("投骰子失败")
	end
end

function i3k_sbean.finishDiceEvent(groupID, useDiamond, arg1, callback)
	local data = i3k_sbean.rich_get_event_req.new()
	data.groupId = groupID
	-- 你用物品兑换就发1  用元宝兑换就发2, 只用arg
	data.arg = useDiamond and 2 or 1
	data.arg1 = arg1
	data.callback = callback
	i3k_game_send_str_cmd(data, "rich_get_event_res")
end
function i3k_sbean.rich_get_event_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Dice, "clearDiceEventCount")
		if req.callback then
			req.callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("事件完成失败")
	end
end

function i3k_sbean.giveUpDiceEvent(groupID)
	local data = i3k_sbean.rich_give_up_req.new()
	data.groupId = groupID
	i3k_game_send_str_cmd(data, "rich_give_up_res")
end
function i3k_sbean.rich_give_up_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("放弃成功")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Dice, "clearDiceEventCount")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Dice, "updateDiceEventStatus", DICE_STATUS_GIVEUP)
	else
		g_i3k_ui_mgr:PopupTipMessage("放弃失败")
	end
end

function i3k_sbean.rich_sync_event_counts.handler(res)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Dice, "setDiceEventCount", res.count)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_DiceMonster, "updateProcessBar", res.count)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_DiceFlower, "updateProcessBar", res.count)
end

-------------------大富翁end-------------------------


-------------------江湖大盗begin-------------------------
function i3k_sbean.role_robbermonster.handler(bean)
	g_i3k_game_context:setRobberDayRefreshTimes(bean.dayRefreshTimes)
end

-- 同步江洋大盗信息
function i3k_sbean.robbermonster_sync()
	local info = i3k_sbean.robbermonster_sync_req.new()
	i3k_game_send_str_cmd(info, "robbermonster_sync_res")
end

function i3k_sbean.robbermonster_sync_res.handler(bean)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "reloadRobberMonster", bean.robbers)
end

-- 刷新江洋大盗信息
function i3k_sbean.robbermonster_refresh(times, diamondCount)
	local info = i3k_sbean.robbermonster_refresh_req.new()
	info.times = times
	info.diamondCount = diamondCount
	i3k_game_send_str_cmd(info, "robbermonster_refresh_res")
end

function i3k_sbean.robbermonster_refresh_res.handler(bean, req)
	if bean.robbers then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16824))
		if req.diamondCount > 0 then
			g_i3k_game_context:UseDiamond(req.diamondCount, false, AT_BUY_ROBBER_MONSTER)
		end
		g_i3k_game_context:addRobberDayRefreshTimes()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "loadRobberMonsterScroll", bean.robbers)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "loadRefreshInfo")
	else
		g_i3k_ui_mgr:PopupTipMessage("刷新失败")
	end
end

-- 大盗传送
function i3k_sbean.robbermonster_tele(monsterID)
	local data = i3k_sbean.robbermonster_tele_req.new()
	data.id = monsterID
	i3k_game_send_str_cmd(data, "robbermonster_tele_res")
end

function i3k_sbean.robbermonster_tele_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:UseTrans(i3k_db_common.activity.transNeedItemId, 1, AT_TELEPORT_ROBBER_MONSTER)
	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16872))
	end
end

-------------------江湖大盗end-------------------------
---飞马度记录点击次数----
function i3k_sbean.recordHorseClickCount(id)
	local data = i3k_sbean.drive_out_horses_req.new()
	data.mid = id
	local world = i3k_game_get_world();
	
	if world then
		local entity = world:GetEntity(eET_Monster, id);
		
		if entity then
			entity:sethaveClickCount(0)
		end
	end
	
	i3k_game_send_str_cmd(data)
end

-----end-----
function i3k_sbean.sync_daily_activity_week_reward()
	local bean = i3k_sbean.activitymap_week_sync_req.new()
	i3k_game_send_str_cmd(bean, "activitymap_week_sync_res")
end
--self.info:		DBActivityMapWeekReward
	--self.weekTimes:		int32
	--self.rewards:		set[int32]
function i3k_sbean.activitymap_week_sync_res.handler(bean)
	g_i3k_game_context:SetDailyActivityWeekRewardInfo(bean.info)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "reloadDailyActivityReal")
end
function i3k_sbean.daily_active_reward(id)
	local bean = i3k_sbean.activitymap_week_rewards_req.new()
	bean.id = id
	i3k_game_send_str_cmd(bean, "activitymap_week_rewards_res")
end
function i3k_sbean.activitymap_week_rewards_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:GainDailyActivityReward(req.id)
		local items = {}
		for k, v in pairs(bean.rewards) do
			table.insert(items, {id = k, count = v})
		end
		g_i3k_ui_mgr:OpenUI(eUIID_UseItemGainItems)
		g_i3k_ui_mgr:RefreshUI(eUIID_UseItemGainItems, items)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "updateDailyActivityWeekReward")
	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage("已经刷新，请重新打开介面")
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage("背包已满，领取失败")
	end
end
function i3k_sbean.spring_lantern_sync(redirectFlag, npcID)
	local bean = i3k_sbean.spring_lantern_sync_req.new()
	bean.redirectFlag = redirectFlag
	bean.npcID = npcID
	i3k_game_send_str_cmd(bean, i3k_sbean.spring_lantern_sync_res.getName())
end
function i3k_sbean.spring_lantern_sync_res.handler(res, req)
	g_i3k_game_context:setSpringRollInfo(res.info)
	local times = g_i3k_game_context:getSpringRollNPCTimes(req.npcID)
	local npcInfo = g_i3k_game_context:getSpringRollNPCInfo(req.npcID)
	local maxTimes = npcInfo and npcInfo.args1 or 0
	if maxTimes == 0 and req.redirectFlag ~= OPEN_SPRING_ROLL_MAIN then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19052))
		return
	end
	if times >= maxTimes and req.redirectFlag ~= OPEN_SPRING_ROLL_MAIN then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19041))
		return
	end
	local totalTimes = g_i3k_game_context:getSpringRollTotalTimes()
	if totalTimes >= i3k_db_spring_roll.rollConfig.dayTotalTimes and req.redirectFlag ~= OPEN_SPRING_ROLL_MAIN then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19042))
		return
	end
	if req.redirectFlag == OPEN_SPRING_ROLL_MAIN then
		g_i3k_ui_mgr:OpenAndRefresh(eUIID_SpringRollMain)
	elseif req.redirectFlag == OPEN_SPRING_ROLL_BATTLE then
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(19049, i3k_db_npc[req.npcID].remarkName), function (isOk)
			if isOk then
				i3k_sbean.spring_lantern_map_enter(req.npcID)
			end
		end)
	elseif req.redirectFlag == OPEN_SPRING_ROLL_QUIZ then
		g_i3k_ui_mgr:OpenAndRefresh(eUIID_SpringRollQuiz, req.npcID)
	elseif req.redirectFlag == OPEN_SPRING_ROLL_BUY then
		g_i3k_ui_mgr:OpenAndRefresh(eUIID_SpringRollBuy, req.npcID)
	end
end
function i3k_sbean.spring_lantern_map_enter(npcID)
	local bean = i3k_sbean.spring_lantern_map_enter_req.new()
	bean.npcId = npcID
	i3k_game_send_str_cmd(bean, i3k_sbean.spring_lantern_map_enter_res.getName())
end
function i3k_sbean.spring_lantern_map_enter_res.handler(res, req)
end
function i3k_sbean.spring_lantern_join(npcID)
	local bean = i3k_sbean.spring_lantern_join_req.new()
	bean.npcId = npcID
	i3k_game_send_str_cmd(bean, i3k_sbean.spring_lantern_join_res.getName())
end
function i3k_sbean.spring_lantern_join_res.handler(res, req)
	if res.ok > 0 then
		local npcInfo = g_i3k_game_context:getSpringRollNPCInfo(req.npcId)
		local items = {{['id'] = i3k_db_spring_roll.rollConfig.itemImageID, ['count'] = npcInfo.args2}}
		g_i3k_ui_mgr:ShowGainItemInfo(items)
		if npcInfo.type == SPRING_ROLL_TYPE_QUIZ then
			local userCfg = g_i3k_game_context:GetUserCfg()
			userCfg:SetSpringRollQuiz(req.npcId, nil)
			g_i3k_ui_mgr:CloseUI(eUIID_SpringRollQuiz)
		elseif npcInfo.type == SPRING_ROLL_TYPE_BUY then
			g_i3k_game_context:UseBaseItem(npcInfo.args3, npcInfo.args4)
			g_i3k_game_context:addSpringRollNPCTimes(req.npcId)
			local times = g_i3k_game_context:getSpringRollNPCTimes(req.npcId)
			local npcInfo = g_i3k_game_context:getSpringRollNPCInfo(req.npcId)
			local maxTimes = npcInfo and npcInfo.args1 or 0
			if times >= maxTimes then
				g_i3k_ui_mgr:CloseUI(eUIID_SpringRollBuy)
			end
		end
	elseif res.ok == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19042))
	elseif res.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19052))
	end
end
function i3k_sbean.spring_lantern_use(index)
	local bean = i3k_sbean.spring_lantern_use_req.new()
	bean.index = index
	i3k_game_send_str_cmd(bean, i3k_sbean.spring_lantern_use_res.getName())
end
function i3k_sbean.spring_lantern_use_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_SPRING_ROLL, 0)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpringRollMain, "filledLampCallback")
	end
end
function i3k_sbean.spring_lantern_finish_drop.handler(res)
	g_i3k_game_context:setSpringRollDropAwards(res.drop, false)
end
