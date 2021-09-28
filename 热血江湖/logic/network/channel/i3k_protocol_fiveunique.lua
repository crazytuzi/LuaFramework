------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

---------------------------------五绝试炼相关协议----------------------------------------------
local FIVE_NUMBER = 65536

-- 同步爬塔数据
function i3k_sbean.sync_activities_tower(state,percent,func,next)
	local bean = i3k_sbean.sync_tower_req.new()
	bean.state = state
	bean.percent = percent
	bean.func = func
	bean.next = next--快速下一关
	i3k_game_send_str_cmd(bean, "sync_tower_res")
end

function i3k_sbean.sync_tower_res.handler(res, req)--info(data(groupId,bestFloor,dayTimesBuy,dayTimesUsed,finishFloors,pets))
	local data = res.info
	if res.info  then
		local user_cfg = g_i3k_game_context:GetUserCfg()
		local groupId = user_cfg:GetSelectFiveUnique()
		if req.state then
			local tmp_t = {}
			for i = 1, 5 do
				tmp_t[i] = {}
			end
			for k,v in pairs(data.finishFloors) do
				local tmp_num = math.modf(k/FIVE_NUMBER)
				tmp_t[tmp_num][k%FIVE_NUMBER] = true
			end
			data.finishFloors = tmp_t
			if req.func then
				req.func()
			else
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "enterFiveUniqueActivity",data,req.percent)	
			end
		else
			if not res.next then
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "reloadFiveUniqueActivity",data.dayTimesBuy,data.dayTimesUsed,data.finishFloors)
			end
			if req.func then
				req.func(groupId, data)
			end
		end

		g_i3k_game_context:SetTowerActivityPets(data.pets) --设置爬塔佣兵设置
		--i3k_log("------get_tower_card------", data.groupId,data.bestFloor,data.dayTimesBuy,data.dayTimesUsed,req.state,req.index )
		g_i3k_game_context:LeadCheck()
	end
end


-- 设置爬塔系统出战随从
function i3k_sbean.set_tower_pets(pets)
	local bean = i3k_sbean.tower_setpets_req.new()
	bean.pets = pets
	i3k_game_send_str_cmd(bean, "tower_setpets_res")
end

function i3k_sbean.tower_setpets_res.handler(res, req)
	if res.ok==1 then
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s", "保存成功"))
		g_i3k_ui_mgr:CloseUI(eUIID_FiveUniquePets)
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s", "服务器资讯：保存失败"))
	end
end

-- 购买挑战次数
function i3k_sbean.set_tower_buytimes(times,needDiamond,item,floor,func)
	local buy = i3k_sbean.tower_buytimes_req.new()
	--buy.times = timeBuyed+1
	buy.times = times
	buy.needDiamond = needDiamond
	buy.item = item
	buy.floor = floor
	buy.func = func
	i3k_game_send_str_cmd(buy, "tower_buytimes_res")
end

function i3k_sbean.tower_buytimes_res.handler(res, req)
	if res.ok==1 then
		local timeUsed,timeBuy, totalTimes = g_i3k_game_context:GetTowerChallengeTimes()
		local haveTimes = totalTimes+1-timeUsed
		totalTimes = totalTimes+1
		timeBuy = timeBuy +1
		g_i3k_game_context:SetTowerChallengeTimes(timeUsed,timeBuy, totalTimes)
		i3k_sbean.sync_activities_tower(true, req.floor-1, req.func)
		if req.item then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "buyTimesCB", haveTimes, totalTimes,req.item)
		end
		g_i3k_game_context:UseDiamond(req.needDiamond, false,AT_CLIMB_TOWER_BUY_TIMES)
	else
		g_i3k_ui_mgr:PopupTipMessage("购买失败，请重试")
	end
end

-- 开始战斗
function i3k_sbean.startfight_tower_activities(floor,id,mapId,groupId)
	local bean = i3k_sbean.tower_startfight_req.new()
	bean.floor = floor
	bean.id = id
	bean.mapId = mapId
	bean.groupId = groupId
	i3k_game_send_str_cmd(bean, "tower_startfight_res")
end

