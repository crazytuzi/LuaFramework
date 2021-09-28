------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

----------------------------------------------------
local ErrorCode = {
	[g_FIGHT_TEAM_ALREADY_JOIN] 		 	= "已有队伍",
	[g_FIGHT_TEAM_CREATE_NAME_INVALID]	 	= "名字非法",
	[g_FIGHT_TEAM_CREATE_NAME_DUPLICATE] 	= "名字重复",
	[g_FIGHT_TEAM_NO_IN]					= "已经不在队伍中",
	[g_FIGHT_TEAM_OFFLINE]				 	= "不在线",
	[g_FIGHT_TEAM_ALREADY_IN_TEAM]		 	= "已经在战队中",
	[g_FIGHT_TEAM_CLASSTYPE_LIMIT]		 	= "同一职业玩家超过上限",
	[g_FIGHT_TEAM_NOT_EXSIT]			 	= "战队已解散",
	[g_FIGHT_TEAM_INVITE_INVALID]	 	 	= "邀请失败",
	[g_FIGHT_TEAM_TEAN_FULL]				= "战队已满",
	[g_FIGHT_TEAM_NOT_LEADER]			 	= "不是队长",
	[g_FIGHT_TEAM_NOT_FIGHT_TIME]		 	= "不在报名时间段内",
	[g_FIGHT_TEAM_ALREADY_INJOIN_STATE]	 	= "已经在报名状态",
	[g_FIGHT_TEAM_ONLINE_MEMBER_LACK]	 	= "战队在线人数不足",
	[g_FIGHT_TEAM_NOT_JOIN]				 	= "没有报名",
	[g_FIGHT_TEAM_KICK_CD]				 	= "踢人cd中",
	[g_FIGHT_TEAM_QUALIFYING_TIMES_LIMIT] 	= "参加次数不足",
	[g_FIGHT_TEAM_REFUSE]					= i3k_get_string(353,"对方"),
	[g_FIGHT_TEAM_FIGHTEND]					= "战斗结束",
	[g_FIGHT_TEAM_MAXGUARD_COUNT]			= "观战人数超过上限",
	[g_FIGHT_TEAM_NO_FIGHT]					= "没有正在进行的战斗",
	[g_FIGHT_TEAM_OTHER_WAIT_MATCH]			= "有队员正在等待其他活动，无法参加",
	[g_FIGHT_TEAM_JOIN_TIMES_LIMIT]			= i3k_get_string(1257, i3k_db_fightTeam_base.team.maxJoinTimes),
	[g_FIGHT_TEAM_MEMBER_HUG]				= "有队员中有人正在多人坐骑或相依相偎中",
}

--相关错误码提示
local function FightTeamErrorCode(result)
	if ErrorCode[result] then
		g_i3k_ui_mgr:PopupTipMessage(ErrorCode[result])
	else
		g_i3k_ui_mgr:PopupTipMessage("无效错误码："..result)
	end
end

-- 战队信息同步
function i3k_sbean.fightteam_sync()
	local bean = i3k_sbean.fightteam_sync_req.new()
	i3k_game_send_str_cmd(bean, "fightteam_sync_res")
end

function i3k_sbean.fightteam_sync_res.handler(bean)
	--顺序不可乱
	if bean.season then
		g_i3k_game_context:setFightTeamSchedule(bean.season)
		g_i3k_game_context:setFightTeamInfo(bean.info)
		g_i3k_game_context:setFightTeamGroup(bean.group)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "reloadFightTeam")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadFightTeamGroup", bean.group)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadFightTeamInfo", bean.info)
		g_i3k_game_context:setFightTeamHonor(bean.honor)
		g_i3k_game_context:setFightTeamJoinTimes(bean.seasonJoinTeamTimes)
		g_i3k_game_context:setFightTeamResult({
			roleRank = bean.roleRank,
			teamResult = bean.teamResult,	
			roleReward = bean.roleReward,
			teamReward = bean.teamReward
		})
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1245))
	end
end

-- 创建战队
function i3k_sbean.fightteam_create(name)
	local bean = i3k_sbean.fightteam_create_req.new()
	bean.name = name
	i3k_game_send_str_cmd(bean, "fightteam_create_res")
end

function i3k_sbean.fightteam_create_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1205))
		g_i3k_game_context:setFightTeamInfo(bean.info)
		g_i3k_game_context:addFightTeamJoinTimes()
		for _, e in ipairs(i3k_db_fightTeam_base.team.needItems) do
			g_i3k_game_context:UseCommonItem(e.id, e.count, AT_CREATE_FIGHT_TEAM)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadFightTeamInfo", bean.info)
		g_i3k_ui_mgr:CloseUI(eUIID_CreateFightTeam)
	else
		FightTeamErrorCode(bean.ok)
	end
