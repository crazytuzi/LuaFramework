------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")


--同步江湖客栈信息
function i3k_sbean.sync_hostel()
	local sync = i3k_sbean.treasure_syncnpcs_req.new()
	i3k_game_send_str_cmd(sync, "treasure_syncnpcs_res")
end

function i3k_sbean.treasure_syncnpcs_res.handler(bean, res)
	local info = bean.npcInfo
	if info then
		--g_i3k_game_context:setTreasureFinishMap(info.finishMaps)
		g_i3k_game_context:setAllNpcInfo(info.npcs)
		g_i3k_game_context:setHasBuyedChips(info.pieceLog)
		g_i3k_game_context:setTreasureChipOwnCounts(bean.pieces)
		g_i3k_ui_mgr:OpenUI(eUIID_NpcHotel)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_NpcHotel, "initHeadiconScroll", info.npcs)
	else

	end
end




--刷新某个NPC信息
function i3k_sbean.refresh_treasure_npc(npcID, times, callback)
	local refresh = i3k_sbean.treasure_refreshnpc_req.new()
	refresh.npcID = npcID
	refresh.times = times
	refresh.callback = callback
	i3k_game_send_str_cmd(refresh, "treasure_refreshnpc_res")
end

function i3k_sbean.treasure_refreshnpc_res.handler(bean, res)
	if bean.info then
		if res.callback then
			res.callback()
		end
		g_i3k_game_context:setNpcInfo(res.npcID, bean.info)
		-- g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "importNpcData", res.npcID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_NpcHotel, "importNpcData", res.npcID)
	else
		g_i3k_ui_mgr:PopupTipMessage("刷新失败，服务器错误资讯")
	end
end




--购买藏宝图碎片
function i3k_sbean.buy_treasure_chip(npcID, pieceID, callback, count)
	local buy = i3k_sbean.treasure_buypieces_req.new()
	buy.npcID = npcID
	buy.pieceID = pieceID
	buy.callback = callback
	buy.count = count
	i3k_game_send_str_cmd(buy, "treasure_buypieces_res")
end

function i3k_sbean.treasure_buypieces_res.handler(bean, res)
	if bean.ok==1 then
		if res.callback then
			res.callback()
		end

		g_i3k_game_context:addHasBuyedChips(res.pieceID)
		local info = g_i3k_game_context:getNpcInfoById(res.npcID)
		info.lib[res.pieceID] = 0
		info.fame = info.fame + i3k_db_treasure_chip[res.pieceID].npcFriendly
		g_i3k_game_context:setNpcInfo(res.npcID, info)
		g_i3k_game_context:addTreasureChipOwnCounts(res.pieceID, res.count)
		-- g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "importNpcData", res.npcID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_NpcHotel, "importNpcData", res.npcID)

		local map = {}
		local eventId = "江湖客栈碎片购买"
		map["碎片" .. res.pieceID] = res.count
		DCEvent.onEvent(eventId, map)
	else
		g_i3k_ui_mgr:PopupTipMessage("购买碎片失败，服务器错误")
	end
end





--领取NPC礼包
function i3k_sbean.get_npc_reward(npcID)
	local get = i3k_sbean.treasure_npcreward_req.new()
	get.npcID = npcID
	i3k_game_send_str_cmd(get, "treasure_npcreward_res")
end

function i3k_sbean.treasure_npcreward_res.handler(bean, res)
	if bean.ok==1 then
		local info = g_i3k_game_context:getNpcInfoById(res.npcID)
		info.reward = info.reward + 1
		g_i3k_game_context:setNpcInfo(res.npcID, info)
		-- g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "importNpcData", res.npcID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_NpcHotel, "importNpcData", res.npcID)
		local totalRewards = {}
		for i,v in pairs(bean.rewards) do
			local tmpReward = {id = i, count = v}
			table.insert(totalRewards, tmpReward)
		end
		g_i3k_ui_mgr:ShowGainItemInfo(totalRewards)
	elseif bean.ok==-1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
	else
		g_i3k_ui_mgr:PopupTipMessage("领取礼包奖励 服务器错误资讯")
	end