function i3k_sbean.tower_startfight_res.handler(res, req)--ok
	if res.ok==1 then
		
		--统计进入次数
		local mapId = req.mapId
		local map = {}
		local cfg = i3k_db_climbing_tower_fb[mapId]---
		map["组"..req.id] = tostring(mapId)
		local eventId = "进入爬塔副本"
		DCEvent.onEvent(eventId, map)
		g_i3k_game_context:UseVit(cfg.enterConsume,AT_START_CLIMB_TOWER_COPY)
		g_i3k_game_context:GetUserCfg():SetSelectFiveUniqueLevel(req.floor)
		--g_i3k_ui_mgr:OpenUI(eUIID_BattleFuben)
	
		g_i3k_ui_mgr:OpenUI(eUIID_KillTarget)
		g_i3k_ui_mgr:RefreshUI(eUIID_KillTarget,mapId)
		--i3k_log("tower_startfight_res = ------ ", mapId,req.id,req.floor)
	else
		local tips = string.format("%s", "爬塔资料即将跨天刷新，请在5点后进入")
		g_i3k_ui_mgr:PopupTipMessage(tips)
	end
end

-- 进入爬塔场景同步

function i3k_sbean.role_towermap_sync.handler(bean)--mapId,killCount
	--i3k_log("role_towermap_sync------", bean.mapId,bean.killCount)
	if not g_i3k_ui_mgr:GetUI(eUIID_KillTarget) then
		g_i3k_ui_mgr:OpenUI(eUIID_KillTarget)
	end
	
	g_i3k_ui_mgr:RefreshUI(eUIID_KillTarget,bean.mapId)
	g_i3k_game_context:setTowerKillCount(bean.killCount)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_KillTarget, "showInfo",bean.killCount)
	
	
end

-- 同步战绩记录
function i3k_sbean.sync_record_tower(groupId)
	local bean = i3k_sbean.tower_record_req.new()
	bean.groupId = groupId
	i3k_game_send_str_cmd(bean, "tower_record_res")
end

function i3k_sbean.tower_record_res.handler(res, req)--(data(ownData,sectData(roleId,name,floor),serverData(roleId,name,floor)))
	--local data = res.info.data
	if res.data then
		--i3k_log("------get_tower_card------", data.groupId,data.bestFloor,data.dayTimesBuy,data.dayTimesUsed)
		
		g_i3k_ui_mgr:OpenUI(eUIID_FiveUniqueExploits)
		g_i3k_ui_mgr:RefreshUI(eUIID_FiveUniqueExploits,res.data,req.groupId)
		
	end
end

-- 同步声望记录

function i3k_sbean.sync_fame_tower(groupId, percent, callBack)
	local bean = i3k_sbean.sync_towerfame_req.new()
	bean.groupId = groupId
	bean.percent = percent
	bean.callBack = callBack 
	i3k_game_send_str_cmd(bean, "sync_towerfame_res")
end

function i3k_sbean.sync_towerfame_res.handler(bean, req)
	if bean.data then
		if req and req.callBack then
			req.callBack()
		end
		for k,v in ipairs(bean.data) do
			g_i3k_game_context:SetRoleTowerPrestigeLvl(k,v.level,v.fame)
			
		end
		
		g_i3k_ui_mgr:OpenUI(eUIID_FiveUniquePrestige)
		g_i3k_ui_mgr:RefreshUI(eUIID_FiveUniquePrestige, bean.data, req.groupId, req.percent)
		-- g_i3k_ui_mgr:CloseUI(eUIID_SkillLy)
		
	end
end

-- 爬塔声望捐赠物品
function i3k_sbean.activities_towerfame_donate(actType,itemId,percent)
	local bean = i3k_sbean.tower_donate_req.new()
	bean.group = actType
	bean.itemId = itemId
	bean.percent = percent
	i3k_game_send_str_cmd(bean, "tower_donate_res")
end

function i3k_sbean.tower_donate_res.handler(res, req)--只有ok

	if res.ok > 0 then
		--扣道具req.
		g_i3k_game_context:UseCommonItem(req.itemId, 1,AT_USER_ITEM_TOWER_FAME)--UseBagMiscellaneous
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FiveUniquePrestige, "setFameTower",true)
		i3k_sbean.sync_fame_tower(req.group,req.percent)
		
	else
		g_i3k_ui_mgr:PopupTipMessage("捐赠物品失败或已达上限")
			
	end
	
end


-- 爬塔领取声望奖励
function i3k_sbean.activities_towerfame_take(actType,seq,gifts,item,percent,skillId,uniqueSkillId)
	local bean = i3k_sbean.take_towerfame_req.new()
	bean.group = actType
	bean.seq = seq
	
	bean.gifts = gifts
	bean.item = item
	bean.percent = percent
	bean.skillId = skillId
	bean.uniqueSkillId = uniqueSkillId
	i3k_game_send_str_cmd(bean,"take_towerfame_res")