end

-- 解散战队
function i3k_sbean.fightteam_dismiss_request()
	local bean = i3k_sbean.fightteam_dismiss_req.new()
	i3k_game_send_str_cmd(bean, "fightteam_dismiss_res")
end

function i3k_sbean.fightteam_dismiss_res.handler(bean)
	if bean.ok > 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_FightTeamRecord)
		g_i3k_game_context:setFightTeamInfo(nil)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadFightTeamInfo", nil)
		i3k_sbean.fightteam_sync()
	else
		FightTeamErrorCode(bean.ok)
	end
end

-- 队长踢人
function i3k_sbean.fightteam_kick_requst(memberID)
	local bean = i3k_sbean.fightteam_kick_req.new()
	bean.memberID = memberID
	i3k_game_send_str_cmd(bean, "fightteam_kick_res")
end

function i3k_sbean.fightteam_kick_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:fightTeamKickMember(req.memberID)
	else
		FightTeamErrorCode(bean.ok)
	end
end

-- 邀请加入战队
function i3k_sbean.fightteam_invite(roleID, teamID)
	local bean = i3k_sbean.fightteam_invite_req.new()
	bean.roleID	= roleID
	bean.teamID = teamID
	i3k_game_send_str_cmd(bean, "fightteam_invite_res")
end

function i3k_sbean.fightteam_invite_res.handler(bean)
	if bean.ok > 0 then

	else
		FightTeamErrorCode(bean.ok)
	end
end

-- 战队邀请响应
function i3k_sbean.fightteam_invite_response(roleID, response)
	local bean = i3k_sbean.fightteam_invite_response_req.new()
	bean.roleID = roleID
	bean.response = response
	i3k_game_send_str_cmd(bean, "fightteam_invite_response_res")
end

function i3k_sbean.fightteam_invite_response_res.handler(bean)
	if bean.ok > 0 then
		g_i3k_game_context:setFightTeamInfo(bean.info)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadFightTeamInfo", bean.info)
	else
		FightTeamErrorCode(bean.ok)
	end
end

-- 战队信息通知
function i3k_sbean.fightteam_info.handler(bean)
	g_i3k_game_context:setFightTeamInfo(bean.info)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadFightTeamInfo", bean.info)
end

-- 队员加入通知
function i3k_sbean.fightteam_join.handler(bean)
	g_i3k_game_context:fightTeamJoinMember(bean.member)
end

-- 队员被踢通知
function i3k_sbean.fightteam_kick.handler(bean)
	if g_i3k_game_context:GetRoleId() == bean.memberID then
		g_i3k_game_context:setFightTeamInfo(nil)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadFightTeamInfo", nil)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1206, bean.memberName))          
		g_i3k_game_context:fightTeamKickMember(bean.memberID)
	end
end

-- 战队解散通知
function i3k_sbean.fightteam_dismiss.handler()
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1207))
	g_i3k_game_context:setFightTeamInfo(nil)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadFightTeamInfo", nil)
end

-- 通知客户端战队成员的连接状态变化,online大于1是连接状态，为0是断线
function i3k_sbean.fteam_member_connection.handler(bean)
	g_i3k_game_context:updateFightTeamMemberOnline(bean.roleID, bean.online)
end

-- 收到加入战队邀请
function i3k_sbean.fightteam_invite_forward.handler(bean)
	local roleID = bean.roleID
	if g_i3k_game_context:IsInLeadMode() then
		i3k_sbean.fightteam_invite_response(roleID, -2)
		return
	end
	local msg = i3k_get_string(1208, bean.roleName)
	local rtext = i3k_get_string(1209, i3k_db_common.RefuseTeamInvitationTime/60)
	local function callback(isOk, isRadio)
		if isOk then
			if isRadio then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1210))
			else
				g_i3k_ui_mgr:CloseUI(eUIID_FightTeamInviteConfirm)
				i3k_sbean.fightteam_invite_response(roleID, 1)
			end
		else
			g_i3k_ui_mgr:CloseUI(eUIID_FightTeamInviteConfirm)
			i3k_sbean.fightteam_invite_response(roleID, isRadio and 2 or 0)
		end
	end

	local function callbackRadioButton(randioButton,yesButton,noButton)
		
	end
	if not g_i3k_ui_mgr:GetUI(eUIID_FightTeamInviteConfirm) then
		g_i3k_ui_mgr:OpenUI(eUIID_FightTeamInviteConfirm)
		g_i3k_ui_mgr:RefreshUI(eUIID_FightTeamInviteConfirm, i3k_get_string(1211), i3k_get_string(1212), msg, rtext, callback, callbackRadioButton)
	else
		i3k_sbean.fightteam_invite_response(roleID, 0)
	end