end



--公测返现查询
function i3k_sbean.query_reward()
	local query = i3k_sbean.pbtcashback_sync_req.new()
	i3k_game_send_str_cmd(query,"pbtcashback_sync_res")
end

function i3k_sbean.pbtcashback_sync_res.handler(bean,req)
	if bean.ok == 1 then
		if bean.result >= 0 then
			g_i3k_ui_mgr:OpenUI(eUIID_FanXian)
			g_i3k_ui_mgr:RefreshUI(eUIID_FanXian,bean.result)
		elseif bean.result == -102 or bean.result == -101 then
			g_i3k_ui_mgr:PopupTipMessage("网路超时")
		elseif bean.result == -1002 or bean.result == -1003 then
			g_i3k_ui_mgr:PopupTipMessage("您已经领取过该奖励")
		elseif bean.result == -1001 then
			g_i3k_ui_mgr:PopupTipMessage("未查询到您的帐号在当前管道测试期间的储值记录")
		elseif bean.result == -1 then
			g_i3k_ui_mgr:PopupTipMessage("网路异常")
		else
			g_i3k_ui_mgr:PopupTipMessage("网路错误")
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("网路错误")
	end
end


--公测返现兑换
function i3k_sbean.take_reward()
	local take = i3k_sbean.pbtcashback_take_req.new()
	i3k_game_send_str_cmd(take,"pbtcashback_take_res")
end

function i3k_sbean.pbtcashback_take_res.handler(bean,req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FanXian, "update", bean.addtion)
	elseif bean.ok == -1001 then
		g_i3k_ui_mgr:PopupTipMessage("未查询到您的帐号在当前管道测试期间的储值记录")
	elseif bean.ok == -1002 then
		g_i3k_ui_mgr:PopupTipMessage("您已领取过该奖励")
	elseif bean.ok == -1007 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(288))
	else
		g_i3k_ui_mgr:PopupTipMessage("网路错误，领取失败")
	end
end


--藏宝图同步
function i3k_sbean.sync_treasure()
	local sync = i3k_sbean.treasure_syncmap_req.new()
	i3k_game_send_str_cmd(sync, "treasure_syncmap_res")
end

function i3k_sbean.treasure_syncmap_res.handler(bean, res)
	local mapInfo = bean.mapInfo
	if mapInfo then
		if mapInfo.curMap.mapID~=0 and mapInfo.curMap.open~=0 then
			g_i3k_game_context:setTreasureMapInfo(mapInfo.curMap)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "loadTreasureChipData", mapInfo)
	else
		g_i3k_ui_mgr:PopupTipMessage("藏宝图同步服务器错误资讯")
	end
end






--合成藏宝图
function i3k_sbean.make_map(chipId, callback)
	local make = i3k_sbean.treasure_makemap_req.new()
	make.pieceID = chipId
	make.callback = callback
	i3k_game_send_str_cmd(make, "treasure_makemap_res")
end

function i3k_sbean.treasure_makemap_res.handler(bean, res)
	if bean.ok==1 then
		if res.callback then
			res.callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s", "合成失败"))
	end
end






--总体探索
function i3k_sbean.explore_treasure(mapId, callback)
	local explore = i3k_sbean.treasure_totalsearch_req.new()
	explore.callback = callback
	explore.mapId = mapId
	i3k_game_send_str_cmd(explore, "treasure_totalsearch_res")
end

function i3k_sbean.treasure_totalsearch_res.handler(bean, res)
	if bean.curMap then
		g_i3k_game_context:setTreasureMapInfo(bean.curMap)
		if res.callback then
			res.callback()
		end

		DCEvent.onEvent("藏宝图总体探索", { ["藏宝图ID"] = tostring(res.mapId)})
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s", "探索失败，服务器错误资讯"))
	end
end




--探索情报点
function i3k_sbean.explore_spot(index, callback)
	local explore = i3k_sbean.treasure_search_req.new()
	explore.pointIndex = index
	explore.callback = callback
	i3k_game_send_str_cmd(explore, "treasure_search_res")
end

