------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

--同步多人竞技场数据
function i3k_sbean.team_arena_sync()
	local sync = i3k_sbean.superarena_sync_req.new()
	i3k_game_send_str_cmd(sync, "superarena_sync_res")
end

function i3k_sbean.superarena_sync_res.handler(bean, res)
	if bean.info then
		local point = bean.info.point
		g_i3k_game_context:syncTournamentPoint(point)
		g_i3k_game_context:SetBudoCount(bean.info.teamFightCoin)
		for i,_ in pairs(bean.info.pets) do
			g_i3k_game_context:SetTournamentPet(i)
		end
		g_i3k_game_context:setTournamentData(bean.info)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadTournament", bean.info)
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s", "会武场进入失败"))
	end
end


--单人匹配
function i3k_sbean.mate_alone(theType)
	local mate = i3k_sbean.superarena_singlejoin_req.new()
	mate.type = theType
	i3k_game_send_str_cmd(mate, "superarena_singlejoin_res")
end

function i3k_sbean.superarena_singlejoin_res.handler(bean, res)
	local errStr = {
	}
	if bean.ok==1 then
		
	else
		if errStr[bean.ok] then
			g_i3k_ui_mgr:PopupTipMessage(errStr[bean.ok])
		end
		g_i3k_game_context:StopMatchingState()
		--g_i3k_ui_mgr:CloseUI(eUIID_Matching)
	end
end


--组队匹配
function i3k_sbean.mate_team(theType)
	local mate = i3k_sbean.superarena_teamjoin_req.new()
	mate.type = theType
	i3k_game_send_str_cmd(mate, "superarena_teamjoin_res")
end

function i3k_sbean.superarena_teamjoin_res.handler(bean, res)
	if bean.ok==1 then
		--g_i3k_ui_mgr:CloseUI(eUIID_TournamentRoom)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_TournamentRoom, "startMatching")
	else
		g_i3k_game_context:StopMatchingState()
		--g_i3k_ui_mgr:CloseUI(eUIID_Matching)
	end
end


--通知其他成员开始匹配
function i3k_sbean.superarena_startmatch.handler(bean)
	--g_i3k_ui_mgr:OpenUI(eUIID_Matching)
	g_i3k_game_context:InMatchingState(i3k_game_get_time(), g_TOURNAMENT_MATCH, g_i3k_game_context:GetRoomType())
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_TournamentRoom, "startMatching")
end


--匹配结果
function i3k_sbean.superarena_join.handler(bean)
	g_i3k_game_context:StopMatchingState()
	if bean.ok==1 then
		g_i3k_ui_mgr:PopupTipMessage(string.format("匹配成功"))
		--g_i3k_ui_mgr:CloseUI(eUIID_Matching)
	else
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_TournamentRoom, "stopMatching")
		if g_i3k_ui_mgr:GetUI(eUIID_WaitTip) then
			if g_i3k_ui_mgr:InvokeUIFunction(eUIID_WaitTip, "getWaitType")==g_TOURNAMENT_WAIT then
				g_i3k_ui_mgr:CloseUI(eUIID_WaitTip)
			end
		end
		if bean.ok==-1 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(346, "离线状态"))
		elseif bean.ok==-5 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(344, i3k_db_tournament_base.needLvl))
		elseif bean.ok==-6 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(345))
		elseif bean.ok==-21 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1009))
		elseif bean.ok==-22 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(347))
		end
		--g_i3k_ui_mgr:CloseUI(eUIID_Matching)
	end
end


--取消匹配
function i3k_sbean.cancel_mate()
	local cancel = i3k_sbean.superarena_quit_req.new()
	i3k_game_send_str_cmd(cancel, "superarena_quit_res")
end

function i3k_sbean.superarena_quit_res.handler(bean, res)
	if bean.ok==1 then
		--g_i3k_ui_mgr:CloseUI(eUIID_Matching)
		g_i3k_game_context:StopMatchingState()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_TournamentRoom, "stopMatching")
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s", "取消失败，服务器返回错误"))
	end