end

-- 通知队长邀请响应
function i3k_sbean.fightteam_invite_response_forward.handler(bean)
	local roleName = bean.roleName
	if bean.response == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1213, roleName))
	elseif bean.response == 0 or bean.response == 2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1214, roleName))
	end
end

-- 查询添加好友
function i3k_sbean.fightteam_queryf()
	local bean = i3k_sbean.fightteam_queryf_req.new()
	i3k_game_send_str_cmd(bean, "fightteam_queryf_res")
end

function i3k_sbean.fightteam_queryf_res.handler(bean)
	if bean.roles then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_InviteFriends, "onShowFightTeamFriends", bean.roles)
	end
end

-- 队长报名海选赛
function i3k_sbean.fightteam_joinqualifying_request()
	local bean = i3k_sbean.fightteam_joinqualifying_req.new()
	i3k_game_send_str_cmd(bean, "fightteam_joinqualifying_res")
end

function i3k_sbean.fightteam_joinqualifying_res.handler(bean)
	if bean.ok > 0 then
		g_i3k_game_context:InMatchingState(i3k_game_get_time(), g_FIGHT_TEAM_MATCH, g_FIGHTTEAM_QUALIFYING_MATCH)
	else
		FightTeamErrorCode(bean.ok)
	end
end

-- 队长取消报名海选赛
function i3k_sbean.fightteam_quitqualifying_request()
	local bean = i3k_sbean.fightteam_quitqualifying_req.new()
	i3k_game_send_str_cmd(bean, "fightteam_quitqualifying_res")
end

function i3k_sbean.fightteam_quitqualifying_res.handler(bean)
	if bean.ok > 0 then
		g_i3k_game_context:StopMatchingState()
	else
		FightTeamErrorCode(bean.ok)
	end
end

-- 队友收到武道会匹配状态更新
function i3k_sbean.fightteam_state_update.handler(bean)
	if bean.state > 0 then
		local time = bean.state == g_FIGHTTEAM_QUALIFYING_MATCH and i3k_game_get_time() or 0 -- 签到不计匹配时间
		g_i3k_game_context:InMatchingState(time, g_FIGHT_TEAM_MATCH, bean.state)
		if bean.state == g_FIGHTTEAM_TOURNAMENT_MATCH then -- 锦标赛签到
			g_i3k_game_context:updateFightTeamMemberState(g_i3k_game_context:GetRoleId(), bean.state)
		end
	else
		g_i3k_game_context:StopMatchingState()
	end
end

-- 队员锦标赛签到
function i3k_sbean.fightteam_joinknockout()
	local bean = i3k_sbean.fightteam_joinknockout_req.new()
	i3k_game_send_str_cmd(bean, "fightteam_joinknockout_res")
end

function i3k_sbean.fightteam_joinknockout_res.handler(bean)
	if bean.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1215))
	else
		FightTeamErrorCode(bean.ok)
	end
end

-- 队友签到状态更新
function i3k_sbean.fteam_member_state.handler(bean)
	g_i3k_game_context:updateFightTeamMemberState(bean.roleID, bean.state)
end

-- 锦标赛对手签到状态通知
function i3k_sbean.fightteam_enemy_join.handler(bean)
	if bean.join then
		g_i3k_game_context:updateEnemySignState(bean.join)
	end
end

-- 锦标赛结果
function i3k_sbean.tournament_knockout_result.handler(bean)
	if bean.result == f_FIGHT_RESULT_ENEMY_ERROR then
		g_i3k_ui_mgr:PopupTipMessage("对方服务器异常")	
	end
	g_i3k_game_context:StopMatchingState()
	g_i3k_game_context:resetFightTeamMemberState()
	i3k_sbean.fightteam_selfgroup()
end

-- 锦标赛对手查询
function i3k_sbean.fightteam_selfgroup()
	local bean = i3k_sbean.fightteam_selfgroup_req.new()
	i3k_game_send_str_cmd(bean, "fightteam_selfgroup_res")
end

function i3k_sbean.fightteam_selfgroup_res.handler(bean)
	g_i3k_game_context:setFightTeamGroup(bean.group)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadFightTeamGroup", bean.group)