function i3k_sbean.treasure_search_res.handler(bean, res)
	if bean.ok>0 then
		if res and res.callback then
			res.callback()
		end
		local info = g_i3k_game_context:getTreasureMapInfo()
		local spotTable = i3k_db_treasure[info.mapID].clueSpotList
		for i,v in pairs(info.points) do
			if v==0 then
				local spotCfg = i3k_db_spot_list[spotTable[i]]
				local structType = i3k_db_treasure[info.mapID].clueType
				local percent = i3k_db_treasure_base["struct"..structType]["percent"..i]
				if spotCfg.spotType==g_KILL_MONSTER then
					local iconId = i3k_db_treasure_base.other.killOkId
					g_i3k_ui_mgr:OpenUI(eUIID_FindClue)
					g_i3k_ui_mgr:RefreshUI(eUIID_FindClue, i3k_db_dialogue[spotCfg.textId1[1]][1].txt, iconId, percent, i==#spotTable)
				elseif spotCfg.spotType==g_DIALOGUE then
					local iconId = i3k_db_treasure_base.other.npcOkId
					local targetNpc = g_i3k_game_context:GetNPCbyID(spotCfg.arg1)
					local callback = function ()
						g_i3k_ui_mgr:OpenUI(eUIID_FindClue)
						g_i3k_ui_mgr:RefreshUI(eUIID_FindClue, i3k_db_dialogue[spotCfg.textId5[1]][1].txt, iconId, percent, i==#spotTable)
					end
					if targetNpc:IsShow() then
						g_i3k_ui_mgr:PopTextBubble(true, i3k_game_get_player_hero(), i3k_db_dialogue[spotCfg.textId1[1]][1].txt, targetNpc, i3k_db_dialogue[spotCfg.textId4[1]][1].txt, callback)
					end
				elseif spotCfg.spotType==g_DIG then
					local iconId = i3k_db_treasure_base.other.digOkId
					g_i3k_ui_mgr:OpenUI(eUIID_FindClue)
					g_i3k_ui_mgr:RefreshUI(eUIID_FindClue, i3k_db_dialogue[spotCfg.textId2[1]][1].txt, iconId, percent, i==#spotTable)
				else
					local iconId = i3k_db_treasure_base.other.boxOkId
					g_i3k_ui_mgr:OpenUI(eUIID_FindClue)
					g_i3k_ui_mgr:RefreshUI(eUIID_FindClue, i3k_db_dialogue[spotCfg.textId1[1]][1].txt, iconId, percent, i==#spotTable)
				end
				info.points[i] = 1
				if spotTable[i+1] then
					info.points[i+1] = 0
				end
				g_i3k_game_context:setTreasureMapInfo(info)
				--g_i3k_ui_mgr:RefreshUI(eUIID_BattleTreasure)
				break
			end
		end
	else
		local info = g_i3k_game_context:getTreasureMapInfo()
		local spotTable = i3k_db_treasure[info.mapID].clueSpotList
		local targetId = g_i3k_game_context:GetNearestNPCID()
		local responseTreasure=i3k_db_npc[targetId].npcToTreasure
		for i,v in pairs(info.points) do
			if v==0 then
				local hero = i3k_game_get_player_hero()
				local spotCfg = i3k_db_spot_list[spotTable[i]]
				if spotCfg.spotType==g_DIALOGUE then
					local isupdate = 0
					local targetPos = g_i3k_db.i3k_db_get_npc_pos(spotCfg.arg1)
					local dis = i3k_vec3_dist(hero._curPosE, targetPos)
					local text = i3k_db_dialogue[spotCfg.textId3[1]][1].txt
					if dis<i3k_db_treasure_base.other.talkRadius then
						text = text..i3k_get_string(15070)
					else
						text = text..i3k_get_string(15069)
					end
					local callback = function ()
						local iconId = i3k_db_treasure_base.other.npcFailedId
						g_i3k_ui_mgr:OpenUI(eUIID_ExploreSpotFailed)
						g_i3k_ui_mgr:RefreshUI(eUIID_ExploreSpotFailed, text, iconId)
					end
					if targetId~=-1 and responseTreasure == 0 then
						local targetNpc = g_i3k_game_context:GetNPCbyID(targetId)
						local index = math.random(0, #spotCfg.textId2)
						local textIndex = math.ceil(index)
						textIndex = textIndex==0 and 1 or textIndex
						if targetNpc:IsShow() then
							isupdate = 1
							g_i3k_ui_mgr:CloseUI(eUIID_ExploreSpotFailed)
							g_i3k_ui_mgr:PopTextBubble(false, i3k_game_get_player_hero(), i3k_db_dialogue[spotCfg.textId1[1]][1].txt, targetNpc, i3k_db_dialogue[spotCfg.textId2[textIndex]][1].txt, callback)
						end
					else
						isupdate = 1
						g_i3k_ui_mgr:CloseUI(eUIID_ExploreSpotFailed)
						g_i3k_ui_mgr:PopTextBubble(false, i3k_game_get_player_hero(), i3k_db_dialogue[spotCfg.textId1[1]][1].txt, nil, nil, callback)
					end
					if isupdate == 0 then
						g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTreasure,"setFuncBtnEnabled",true)
						local texts = "周围没有人，不要乱讲话"
						local iconId = i3k_db_treasure_base.other.npcFailedId
						g_i3k_ui_mgr:OpenUI(eUIID_ExploreSpotFailed)
						g_i3k_ui_mgr:RefreshUI(eUIID_ExploreSpotFailed, texts, iconId)
					end
				elseif spotCfg.spotType==g_DIG then
					targetPos = i3k_db_dungeon_base[spotCfg.arg1].revivePos
					targetPos.x = spotCfg.arg2
					targetPos.z = spotCfg.arg3
					local dis = i3k_vec3_dist(hero._curPosE, targetPos)
					local index = math.random(0, #spotCfg.textId1)
					local textIndex = math.ceil(index)
					textIndex = textIndex==0 and 1 or textIndex
					local text = i3k_db_dialogue[spotCfg.textId1[textIndex]][1].txt
					if dis>=i3k_db_treasure_base.other.digRadius then
						text = text..i3k_get_string(15100)
					else
						text = text..i3k_get_string(15101)
					end
					local iconId = i3k_db_treasure_base.other.digFailedId
					g_i3k_ui_mgr:OpenUI(eUIID_ExploreSpotFailed)
					g_i3k_ui_mgr:RefreshUI(eUIID_ExploreSpotFailed, text, iconId)
				else
					g_i3k_ui_mgr:PopupTipMessage("spotCfg.spotType = screct box")
				end
				g_i3k_game_context:setTreasureMapInfo(info)
				--g_i3k_ui_mgr:RefreshUI(eUIID_BattleTreasure)
				break
			end
		end

	end
end





--放弃藏宝图
function i3k_sbean.giveup_treasure(mapId, callback)
	local giveup = i3k_sbean.treasure_quitmap_req.new()
	giveup.callback = callback
	giveup.mapId = mapId
	i3k_game_send_str_cmd(giveup, "treasure_quitmap_res")
end

function i3k_sbean.treasure_quitmap_res.handler(bean, res)
	if bean.ok==1 then
		if res.callback then
			res.callback()
		end
		i3k_sbean.sync_treasure()
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleTreasure)

		DCEvent.onEvent("放弃藏宝图", { ["藏宝图ID"] = tostring(res.mapId)})
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s", "放弃失败，服务器错误资讯"))
	end
end




--领取藏宝图奖励
function i3k_sbean.take_map_reward(totalPercent)
	local take = i3k_sbean.treasure_mapreward_req.new()
	take.totalPercent = totalPercent
	i3k_game_send_str_cmd(take, "treasure_mapreward_res")
end

function i3k_sbean.treasure_mapreward_res.handler(bean, res)
	local rewards = bean.rewards
	if bean.ok==1 and rewards then
		local isFinish = false
		local mapInfo = g_i3k_game_context:getTreasureMapInfo()
		local collectionId = i3k_db_treasure[mapInfo.mapID].collectId
		for i,v in ipairs(mapInfo.points) do
			if v==1 and not mapInfo.points[i+1] then
				isFinish = true
			end
		end
		if isFinish and not g_i3k_game_context:getCollectionWithId(collectionId) then
			g_i3k_game_context:SetPrePower()
			g_i3k_game_context:addCollection(collectionId)
			g_i3k_ui_mgr:OpenUI(eUIID_GetCollection)
			g_i3k_ui_mgr:RefreshUI(eUIID_GetCollection, collectionId)
			local hero = i3k_game_get_player_hero()
			if hero then
				hero:UpdateCollectionProps()
				g_i3k_game_context:ShowPowerChange()
			end
		end


		local totalRewards = {}
		for i,v in pairs(rewards) do
			local tmpReward = {id = i, count = v}
			table.insert(totalRewards, tmpReward)
		end
		if g_i3k_ui_mgr:GetUI(eUIID_GetCollection) then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_GetCollection, "addMessageBox", totalRewards)
		else
			g_i3k_ui_mgr:ShowGainItemInfo(totalRewards)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "takeTreasureReward")
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleTreasure)

		DCEvent.onEvent("藏宝图领奖", { ["完成度"] = tostring(res.totalPercent)})

		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_TREASURE, g_SCHEDULE_COMMON_MAPID)

	elseif bean.ok==-1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
	end