end

--开始战斗的时候通知客户端对方人员
function i3k_sbean.superarena_info.handler(bean)
	local enemies = bean.enemies
	local ids = {}
	for i,v in pairs(enemies) do
		ids[i] = true
	end
	g_i3k_game_context:SetListenedCustomRoles(ids)
	g_i3k_game_context:setTournamentEnemies(enemies)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Battle4v4, "loadData", enemies)
	
	local teamMembers = bean.teamMembers
	local roleId = g_i3k_game_context:GetRoleId()

	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateRoleLife", teamMembers[roleId])
	
	for i,v in pairs(teamMembers) do
		if i~=roleId then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTeam, "setMembersLife", i, v)
		end
	end
end

--同步战斗结果
function i3k_sbean.role_superarena_result.handler(bean)
	local win = bean.win
	local result = bean.result
	local teams = {}
	for i,v in pairs(result.teams) do
		local members = {}
		for _,t in pairs(v.members) do
			table.insert(members, t)
		end
		table.sort(members, function (a, b)
			return a.addHonor<b.addHonor
		end)
		table.insert(teams, members)
	end
	local world = i3k_game_get_world()
	local tType = g_i3k_db.i3k_db_get_tournament_type(world._cfg.id)
	if tType == g_TOURNAMENT_4V4 then
		g_i3k_ui_mgr:OpenUI(eUIID_TournamentResult)
		g_i3k_ui_mgr:RefreshUI(eUIID_TournamentResult, win, teams)
	elseif tType == g_TOURNAMENT_2V2 then
		g_i3k_ui_mgr:OpenUI(eUIID_2v2Result)
		g_i3k_ui_mgr:RefreshUI(eUIID_2v2Result, win, teams, result.teams)
	elseif tType == g_TOURNAMENT_WEAPON then
		g_i3k_ui_mgr:OpenUI(eUIID_TournamentWeaponResult)
		g_i3k_ui_mgr:RefreshUI(eUIID_TournamentWeaponResult, win, result.teams)
	elseif tType == g_TOURNAMENT_CHUHAN then
		g_i3k_ui_mgr:OpenUI(eUIID_chuHanFightResult)
		g_i3k_ui_mgr:RefreshUI(eUIID_chuHanFightResult, win, teams)
	end
end

--4V4商城同步
function i3k_sbean.sync_team_arena_store()
	local sync = i3k_sbean.superarena_shopsync_req.new()
	i3k_game_send_str_cmd(sync)
end

function i3k_sbean.superarena_shopsync_res.handler(bean, res)
	local info = bean.info
	g_i3k_game_context:syncTournamentPoint(bean.currency)
	g_i3k_game_context:SetBudoCount(bean.currency2)
	g_i3k_ui_mgr:OpenUI(eUIID_PersonShop)
	g_i3k_ui_mgr:RefreshUI(eUIID_PersonShop, info, g_SHOP_TYPE_TOURNAMENT, bean.discount)
end

--4V4竞技场刷新
function i3k_sbean.team_arena_refresh_store(times, isSecondType, coinCnt, discount)
	local refresh = i3k_sbean.superarena_shoprefresh_req.new()
	refresh.times = times
	refresh.isSecondType = isSecondType
	refresh.coinCnt = coinCnt
	refresh.discount = discount
	i3k_game_send_str_cmd(refresh, "superarena_shoprefresh_res")
end

function i3k_sbean.superarena_shoprefresh_res.handler(bean, req)
	if bean.info then
		if req.isSecondType > 0 then
			moneytype = g_BASE_ITEM_DIAMOND
		else
			moneytype = g_BASE_ITEM_TOURNAMENT_MONEY
		end
		g_i3k_game_context:UseCommonItem(moneytype, req.coinCnt, AT_USER_REFRESH_SHOP)
		g_i3k_ui_mgr:RefreshUI(eUIID_PersonShop, bean.info, g_SHOP_TYPE_TOURNAMENT, req.discount)
	else
		g_i3k_ui_mgr:PopupTipMessage("4v4竞技商店刷新错误")
	end
