------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/network/channel/i3k_channel");

-----------------------------------
-- 副本扫荡请求响应（返回是否成功以及成功时的奖励）
function i3k_sbean.privatemap_sweep_res.handler(bean,res)
	local _t = bean.summary
	if not _t then
		return
	end
	local mapID = res.mapId
	local times = res.times
	local extraCard = res.extraCard
	local diamondNeed = i3k_db_common.wipe.ingot
	local dungeon_data = i3k_db_new_dungeon[mapID]
	if dungeon_data then
		local consume = dungeon_data.consume
		g_i3k_game_context:UseVit(consume*times,AT_SWEEP_PRIVATE_MAP)
		if extraCard ~= 0 then
			g_i3k_game_context:UseCommonItem(g_BASE_ITEM_DIAMOND,diamondNeed*times,AT_SWEEP_PRIVATE_MAP)
		end
		local scheduleType
		if dungeon_data.difficulty == 2 then
			scheduleType = g_SCHEDULE_TYPE_COMMON
		elseif dungeon_data.difficulty == 3 then
			scheduleType = g_SCHEDULE_TYPE_HARD
		end
		if scheduleType then
			for i = 1 , times do
				g_i3k_game_context:ChangeScheduleActivity( scheduleType, mapID )
			end
		end
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
	g_i3k_game_context:UseBagMiscellaneous(SWEEP_COUPON, times)
	g_i3k_game_context:addDungeonEnterTimes(mapID,times)
	g_i3k_game_context:setDungeonEndScore(mapID, i3k_db_new_dungeon[mapID].wipeScore)
	g_i3k_ui_mgr:OpenUI(eUIID_WIPEAward)
	g_i3k_ui_mgr:RefreshUI(eUIID_WIPEAward,coin,exp,totlaNormal,totlCard,count)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FBLB, "updateDungeonData")
	for k,v in ipairs(i3k_db_mercenaries) do
		local taskID,value = g_i3k_game_context:getPetTskIdAndValueById(k)
		local pet_task_cfg = g_i3k_db.i3k_db_get_pet_task_cfg(taskID)
		if pet_task_cfg then
			local taskType = pet_task_cfg.type
			if taskType == g_TASK_GET_TO_FUBEN then
				g_i3k_game_context:UpdatePetTaskValue(taskType,mapID)
				break;
			end
		end
	end
	g_i3k_game_context:SetTaskDataByTaskType(mapID, g_TASK_GET_TO_FUBEN)
end


function i3k_sbean.activity_wipe(mapId,times,extraCard)
	local data = i3k_sbean.activity_sweep_req.new()
	data.extraCard = extraCard
	data.times = times
	data.mapId = mapId
	i3k_game_send_str_cmd(data, "activity_sweep_res")
end
-- 活动副本扫荡请求响应（返回是否成功以及成功时的奖励）
function i3k_sbean.activity_sweep_res.handler(res,req)
	local _t = res.summary
	if not _t then
		return
	end
	local mapID = req.mapId
	local times = req.times
	local extraCard = req.extraCard
	local diamondNeed = i3k_db_common.wipe.ingot
	local dungeon_data = i3k_db_activity_cfg[mapID]
	if dungeon_data then
		local consume = dungeon_data.needTili
		g_i3k_game_context:UseVit(consume*times,AT_SWEEP_PRIVATE_MAP)
		if extraCard ~= 0 then
			g_i3k_game_context:UseCommonItem(g_BASE_ITEM_DIAMOND,diamondNeed*times,AT_SWEEP_PRIVATE_MAP)
		end
		for i = 1 , times do
			g_i3k_game_context:ChangeScheduleActivity( g_SCHEDULE_TYPE_ACT, dungeon_data.groupId )
		end
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

	g_i3k_game_context:UseCommonItem(SWEEP_COUPON, times,AT_SWEEP_PRIVATE_MAP)
	g_i3k_game_context:addActivityDayEnterTime(mapID,times)

	g_i3k_ui_mgr:OpenUI(eUIID_WIPEAward)
	g_i3k_ui_mgr:RefreshUI(eUIID_WIPEAward,coin,exp,totlaNormal,totlCard,count)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "updateDailyActivity")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_ActivityDetail, "updateWipeWidget")

	--g_i3k_ui_mgr:InvokeUIFunction(eUIID_FBLB, "updateDungeonData")
	for k,v in ipairs(i3k_db_mercenaries) do
		local taskID,value = g_i3k_game_context:getPetTskIdAndValueById(k)
		local pet_task_cfg = g_i3k_db.i3k_db_get_pet_task_cfg(taskID)
		if pet_task_cfg then
			local taskType = pet_task_cfg.type
			if taskType == g_TASK_GET_TO_FUBEN then
				g_i3k_game_context:UpdatePetTaskValue(taskType,mapID)
				break
			end
		end
	end