end

--------- 武道会战斗相关
-- 战斗开始
function i3k_sbean.tournament_map_start.handler(bean)
	g_i3k_game_context:StopMatchingState() --进入武道会战场 终止匹配
end

-- members(包括自己)
function i3k_sbean.tournamentmap_info.handler(bean)
	g_i3k_game_context:setFightTeamMapInfo(bean.members)
	local ids = {}
	for _, e in ipairs(bean.members) do
		local overview = e.profile.overview
		ids[overview.id] = true
	end
	g_i3k_game_context:SetListenedCustomRoles(ids)
end

-- 观战同步信息
function i3k_sbean.tournamentmap_guard.handler(bean)
	g_i3k_game_context:SetFightTeamGuardData(bean)
end

-- 更新队友生命数
function i3k_sbean.tournamentmap_rolelives.handler(bean)
	g_i3k_game_context:updateFightTeamMapInfo(bean.roleID, bean.lives)
end

-- 更新双方存活数
function i3k_sbean.tournamentmap_teamlives.handler(bean)
	g_i3k_game_context:setFightTeamLives(bean.self, bean.enemy)
end

-- 更新自己武道荣誉
function i3k_sbean.tournamentmap_honor.handler(bean)
	g_i3k_game_context:setFightTeamHonor(bean.honor)
end

-- 首杀
function i3k_sbean.map_first_blood.handler(bean)
	if g_i3k_game_context:GetRoleName() == bean.killer then
		g_i3k_ui_mgr:OpenUI(eUIID_ShouSha)
	end
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1216, bean.killer, bean.deader))
end

--同步队友位置
function i3k_sbean.request_query_mapcopy_members_pos()
	local bean = i3k_sbean.query_mapcopy_members_pos.new()
	i3k_game_send_str_cmd(bean)
end

function i3k_sbean.mapcopy_members_position.handler(bean)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_ForceWarMap, "updateTeammatePos", bean.members)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_DesertBattleMiniMap, "updateTeammatePos", bean.members)
end

--同步赛事信息
function i3k_sbean.request_tournament_teamgroup_sync_req(type, id)
	local data = i3k_sbean.tournament_teamgroup_sync_req.new()
	data.type = type
	data.id = id
	i3k_game_send_str_cmd(data, "tournament_teamgroup_sync_res")
end

function i3k_sbean.tournament_teamgroup_sync_res.handler(bean,req)	
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FightTeamGameReport,"show", req.type-1, bean, req.id)
end

--查看战队信息
function i3k_sbean.request_fightteam_querym_req(teamId)
	local data = i3k_sbean.fightteam_querym_req.new()
	data.teamId = teamId
	i3k_game_send_str_cmd(data, "fightteam_querym_res")
end

function i3k_sbean.fightteam_querym_res.handler(bean, req)
	g_i3k_ui_mgr:OpenUI(eUIID_FightTeamInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_FightTeamInfo,bean, req.teamId == g_i3k_game_context:getFightTeamID())
end

--领取战队奖励
function i3k_sbean.request_tournament_take_teamreward_req(callback)
	local data = i3k_sbean.tournament_take_teamreward_req.new()
	data.callback = callback
	i3k_game_send_str_cmd(data, "tournament_take_teamreward_res")
end

function i3k_sbean.tournament_take_teamreward_res.handler(bean,req)
	if bean.ok == 1 then
		req.callback()
	end
end

--领取个人奖励
function i3k_sbean.request_tournament_take_rolereward_req(callback)
	local data = i3k_sbean.tournament_take_rolereward_req.new()
	data.callback = callback
	i3k_game_send_str_cmd(data, "tournament_take_rolereward_res")
end

function i3k_sbean.tournament_take_rolereward_res.handler(bean,req)
	if bean.ok == 1 then
		req.callback()
	end
end

--战斗结束
function i3k_sbean.tournament_map_result.handler(bean)
	g_i3k_ui_mgr:OpenUI(eUIID_FightTeamResult)
	g_i3k_ui_mgr:RefreshUI(eUIID_FightTeamResult,bean)
end

-- 进入观战
function i3k_sbean.tournament_guard(teamID)
	local data = i3k_sbean.tournament_guard_req.new()
	data.teamID = teamID or 0
	i3k_game_send_str_cmd(data, "tournament_guard_res")
end

function i3k_sbean.tournament_guard_res.handler(bean)
	if bean.ok > 0 then

	else
		FightTeamErrorCode(bean.ok)
	end
end