end

--商城购买
function i3k_sbean.team_arena_buy_item(index, info, discount, discountCfg)
	local buy = i3k_sbean.superarena_shopbuy_req.new()
	buy.seq = index
	buy.info = info
	buy.discount = discount
	buy.discountCfg = discountCfg
	i3k_game_send_str_cmd(buy, "superarena_shopbuy_res")
end

function i3k_sbean.superarena_shopbuy_res.handler(bean, res)
	if bean.ok == 1 then
		local info = res.info
		local index = res.seq
		local shopItem = i3k_db_tournament_shop[info.goods[index].id]
		local tips = i3k_get_string(189, shopItem.itemName.."*"..shopItem.itemCount)
		info.goods[index].buyTimes = 1
		local count1 = res.discount > 0 and (shopItem.moneyCount * res.discount / 10) or shopItem.moneyCount
		local count2 = res.discount > 0 and (shopItem.moneyCount2 * res.discount / 10) or shopItem.moneyCount2
		g_i3k_game_context:UseBaseItem(shopItem.moneyType, math.ceil(count1), AT_BUY_SHOP_GOOGS)
		g_i3k_game_context:UseBaseItem(shopItem.moneyType2, math.ceil(count2), AT_BUY_SHOP_GOOGS)
		g_i3k_ui_mgr:RefreshUI(eUIID_PersonShop, info, g_SHOP_TYPE_TOURNAMENT, res.discountCfg)
		g_i3k_ui_mgr:PopupTipMessage(tips)
		DCItem.consume(g_BASE_ITEM_TOURNAMENT_MONEY,"会武币",shopItem.moneyCount,AT_BUY_SHOP_GOOGS)
		DCItem.buy(shopItem.itemId,g_i3k_db.i3k_db_get_common_item_is_free_type(shopItem.itemId),shopItem.itemCount, shopItem.moneyType, shopItem.totalPrice, AT_BUY_SHOP_GOOGS)
	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(50065))
	end
end

--创建房间
function i3k_sbean.create_arena_room(arenaType)
	local create = i3k_sbean.aroom_create_req.new()
	create.type = arenaType
	i3k_game_send_str_cmd(create, "aroom_create_res")
end

function i3k_sbean.aroom_create_res.handler(bean, res)
	local errStr = {
		[-4] = i3k_get_string(374),
		[-6] = "队伍内有成员等级不足，创建房间失败",
		[-11] = "队伍内有成员双人互动或多人坐骑中，创建房间失败",
		[-12] = i3k_get_string(17178),
		[-13] = "有队友每日进入次数到达上限",
		[-14] = "有队友没有设置出战英雄",
		[-15] = "有队友在惩罚时间",
	}
	if bean.ok==1 then
		
	else
		if errStr[bean.ok] then
			g_i3k_ui_mgr:PopupTipMessage(errStr[bean.ok])
		end
	end
end

--查询附近的玩家的信息
function i3k_sbean.sync_near_player()
	local sync = i3k_sbean.aroom_mapr_req.new()
	i3k_game_send_str_cmd(sync, "aroom_mapr_res")
end

function i3k_sbean.aroom_mapr_res.handler(bean, res)
	local roles = bean.roles
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_InviteFriends, "onShowPlayerList", roles)
--	g_i3k_ui_mgr:InvokeUIFunction(eUIID_TournamentRoom, "aroundPlayer", roles)
end

--房主邀请新人加入房间
function i3k_sbean.invite_arena_room(roleId)
	local invite = i3k_sbean.aroom_invite_req.new()
	invite.roleID = roleId
	i3k_game_send_str_cmd(invite, "aroom_invite_res")