end


--房间创建成功
function i3k_sbean.mroom_create(mapId, roomType)
	local data = i3k_sbean.mroom_create_req.new()
	data.mapId = mapId
	data.type = roomType or gRoom_Dungeon
	i3k_game_send_str_cmd(data, "mroom_create_res")
end

function i3k_sbean.mroom_create_res.handler(bean, res)
	if bean.ok > 0 then
		i3k_sbean.mroom_self()
		DCEvent.onEvent("创建副本房间")
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5526))
	end
end


function i3k_sbean.justicemap_day_enter_time.handler(bean,res)
	g_i3k_game_context:setRightHeartEnterTimes(bean.dayJusticeEnterTimes)
end

function i3k_sbean.mroom_enterReq(roomId, mapId, roomTypetype)
	local data = i3k_sbean.mroom_enter_req.new()
	data.roomId = roomId
	data.mapId = mapId
	data.roomType = roomTypetype
	i3k_game_send_str_cmd(data,i3k_sbean.mroom_enter_res.getName())
end

--加入房间返回
function i3k_sbean.mroom_enter_res.handler(bean,res)
	if bean.ok > 0 then
		i3k_sbean.mroom_self()
	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(502))
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(504))
	elseif bean.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(505))
	elseif bean.ok == -4 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(507))
	elseif bean.ok == -11 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3181))
	elseif bean.ok == -12 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1402))
	end
end

function i3k_sbean.justicemap_start()
	local data = i3k_sbean.justicemap_start_req.new()
	data.mapId = mapId
	i3k_game_send_str_cmd(data, "justicemap_start_res")
end
function i3k_sbean.justicemap_start_res.handler(bean,res)
	if bean.ok <= 0 then
		if bean.ok == -1 then
			g_i3k_ui_mgr:PopupTipMessage("有队友离线，进入失败")
		elseif bean.ok == -2 then
			g_i3k_ui_mgr:PopupTipMessage("有队友进入次数不足，进入失败")
		elseif bean.ok == -3 then
			g_i3k_ui_mgr:PopupTipMessage("有队友距离NPC太远，进入失败")
		elseif bean.ok == -4 then
			g_i3k_ui_mgr:PopupTipMessage("NPC已不在此位置，进入失败")
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5526))
		end
	end
end

function i3k_sbean.start_npc_mapReq(groupId)
	local mapID = g_i3k_db.i3k_db_get_npcMapID_by_groupID(groupId)
	if i3k_check_resources_downloaded(mapID) then
	local bean = i3k_sbean.start_npc_map_req.new()
	bean.mapId = groupId
	i3k_game_send_str_cmd(bean, "start_npc_map_res")
	end
end

function i3k_sbean.start_npc_map_res.handler(bean)
	if bean.ok > 0 then
	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage("有队友离线，进入失败")
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage("有队友进入次数不足，进入失败")
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5526))
	end
end

--自己点击加入服务器同步消息
function i3k_sbean.mroom_sync.handler(bean,res)
	g_i3k_game_context:SetMroomSync(bean.room)
end

--有人进入房间服务器同步消息
function i3k_sbean.mroom_join.handler(bean,res)
	local roleId = bean.roleId
	local roleName = bean.roleName
	g_i3k_game_context:AddRoomRoleCount()
	i3k_sbean.mroom_self()
end

--有人离开房间服务器同步消息
function i3k_sbean.mroom_leave.handler(bean,res)
	g_i3k_game_context:SetMroomLeaveData(bean.roleId)
end

--有人被踢出房间服务器同步消息
function i3k_sbean.mroom_kick.handler(bean,res)
	g_i3k_game_context:SetMroomKickData(bean.roleId)