end




--装裱收藏品
function i3k_sbean.mount_collection(collectionId, collectionType, callback)
	local mount = i3k_sbean.treasure_medalgrow_req.new()
	mount.medalID = collectionId
	mount.type = collectionType
	mount.callback = callback
	i3k_game_send_str_cmd(mount, "treasure_medalgrow_res")
end

function i3k_sbean.treasure_medalgrow_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:mountCollection(res.medalID)
		local hero = i3k_game_get_player_hero()
		if hero then
			hero:UpdateCollectionProps()
			g_i3k_game_context:ShowPowerChange()
		end
		if res.callback then
			res.callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17727))
	end
end

--镶边收藏品
function i3k_sbean.edge_collection(collectionId, collectionType, callback)
	local edge = i3k_sbean.treasure_edge_req.new()
	edge.medalID = collectionId
	edge.type = collectionType
	edge.callback = callback
	i3k_game_send_str_cmd(edge, "treasure_edge_res")
	end
function i3k_sbean.treasure_edge_res.handler(bean, req)
	if bean.ok == 1 then
		if req.callback then
			req.callback()
end
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:edgeCollection(req.medalID)
		local hero = i3k_game_get_player_hero()
		if hero then
			hero:UpdateCollectionProps()
			g_i3k_game_context:ShowPowerChange()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17722))
	end