end

function i3k_sbean.take_towerfame_res.handler(res, req)--只有ok
	local id = req.skillId 
	
	if res.ok > 0 then
		g_i3k_ui_mgr:ShowGainItemInfo(req.gifts)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FiveUniquePrestige, "changeBtnState",req.item)
		
		if id > 0 then
			local allUniqueSkill = g_i3k_game_context:GetRoleUniqueSkills()
			if not allUniqueSkill[id] then
				local sortId = i3k_db_exskills[req.uniqueSkillId].sortid	
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(515))
				g_i3k_game_context:SetCurRoleUniqueSkills(id,1, 0,sortId)--设置绝技
			end
		end
		i3k_sbean.sync_fame_tower(req.group,req.percent )
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

--通知客户端秘境任务

function i3k_sbean.role_secret_task.handler(bean)--data((id,value,reward))
	if bean and bean.data then
		--g_i3k_game_context:setRemmeberTaskId(6,bean.data.id)
		if bean.data.id and bean.data.id > 0 then
			g_i3k_game_context:AddTaskToDataList(TASK_CATEGORY_SECRETAREA, bean.data.receiveTime)
		end
		g_i3k_game_context:setSecretareaTaskIdAndValue(bean.data.id,bean.data.value )--{id = bean.data.id,value = bean.data.value}
	
		g_i3k_game_context:setSecretareaTaskId(bean.data.id, bean.data.value, bean.data.reward)
		
	end
end

-- 进入秘境
function i3k_sbean.enter_secretmap_task(mapId)
	if i3k_check_resources_downloaded(mapId) then
	local bean = i3k_sbean.enter_secretmap_req.new()
	
	bean.mapId = mapId
	i3k_game_send_str_cmd(bean, "enter_secretmap_res")
	end
end

function i3k_sbean.enter_secretmap_res.handler(res, req)--ok
	if res.ok==1 then
		
		--统计进入次数
		--[[
		local mapId = req.mapId
		local map = {}
		local cfg = i3k_db_climbing_tower_fb[mapId]---
		map["组"..req.id] = tostring(mapId)
		local eventId = "进入爬塔副本"
		DCEvent.onEvent(eventId, map)
		g_i3k_game_context:UseVit(cfg.enterConsume)]]
		g_i3k_game_context:setInSecretareaMap(req.mapId)
		
	else
		local tips = string.format("%s", "进入爬塔失败")
		g_i3k_ui_mgr:PopupTipMessage(tips)
	end
end
-- 领取秘境任务奖励
function i3k_sbean.activities_secretreward_take(id,gifts,info)
	local bean = i3k_sbean.take_secretreward_req.new()
	bean.id = id
	bean.gifts = gifts
	bean.info = info
	i3k_game_send_str_cmd(bean,"take_secretreward_res")
end

function i3k_sbean.take_secretreward_res.handler(res, req)--只有ok
	if res.ok > 0 then
		
		g_i3k_game_context:ResetDaySecretareaTask()---移除跟踪栏里的秘境
		
		if req.info.bestFloor then
			
			i3k_sbean.sync_activities_tower(true,req.info.bestFloor-1)--同步爬塔
		end
		g_i3k_game_context:setSecretareaTaskIdAndValue(0,0)
		g_i3k_game_context:setSecretareaTaskId(0,0,1)
		g_i3k_ui_mgr:PopupTipMessage("成功领取奖励")
		g_i3k_ui_mgr:CloseUI(eUIID_Secretarea)
		
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

---- 爬塔扫荡
function i3k_sbean.tower_sweep_take(floor,args,fbId,groupId)
	local bean = i3k_sbean.tower_sweep_req.new()
	bean.floor = floor
	bean.groupId = groupId
	bean.args = args
	bean.fbId = fbId
	i3k_game_send_str_cmd(bean,"tower_sweep_res")
end