end

--切换队长服务器同步消息
function i3k_sbean.mroom_change_leader.handler(bean,res)
	g_i3k_game_context:SetMroomChangeLeaderData(bean.roleId)
end

--邀请人加入房间同步消息
function i3k_sbean.mroom_invite(roleId, roleName)
	local data = i3k_sbean.mroom_invite_req.new()
	data.roleId = roleId
	data.roleName = roleName
	i3k_game_send_str_cmd(data, "mroom_invite_res")
end

function i3k_sbean.mroom_invite_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:SetMroomInviteData(bean.ok, req.roleName)
	elseif bean.ok == -9 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3078))
	elseif bean.ok==-10 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(353,"对方"))
	elseif bean.ok == - 11 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3180))
	elseif bean.ok == -12 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1402))
	end
end

--被邀请的协议
function i3k_sbean.mroom_invite_forward.handler(bean,res)
	g_i3k_game_context:SetInviteForward(bean.roleId, bean.roleName, bean.mapId, bean.roomId, bean.type)
end

--房间附近的人
function i3k_sbean.mroom_mapr(freshType)
	local data = i3k_sbean.mroom_mapr_req.new()
	data.freshType = freshType

	i3k_game_send_str_cmd(data, "mroom_mapr_res")
end

function i3k_sbean.mroom_mapr_res.handler(bean,res)
	g_i3k_game_context:SetMroomNearData(bean.roles, res.freshType)
end

--查询房间协议
function i3k_sbean.mroom_self()
	local data = i3k_sbean.mroom_self_req.new()
	i3k_game_send_str_cmd(data, "mroom_self_res")
end

function i3k_sbean.mroom_self_res.handler(bean, res)
	g_i3k_game_context:SetMroomSelfData(bean.roles)
end

--查询房间列表
function i3k_sbean.mroom_query(mapId)
	local data = i3k_sbean.mroom_query_req.new()
	data.mapId = mapId
	i3k_game_send_str_cmd(data, "mroom_query_res")
end

function i3k_sbean.mroom_query_res.handler(bean,res)
	g_i3k_game_context:SetMroomQuery(bean.roles)
end

-- 通知邀请者前面的邀请被拒绝
function i3k_sbean.mroom_invite_refuse.handler(bean)
	local roleName = bean.roleName
	g_i3k_game_context:SetRoomInviteRefuse(roleName)
end

-- 通知邀请者被邀请的人正忙
function i3k_sbean.mroom_invite_busy.handler(bean)
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(354, bean.roleName))
end

-- 通知邀请者被邀请的人条件不满足
function i3k_sbean.mroom_invite_fail.handler(bean)
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(390, bean.roleName))
end

-- 玩家是否同意加入副本房间的协议
function i3k_sbean.mroom_invitedby_res.handler(bean, req)
	if bean.ok == -11 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3181))
		return
	end
	local condition = req.accept
	local mapId = req.mapId
	if req.type == gRoom_Dungeon then
		if condition == 1 and mapId ~= 0 then
			if g_i3k_game_context:GetLevel() < i3k_db_new_dungeon[mapId].reqLvl then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(69))
				return
			end
			local nedd_dungeon = i3k_db_new_dungeon[mapId].conditionDungeon
			if nedd_dungeon ~= -1 then
				if g_i3k_game_context:getDungeonFinishTimes(nedd_dungeon) < 1 then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(70, i3k_db_new_dungeon[nedd_dungeon].name, i3k_db_new_dungeon[mapId].name))
					return
				end
			end
		end
	elseif req.type == gRoom_NPC_MAP then

	elseif req.type == gRoom_TOWER_DEFENCE then --TODO

	end
end

--副本房间更换房主请求协议
function i3k_sbean.dungeon_change_leader(roleId)
	local data = i3k_sbean.mroom_change_leader_req.new()
	data.roleId = roleId
	i3k_game_send_str_cmd(data, "mroom_change_leader_res")
end

function i3k_sbean.mroom_change_leader_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetMroomChangeLeaderData(req.roleId)
		g_i3k_ui_mgr:PopupTipMessage(string.format("更换房主成功"))
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("更换房主失败"))
	end
end