end



--收藏品同步（登陆）
function i3k_sbean.role_treasure_info.handler(bean)
	local medals = bean.medals
	for i,v in pairs(medals) do
		g_i3k_game_context:addCollection(i, v==1 or v == 2,  v == 2)
	end
	g_i3k_game_context:setIsHaveMapCanExplore(bean.curMap.mapID~=0 and bean.curMap.open==0)
	if bean.curMap.mapID~=0 and bean.curMap.open~=0 then
		g_i3k_game_context:setTreasureMapInfo(bean.curMap)
	end
end

--是否藏宝图引导
function i3k_sbean.role_treasureguide.handler(bean)
	g_i3k_game_context:setIsFirstTreasure(true)
end


-- 藏宝图扫荡
function i3k_sbean.saodangTreasureMap()
	local mount = i3k_sbean.treasure_map_one_key_reward_req.new()
	i3k_game_send_str_cmd(mount, "treasure_map_one_key_reward_res")
end

function i3k_sbean.treasure_map_one_key_reward_res.handler(res, req)
	if res.ok > 0 then
		local totalRewards = {}
		for i,v in pairs(res.rewards) do
			local tmpReward = {id = i, count = v}
			table.insert(totalRewards, tmpReward)
		end
		g_i3k_ui_mgr:ShowGainItemInfo(totalRewards)
		i3k_sbean.sync_treasure()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "takeTreasureReward")
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_TREASURE, g_SCHEDULE_COMMON_MAPID)
	end
end