end

function i3k_sbean.aroom_invite_res.handler(bean, res)
	if bean.ok==1 then
	elseif bean.ok==-1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(371))
	elseif bean.ok==-2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(372))
	elseif bean.ok==-3 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(373))
	elseif bean.ok==-4 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(374))
	elseif bean.ok==-5 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(375))
	elseif bean.ok==-6 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(376))
	elseif bean.ok==-7 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(393))
	elseif bean.ok==-9 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3078))
	elseif bean.ok==-10 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(353,"对方"))
	elseif bean.ok == -13 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18823))
	end
end

--转发其他玩家进入房间的邀请
function i3k_sbean.aroom_invite_forward.handler(bean)
	local roleId = bean.roleID
	local roleName = bean.roleName
	local roomId = bean.roomID
	local roomType = bean.roomType

	local mapName = i3k_db_tournament[roomType] and i3k_db_tournament[roomType].name or ""
	if roomType == g_DESERT_BATTLE_MATCH then
		mapName = i3k_db_desert_battle_base.gameName
	elseif roomType == g_SPY_STORY_MATCH then
		mapName = i3k_get_string(18648)
	end
	local desc = i3k_get_string(352, roleName, mapName)
--	local callback = function (isOk)
--		roleID = roleId
--		roomID = roomId
--		local accept = 0
--		if isOk then
--			accept = 1
--		else
--			accept = 0
--		end
--		i3k_sbean.arena_room_inviteBy(roleId, roomId, accept)
--	end
--	g_i3k_ui_mgr:ShowCustomMessageBox2("同意", "拒绝", desc, callback)
	
	local rtext=string.format("%d分钟内不再接受组队邀请",i3k_db_common.RefuseTeamInvitationTime/60)
	local function callback(isOk,isRadio)
		if isOk then
			if isRadio then
				g_i3k_ui_mgr:PopupTipMessage("选择不再接受组队状态无法确认")
			else
				accept = 1
				g_i3k_ui_mgr:CloseUI(eUIID_MessageBox3)
				i3k_sbean.arena_room_inviteBy(roleId, roomId, accept)
			end
		else
			if isRadio then
				accept = 2
			else
				accept = 0
			end
			g_i3k_ui_mgr:CloseUI(eUIID_MessageBox3)
			i3k_sbean.arena_room_inviteBy(roleId, roomId, accept)
		end
	end
	local function callbackRadioButton(randioButton,yesButton,noButton)
		
	end

	 g_i3k_ui_mgr:ShowMidCustomMessageBox2Ex("同意", "拒绝", desc,rtext, callback,callbackRadioButton)
end

--接收到其他玩家邀请入房间后玩家选择是否同意操作(-1是忙，0是拒绝，1是同意，2是拒绝接受下一段时间邀请)
function i3k_sbean.arena_room_inviteBy(roleId, roomId, isAccept)
	local response = i3k_sbean.aroom_invitedby_req.new()
	response.roleID = roleId
	response.roomID = roomId
	response.accept = isAccept
	i3k_game_send_str_cmd(response, "aroom_invitedby_res")
end

function i3k_sbean.aroom_invitedby_res.handler(bean, res)
	if bean.ok==1 then
		
	elseif bean.ok==-2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(391))
	elseif bean.ok==-3 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(373))
	end
end

--离开房间
function i3k_sbean.quit_arena_room()
	local quit = i3k_sbean.aroom_leave_req.new()
	i3k_game_send_str_cmd(quit, "aroom_leave_res")
end

function i3k_sbean.aroom_leave_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_game_context:quitTournamentRoom()
	else
		
	end
end

--通知邀请者之前的邀请被拒绝
function i3k_sbean.aroom_invite_refuse.handler(bean)
	local roleId = bean.roleID
	local roleName = bean.roleName
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(353, roleName))
end