function i3k_sbean.tower_sweep_res.handler(res,req)--data(monsters,rewards)

		local _t = res.data 
		if not _t then
			return 
		end
		local fbId = req.fbId

		local info =  req.args
		local dungeon_data = i3k_db_climbing_tower_fb[fbId]
		if dungeon_data then
			local consume = dungeon_data.enterConsume
			g_i3k_game_context:UseVit(consume,AT_SWEEP_TOWER_MAP)
			g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_TOWER, g_SCHEDULE_COMMON_MAPID)
		end
		
		local count = 0
		local totlaNormal = {}
		local totlCard = {}
		
		local coin = {}
		local exp = {}
		
			
		for i,j in pairs(_t.rewards) do
			count = count + 1
			local index = #coin
			coin[index+1] = j.coin
			local index = #exp
			exp[index + 1] = j.exp
			local normalData = {}
			for a,b in pairs(j.normalRewards) do 
				local temp = {}
				temp.id = tonumber(b.id)
				temp.count = tonumber(b.count)
				table.insert(normalData,temp)
			end
			local index = #totlaNormal
			totlaNormal[index + 1] = normalData
			local cardData = {}
			for a,b in pairs(j.cardRewards) do
				local temp = {}
				temp.id = tonumber(b.id)
				temp.count = tonumber(b.count)
				table.insert(cardData,temp)
			end
			local index = #totlCard
			totlCard[index +1] = cardData
		end
			
		g_i3k_game_context:setTowerSweep(info.groupId,req.floor,fbId)
		g_i3k_ui_mgr:OpenUI(eUIID_WIPEAward)	--显示扫荡结果
		g_i3k_ui_mgr:RefreshUI(eUIID_WIPEAward,coin,exp,totlaNormal,totlCard,count)
		info.bestFloor = info.bestFloor + 1
		i3k_sbean.sync_activities_tower(true,req.floor)--同步爬塔
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "onClickSelectAndUpdate", info)
		
end

function i3k_sbean.tower_onekey_donate(donateType, group)
	local data = i3k_sbean.tower_onekey_donate_req.new()
	data.donateType = donateType
	data.group = group
	i3k_game_send_str_cmd(data,"tower_onekey_donate_res")
end

function i3k_sbean.tower_onekey_donate_res.handler(bean, req)
	if bean.ok > 0 then
		if table.nums(bean.delItem) > 0 then
			for k, v in pairs(bean.delItem) do
				g_i3k_game_context:UseCommonItem(k, v, AT_USER_ITEM_TOWER_FAME)
			end
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_FiveUniquePrestige, "setFameTower",true)
			i3k_sbean.sync_fame_tower(req.group)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("使用失败")
	end
end

function i3k_sbean.tower_new_sweep(floors, vit, floor)
	local data = i3k_sbean.tower_new_sweep_req.new()
	data.floors = floors
	data.vit = vit
	data.floor = floor
	i3k_game_send_str_cmd(data, "tower_new_sweep_res")
end

function i3k_sbean.tower_new_sweep_res.handler(bean, req)
	if bean.ok > 0 then
		local count = 0
		local totlaNormal = {}
		local totlCard = {}
		local coin = {}
		local exp = {}
		for k, v in ipairs(bean.data) do
			for i, j in pairs(v.mapSummary.rewards) do
				count = count + 1
				local index = #coin
				coin[index+1] = j.coin
				local index = #exp
				exp[index + 1] = j.exp
				local normalData = {}
				for a,b in pairs(j.normalRewards) do 
					local temp = {}
					temp.id = tonumber(b.id)
					temp.count = tonumber(b.count)
					table.insert(normalData,temp)
				end
				local index = #totlaNormal
				totlaNormal[index + 1] = normalData
				local cardData = {}
				for a,b in pairs(j.cardRewards) do
					local temp = {}
					temp.id = tonumber(b.id)
					temp.count = tonumber(b.count)
					table.insert(cardData,temp)
				end
				local index = #totlCard
				totlCard[index +1] = cardData
			end
			local fbId = i3k_db_climbing_tower_datas[v.groupId][v.floor].fbID
			g_i3k_game_context:setTowerSweep(v.groupId, v.floor, fbId)
			g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_TOWER, g_SCHEDULE_COMMON_MAPID)
		end
		g_i3k_ui_mgr:OpenUI(eUIID_WIPEAward)	--显示扫荡结果
		g_i3k_ui_mgr:RefreshUI(eUIID_WIPEAward, coin, exp, totlaNormal, totlCard, count)
		if req then
			g_i3k_game_context:UseBaseItem(g_BASE_ITEM_VIT, req.vit, AT_SWEEP_TOWER_MAP)
			i3k_sbean.sync_activities_tower(true, req.floor)
		end
		g_i3k_ui_mgr:CloseUI(eUIID_FiveUniqueBatchSweep)
	else
		g_i3k_ui_mgr:PopupTipMessage("扫荡失败")
	end
end