--通知邀请者被邀请的人正忙
function i3k_sbean.aroom_invite_busy.handler(bean)
	local roleId = bean.roleID
	local roleName = bean.roleName
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(354, roleName))
end

--更换房主
function i3k_sbean.change_leader(roleId)
	local change = i3k_sbean.aroom_change_leader_req.new()
	change.roleId = roleId
	i3k_game_send_str_cmd(change, "aroom_change_leader_res")
end

function i3k_sbean.aroom_change_leader_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_game_context:changeTournamentRoomLeader(res.roleId)
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("更换房主失败"))
	end
end

--踢出成员
function i3k_sbean.kick_arena_room_member(roleId)
	local kick = i3k_sbean.aroom_kick_req.new()
	kick.roleID = roleId
	i3k_game_send_str_cmd(kick, "aroom_kick_res")
end

function i3k_sbean.aroom_kick_res.handler(bean, res)
	if bean.ok==1 then
		
	else
		
	end
end

--通知新成员加入房间同步当前房间信息
function i3k_sbean.aroom_sync.handler(bean)
	local room = bean.room
	g_i3k_game_context:syncTournamentRoom(room.id, room.leader, room.grade, room.members, room.type)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateRoomData")
end

--查询房间人物详细信息
function i3k_sbean.sync_members_profile(roleId)
	local sync = i3k_sbean.aroom_query_member.new()
	sync.roleId = roleId
	i3k_game_send_str_cmd(sync)
end

function i3k_sbean.aroom_member_overview.handler(bean)
	local overview = bean.overview
	local state = bean.state
	g_i3k_game_context:syncMembersProfile(overview, state)
end

--房间成员连线状态变化
function i3k_sbean.aroom_member_connection.handler(bean, res)
	g_i3k_game_context:changeTournamentRoomMemberState(bean.roleId, bean.state)
end

--通知其他成员有新成员加入房间
function i3k_sbean.aroom_join.handler(bean)
	local roleId = bean.roleID
	local roleName = bean.roleName
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(365, roleName))
	g_i3k_game_context:addTournamentRoomMember(bean.roleID)
end

--通知其他成员有成员离开房间
function i3k_sbean.aroom_leave.handler(bean)
	local roleId = bean.roleID
	local roleName = bean.roleName
	local myId = g_i3k_game_context:GetRoleId()
	if roleId~=myId then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(366, roleName))
		g_i3k_game_context:memberLeaveTournamentRoom(roleId)
	else
		g_i3k_game_context:quitTournamentRoom()
	end
end

--通知其他成员有成员被踢出房间
function i3k_sbean.aroom_kick.handler(bean)
	local roleId = bean.roleID
	local roleName = bean.roleName
	if roleId~=g_i3k_game_context:GetRoleId() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(367, roleName))
		g_i3k_game_context:memberLeaveTournamentRoom(roleId)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(367, "您"))
		g_i3k_game_context:quitTournamentRoom()
	end
end

--通知成员换房主
function i3k_sbean.aroom_change_leader.handler(bean)
	local roleId = bean.roleID
	local roleName = bean.roleName
	g_i3k_game_context:changeTournamentRoomLeader(roleId)
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(368, roleName))
end

--通知客户端开始战斗
function i3k_sbean.role_superarenamap_start.handler(bean)
	if bean.arenaType == g_Arena_4V4 then
		DCEvent.onEvent("进入4v4竞技场")
	elseif bean.arenaType == g_Arena_2V2 then
		DCEvent.onEvent("进入2v2竞技场")
	end
	local firstClearInfo = g_i3k_game_context:getFirstClearInfo(FIRST_CLEAR_REWARD_TOURNAMENT)
	if not firstClearInfo or not firstClearInfo.enter then
		g_i3k_game_context:refreshFirstClearInfo(FIRST_CLEAR_REWARD_TOURNAMENT)
	end
	g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_TOURNAMENT, g_SCHEDULE_COMMON_MAPID)
end

--function 排行榜相关() end
--周排行榜
function i3k_sbean.sync_week_rank()
	local sync = i3k_sbean.superarena_weekrank_req.new()
	i3k_game_send_str_cmd(sync, "superarena_weekrank_res")
end

function i3k_sbean.superarena_weekrank_res.handler(bean, res)
	local ranks = bean.ranks
	
end

--根据类型获取对应的单日排行榜
function i3k_sbean.sync_day_rank(arenaType)
	local sync = i3k_sbean.superarena_dayrank_req.new()
	sync.type = arenaType
	i3k_game_send_str_cmd(sync, "superarena_dayrank_res")
end

function i3k_sbean.superarena_dayrank_res.handler(bean, res)
	local ranks = bean.ranks
	
end

--通知客户端4v4竞技场点数增加
function i3k_sbean.role_add_superarenahonor.handler(bean)
	g_i3k_game_context:addTournamentWeekHonor(bean.amount)
	g_i3k_game_context:addTournamentHistoryHonor(bean.amount)
	g_i3k_game_context:addTournamentPoint(bean.amount)
	if not i3k_dataeye_itemtype(bean.reason) then
		DCItem.get(g_BASE_ITEM_TOURNAMENT_MONEY, "会武币", bean.amount, bean.reason)
	end 
end

--登陆同步信息
function i3k_sbean.role_superarena.handler(bean)
	local room = bean.room
	local state = bean.state--1是单人，2是多人，0是没有在匹配
	if state~=0 then
		g_i3k_game_context:InMatchingState(bean.joinTime, g_TOURNAMENT_MATCH, bean.joinType)
	end
	local weekHonor = bean.weekHonor
	local historyHonor = bean.historyHonor
	g_i3k_game_context:addTournamentWeekHonor(weekHonor)
	g_i3k_game_context:addTournamentHistoryHonor(historyHonor)
	if room.id~=0 then
		g_i3k_game_context:setIsOpenTournamentRoom(false)
		g_i3k_game_context:syncTournamentRoom(room.id, room.leader, room.grade, room.members, room.type)
	end
end

--function 2v2相关协议()end
--每一小场的结果
function i3k_sbean.superarena_race_result.handler(bean)
	g_i3k_ui_mgr:OpenUI(eUIID_2v2DanResult)
	g_i3k_ui_mgr:RefreshUI(eUIID_2v2DanResult, bean.result)
end

--进地图同步当前比分，每一场的结果
function i3k_sbean.superarena_race_results.handler(bean)
	--[[local results = bean.results
	local result1 = results[1]
	local result2 = results[2]
	local result3 = results[3]
	if result1 then
		--第一场值
		if result2 then
			--第二场值
			if result3 then
				--第三场值
			else
				
			end
		else
			
		end
	else
		--全部没有值
	end--]]
	g_i3k_ui_mgr:CloseUI(eUIID_2v2DanResult)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Battle2v2, "setData", bean.results)
end

-------------------神器乱斗 start -------------------

-- 神器乱斗神兵设置
function i3k_sbean.superarena_weaponseq(weaponSeq)
	local data =  i3k_sbean.superarena_weaponseq_req.new()
	data.weaponSeq = weaponSeq
	i3k_game_send_str_cmd(data, "superarena_weaponseq_res")
end

function i3k_sbean.superarena_weaponseq_res.handler(bean)
	if bean.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17176))
		g_i3k_ui_mgr:CloseUI(eUIID_SuperArenaWeaponSet)
	end
end

-- 神器乱斗进地图信息同步
function i3k_sbean.superarena_weaponmap_info.handler(bean)
	g_i3k_game_context:SetTournamentWeaponsInfo(bean.scores, bean.weaponInfo, bean.skillInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_BattleTouramentWeapon)
end

-- 神器乱斗积分更新
function i3k_sbean.superarena_weaponmap_updatescore.handler(bean)
	g_i3k_game_context:SetTournamentWeaponScores(bean.forceType, bean.score)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTouramentWeapon, "loadScoresInfo", g_i3k_game_context:GetTournamentWeaponScores())
end

-- 神器乱战切换神兵 client to sever
function i3k_sbean.superarena_changeweapon_beg(idx)
	local data = i3k_sbean.superarena_changeweapon.new()
	data.index = idx
	i3k_game_send_str_cmd(data)
end

-- 神器乱斗神兵切换通知 mapServer to client
function i3k_sbean.superarena_weaponchangetimes.handler(bean)
	local idx = bean.index
	g_i3k_game_context:ReduceTournamentWeaponsChangeTimes(idx)
	local hero = i3k_game_get_player_hero()
	if hero then
		local weaponInfo = g_i3k_game_context:GetTournamentWeaponsInfo()
		if weaponInfo[idx] then
			g_i3k_game_context:SetUseShenbing(weaponInfo[idx].id)
			if g_i3k_db.i3k_db_is_weapon_unique_skill_has_aitrigger(weaponInfo[idx].id) then
				g_i3k_game_context:setShenBingUniqueTrigger()
			else
				g_i3k_game_context:releaseShenBingUniqueTrigger()
			end
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateSoulEnergy", g_i3k_game_context:GetSoulEnergy())
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "showWolfWeapon")
		end
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTouramentWeapon, "loadWeaponInfo", g_i3k_game_context:GetTournamentWeaponsInfo())
end

-- 神器乱斗乱战技能使用通知 mapServer to client
function i3k_sbean.superarena_skillusetimes.handler(bean)
	-- skillID 对应技能次数减一
	g_i3k_game_context:ReduceTournamentWeaponSkillUseTimes(bean.skillID)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTouramentWeapon, "loadSkillInfo", g_i3k_game_context:GetTournamentWeaponSkillInfo())
end
-------------------神器乱斗 end -------------------
--会武楚汉之争同步所有人阵营兵种
function i3k_sbean.sync_superarena_chessarm_info.handler(bean)
	g_i3k_game_context:SetChuHanFightAllRoleInfo(bean.armInfos)
end
--会武周奖励同步
function i3k_sbean.super_arena_week_reward_sync()
	local data = i3k_sbean.super_arena_week_reward_sync_req.new()
	i3k_game_send_str_cmd(data, "super_arena_week_reward_sync_res")
end
-- 会武周奖励领取
function i3k_sbean.super_arena_week_reward_take(times)
	local data = i3k_sbean.super_arena_week_reward_take_req.new()
	data.times = times
	i3k_game_send_str_cmd(data, "super_arena_week_reward_take_res")
end
-- 会武周奖励同步
function i3k_sbean.super_arena_week_reward_sync_res.handler(bean, res)
	g_i3k_game_context:setTournamentWeekRewardInfo(bean.info)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "updataWeekReward")
end
-- 会武周奖励领取
function i3k_sbean.super_arena_week_reward_take_res.handler(bean, res)
	if bean.ok > 0 then
		local items = {} 
		for k, v in ipairs(i3k_db_tournament_week_reward) do
			if res.times[v.needTimes] then
				if items[1] then
					items[1].count = items[1].count + v.itemCount
				else
					items[1] = {}
					items[1].id = v.itemId
					items[1].count = v.itemCount
				end
			end
		end
		g_i3k_ui_mgr:ShowGainItemInfo(items)
		g_i3k_game_context:useTournamentWeekReward(res.times)
		local info = g_i3k_game_context:getTournamentWeekRewardInfo()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "updataWeekReward")
		if table.nums(info.reward) == #i3k_db_tournament_week_reward then
			g_i3k_ui_mgr:CloseUI(eUIID_TournamentWeekReward)
		else
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_TournamentWeekReward, "setWeedReward")
		end
	else
		--g_i3k_ui_mgr:PopupTipMessage("失败")
	end
end
