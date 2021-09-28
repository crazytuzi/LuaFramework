------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

-- 通知新队员加入队伍
--Packet:team_sync
function i3k_sbean.team_sync.handler(bean)
	g_i3k_game_context:SetMyTeam(bean.team.id, bean.team.leader, bean.team.members)
	local fightMercenaries = g_i3k_game_context:GetFightMercenaries()
	if #fightMercenaries > 0 then
		--g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(586))
	end
	g_i3k_game_context:ChangPKMode();
	for i,v in ipairs(bean.team.members) do
		g_i3k_game_context:removeInviteItem(v, g_INVITE_TYPE_TEAM)
	end
end

-- 通知其他队员新队员加入队伍
--Packet:team_join
function i3k_sbean.team_join.handler(bean)
	g_i3k_ui_mgr:PopupTipMessage(bean.roleName.."加入了队伍")
	g_i3k_game_context:TeamMemberJoin(bean.roleId, bean.roleName)
	g_i3k_game_context:ChangPKMode();
end

-- 通知其他队员有成员离开队伍
--Packet:team_leave
function i3k_sbean.team_leave.handler(bean)
	g_i3k_ui_mgr:PopupTipMessage(bean.roleName.."退出了队伍")
	if g_i3k_game_context:GetRoleId() == bean.roleId then
		g_i3k_game_context:ResetMyTeam()
	else
		g_i3k_game_context:TeamMemberLeave(bean.roleId, bean.roleName)
	end
	g_i3k_game_context:ChangPKMode();
end

-- 通知其他队员有成员被踢出队伍
--Packet:team_kick
function i3k_sbean.team_kick.handler(bean)
	g_i3k_ui_mgr:PopupTipMessage(bean.roleName.."被请离了队伍")
	if g_i3k_game_context:GetRoleId() == bean.roleId then
		g_i3k_game_context:ResetMyTeam()
	else
		g_i3k_game_context:TeamMemberLeave(bean.roleId, bean.roleName)
	end
	g_i3k_game_context:ChangPKMode();
end

-- 通知队伍队伍解散
--Packet:team_dissolve
function i3k_sbean.team_dissolve.handler(bean)
	g_i3k_ui_mgr:PopupTipMessage("队伍已经被解散")
	g_i3k_game_context:ResetMyTeam()
	g_i3k_game_context:ChangPKMode();
end

-- 通知队伍换队长
--Packet:team_change_leader
function i3k_sbean.team_change_leader.handler(bean)
	g_i3k_game_context:TeamChangeLeader(bean.roleId, bean.roleName)
end




-----------------------队友连线状态变化-------------------------
-- 通知客户端队伍成员的连接状态变化,state大于1是连接状态，为0是断线
--Packet:team_member_connection
function i3k_sbean.team_member_connection.handler(bean)
	g_i3k_game_context:TeamChangeState(bean.roleId, bean.state)
end




--------------------------血量变化---------------------------
-- 通知客户端队伍成员的hp变化更新后的新值
--Packet:team_member_hp
function i3k_sbean.team_member_hp.handler(bean)
	g_i3k_game_context:TeamSyncHp(bean.roleId, bean.hp, bean.hpMax)
end

-- 通知客户端队伍成员信息的变化后的更新值或客户端主动查询值
--Packet:team_member_profile
function i3k_sbean.team_member_profile.handler(bean)
	g_i3k_game_context:TeamChangePosition(bean.profile.overview.id, bean.mapId, bean.position, bean.line)
	g_i3k_game_context:TeamChangeState(bean.profile.overview.id, bean.state)
	g_i3k_game_context:TeamSyncMemberProfile(bean.profile)
end

function i3k_sbean.query_team_member(roleId)
	local teamMember = i3k_sbean.team_query_member.new()
	teamMember.roleId = roleId
	i3k_game_send_str_cmd(teamMember)
end

-- 通知客户端队伍成员的位置变化更新后的新值
--Packet:team_member_position
function i3k_sbean.team_member_position.handler(bean)
	g_i3k_game_context:TeamChangePosition(bean.roleId, bean.mapId, bean.position, bean.line)
end





-----------------------查询玩家的teamId-------------------------------

function i3k_sbean.query_role_team(roleId)
	local checkTeamId = i3k_sbean.team_role_query_req.new()
	checkTeamId.roleId = roleId
	i3k_game_send_str_cmd(checkTeamId, i3k_sbean.team_role_query_res.getName())
end

-- 查询玩家的队伍信息的响应
--Packet:team_role_query_res
function i3k_sbean.team_role_query_res.handler(bean, res)
	local teamId = bean.teamId

	if res.openId==eUIID_Wjxx then -- 点英雄头像，才会有openId
		local pos = res.pos
		local targetId = res.targetId
		g_i3k_ui_mgr:OpenUI(eUIID_Wjxx)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Wjxx, "popupClickBossIcon", teamId, pos, targetId, res.isMulHorse,res.sectID, res.gender, res.name, res.level)
	end
end

function i3k_sbean.invite_role_join_team(roleId)
	if g_i3k_game_context:IsBlackListBaned(roleId) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17732))
		return
	end
	local syncTeam = i3k_sbean.team_invite_req.new()
	syncTeam.roleId = roleId
	i3k_game_send_str_cmd(syncTeam, i3k_sbean.team_invite_res.getName())
end

-- 邀请其他玩家组队响应(返回邀请操作是否成功，大于0成功并向对方发送邀请消息，对方已经下线-1，队伍已满-2，对方已经在队伍中-3, 对方正在副本中-5)
--Packet:team_invite_res
function i3k_sbean.team_invite_res.handler(bean, res)
	local result = bean.ok
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
	if result==1 then
		DCEvent.onEvent("组队邀请")
	elseif result==-1 then
		g_i3k_ui_mgr:PopupTipMessage("对方已经下线")
	elseif result==-2 then
		g_i3k_ui_mgr:PopupTipMessage("当前队伍满员")
	elseif result==-3 then
		g_i3k_ui_mgr:PopupTipMessage("对方已有队伍")
	elseif result==-5 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(743))
	elseif result==-6 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(393))
	elseif result == -7 then
		g_i3k_ui_mgr:PopupTipMessage("等级到达<c=hlred>10级</c>之后开放组队功能")
	elseif result == -8 then
		g_i3k_ui_mgr:PopupTipMessage("对方未到达<c=hlred>10级</c>")
	elseif result == -9 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3078))
	elseif bean.ok==-10 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(353,"对方"))
	elseif result == -11 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16626))
	elseif result == -12 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17733))
	end
end


function i3k_sbean.invited_join_team_by_other_role(roleId, accept)
	local isAccept = i3k_sbean.team_invitedby_req.new()
	isAccept.roleId = roleId
	isAccept.accept = accept
	i3k_game_send_str_cmd(isAccept, i3k_sbean.team_invitedby_res.getName())
end

-- 玩家是否同意接收组队邀请操作响应(返回对邀请响应的操作是否成功，大于0操作成功(拒绝或接受成功)，如果接受失败：对方已经下线-1，队伍已满-2，邀请人已经加入其它队伍-3)
--Packet:team_invitedby_res
function i3k_sbean.team_invitedby_res.handler(bean, res)
	local result = bean.ok
	if res.accept ~= -1 then--不是正忙的时候才移除
		g_i3k_game_context:removeInviteItem(res.roleId, g_INVITE_TYPE_TEAM)
	end
	if result==1 then

	elseif result==-1 then
		g_i3k_ui_mgr:PopupTipMessage("对方已经下线")
	elseif result==-2 then
		g_i3k_ui_mgr:PopupTipMessage("当前队伍满员")
	elseif result==-3 then
		g_i3k_ui_mgr:PopupTipMessage("对方已有队伍")
	end
end




----------------------------------Apply--------------------------------------
function i3k_sbean.apply_join_team(teamId)
	local apply = i3k_sbean.team_apply_req.new()
	apply.teamId = teamId
	i3k_game_send_str_cmd(apply, i3k_sbean.team_apply_res.getName())
end

-- 其他玩家申请组队响应(返回申请操作是否成功，大于0成功并向队长或申请人发送申请消息，队长或申请人已经下线-1，队伍已满-2，本人已经在其他队伍-3(此项客户端预处理，服务器做保证，正常逻辑不会返回-3))
--Packet:team_apply_res
function i3k_sbean.team_apply_res.handler(bean, res)
	local result = bean.ok
	if result==1 then
		g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
		DCEvent.onEvent("组队申请")
	elseif result==-1 then
		g_i3k_ui_mgr:PopupTipMessage("对方已经下线")
	elseif result==-2 then
		g_i3k_ui_mgr:PopupTipMessage("队伍已经满员")
	elseif result==-3 then
		--g_i3k_ui_mgr:PopupTipMessage("自己已有队伍")
	elseif result == -4 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(852))
	end
end

function i3k_sbean.applied_join_team_by_other_role(roleId, accept)
	local isAccept = i3k_sbean.team_appliedby_req.new()
	isAccept.roleId = roleId
	isAccept.accept = accept
	i3k_game_send_str_cmd(isAccept, i3k_sbean.team_appliedby_res.getName())
end

-- 队长是否同意接受组队申请操作响应(返回对申请响应的操作是否成功，大于0操作成功(拒绝或接受成功)，如果接受失败：对方已经下线-1，队伍已满-2，申请人已经加入其它队伍-3)
--Packet:team_appliedby_res
function i3k_sbean.team_appliedby_res.handler(bean, res)
	local result = bean.ok
	if result==1 then

	elseif result==-1 then
		g_i3k_ui_mgr:PopupTipMessage("对方已经下线")
	elseif result==-2 then
		g_i3k_ui_mgr:PopupTipMessage("当前队伍满员")
	elseif result==-3 then
		g_i3k_ui_mgr:PopupTipMessage("对方已加入其它队伍")
	end
end


------------------------------swap leader------------------------------
function i3k_sbean.change_team_leader(roleId)
	local changeLeader = i3k_sbean.team_change_leader_req.new()
	changeLeader.roleId = roleId
	i3k_game_send_str_cmd(changeLeader, i3k_sbean.team_change_leader_res.getName())
end

-- 队伍切换队长响应(返回换队长是否成功)
--Packet:team_change_leader_res
function i3k_sbean.team_change_leader_res.handler(bean, res)
	local result = bean.ok
	local leaderId = res.roleId
	if result==1 then
		g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
	else

	end
end


-----------------------------kick-------------------------------------------
function i3k_sbean.kick_team_member(roleId)
	local kick = i3k_sbean.team_kick_req.new()
	kick.roleId = roleId
	i3k_game_send_str_cmd(kick, i3k_sbean.team_kick_res.getName())
end

-- 踢出队伍成员协议(返回踢出队伍成员是否成功)
--Packet:team_kick_res
function i3k_sbean.team_kick_res.handler(bean, res)
	local result = bean.ok
	if result==1 then

	else

	end
end


function i3k_sbean.leave_team()
	local leave = i3k_sbean.team_leave_req.new()
	i3k_game_send_str_cmd(leave, i3k_sbean.team_leave_res.getName())
end

-- 离开队伍响应(返回离开队伍是否成功)
--Packet:team_leave_res
function i3k_sbean.team_leave_res.handler(bean, res)
	local result = bean.ok
	if result==1 then
		g_i3k_ui_mgr:PopupTipMessage("您退出了队伍")
		g_i3k_game_context:ResetMyTeam()
		g_i3k_ui_mgr:CloseUI(eUIID_MyTeam)
		--[[local hdr = i3k_game_get_lua_channel_handler(eNChannel_Suicong)
		hdr:summon_pet()--]]
	else
		g_i3k_ui_mgr:PopupTipMessage("退出失败，请重试")
	end
end




function i3k_sbean.dissolve_team()
	local disband = i3k_sbean.team_dissolve_req.new()
	i3k_game_send_str_cmd(disband, i3k_sbean.team_dissolve_res.getName())
end

-- 解散队伍响应(返回解散队伍是否成功)
--Packet:team_dissolve_res
function i3k_sbean.team_dissolve_res.handler(bean, res)
	local result = bean.ok
	if result==1 then
		g_i3k_ui_mgr:PopupTipMessage("队伍已经被解散")
		g_i3k_game_context:ResetMyTeam()
		g_i3k_ui_mgr:CloseUI(eUIID_MyTeam)
		--[[local hdr = i3k_game_get_lua_channel_handler(eNChannel_Suicong)
		hdr:summon_pet()--]]
	else

	end
end



function i3k_sbean.team_self_res.handler(bean, res)
end





------------------------附近的队伍请求协议返回------------------------------
function i3k_sbean.request_team_mapt_req()
	local nearTeam = i3k_sbean.team_mapt_req.new()
	i3k_game_send_str_cmd(nearTeam, i3k_sbean.team_mapt_res.getName())
end

-- 附近的队伍响应协议
--Packet:team_mapt_res
function i3k_sbean.team_mapt_res.handler(bean, res)
	local teams = bean.teams
	g_i3k_ui_mgr:OpenUI(eUIID_Team)
	g_i3k_ui_mgr:RefreshUI(eUIID_Team, teams)
end



-----------------------附近玩家请求协议返回-------------------------------
function i3k_sbean.requset_team_mapr_req(from)
	local nearPlayer = i3k_sbean.team_mapr_req.new()
	nearPlayer.from = 1
	i3k_game_send_str_cmd(nearPlayer, i3k_sbean.team_mapr_res.getName())
end

function i3k_sbean.team_mapr_res.handler(bean, res)
	local from = res.from
	local roles = bean.roles
	if from==1 then
		--从我的队伍请求的
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_InviteFriends, "onShowPlayerList", roles)
--		g_i3k_ui_mgr:InvokeUIFunction(eUIID_MyTeam, "updateNearPlayer", roles)
--		g_i3k_game_context:SetAroundRoleData(roles)
	else
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Team, "updateNearPlayer", roles)
	end
end

-- 邀请师徒
function i3k_sbean.getMasterRequeset(isRefreshRoom)
	local data = i3k_sbean.team_master_req.new()
	data.isRefreshRoom = isRefreshRoom
	i3k_game_send_str_cmd(data, i3k_sbean.team_master_res.getName())
end
function i3k_sbean.team_master_res.handler(res, req)
	local roles = res.roles
	if req.isRefreshRoom then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_CreateRoom, "onShowMasterPlayerList", roles)
	else
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_InviteFriends, "onShowMasterPlayerList", roles)
	end
end


-- 转发其他玩家的组队邀请
--Packet:team_invite_forward
function i3k_sbean.team_invite_forward.handler(bean)
	--local cfg = g_i3k_game_context:GetUserCfg()
	if  g_i3k_game_context:GetUserCfg():GetMatchTeamRequestStatus() then
		if g_i3k_game_context:IsInLeadMode() then
			local isAccept = i3k_sbean.team_invitedby_req.new()
			isAccept.roleId = bean.roleId
			isAccept.accept = -2
			i3k_game_send_str_cmd(isAccept, i3k_sbean.team_invitedby_res.getName())
		else
			local isAccept = i3k_sbean.team_invitedby_req.new()
			isAccept.roleId = bean.roleId
			isAccept.accept = 1
			i3k_game_send_str_cmd(isAccept, i3k_sbean.team_invitedby_res.getName())
		end
	else
		local msg = i3k_get_string(18584, bean.roleName)
		if not bean.hide then
			local yes_name = i3k_get_string(1815)
			local no_name = i3k_get_string(1816)
			local acceptFunc = function()
				local isAccept = i3k_sbean.team_invitedby_req.new()
				isAccept.roleId = bean.roleId
				isAccept.accept = 1
				i3k_game_send_str_cmd(isAccept, i3k_sbean.team_invitedby_res.getName())
			end
			local refuseFunc = function()
				local isAccept = i3k_sbean.team_invitedby_req.new()
				isAccept.roleId = bean.roleId
				isAccept.accept = 0
				i3k_game_send_str_cmd(isAccept, i3k_sbean.team_invitedby_res.getName())
			end
			local busyFunc = function()
				local isAccept = i3k_sbean.team_invitedby_req.new()
				isAccept.roleId = bean.roleId
				isAccept.accept = -1
				i3k_game_send_str_cmd(isAccept, i3k_sbean.team_invitedby_res.getName())
			end
			g_i3k_game_context:addInviteItem(g_INVITE_TYPE_TEAM, bean, acceptFunc, refuseFunc, busyFunc, bean.roleId, msg, yes_name, no_name)
			return
		end
		local rtext=string.format("%d分钟内不再接受组队邀请",i3k_db_common.RefuseTeamInvitationTime/60)
		local function callback(isOk,isRadio)
			if isOk then
				if isRadio then
					g_i3k_ui_mgr:PopupTipMessage("选择不再接受组队状态无法确认")
				else
					g_i3k_ui_mgr:CloseUI(eUIID_MessageBox3)
					local isAccept = i3k_sbean.team_invitedby_req.new()
					isAccept.roleId = bean.roleId
					isAccept.accept = 1
					i3k_game_send_str_cmd(isAccept, i3k_sbean.team_invitedby_res.getName())
				end
			else
				local isAccept = i3k_sbean.team_invitedby_req.new()
				isAccept.roleId = bean.roleId
				if isRadio then
					isAccept.accept = 2
				else
					isAccept.accept = 0
				end
				g_i3k_ui_mgr:CloseUI(eUIID_MessageBox3)
				i3k_game_send_str_cmd(isAccept, i3k_sbean.team_invitedby_res.getName())
			end
			
		end
		
		local function callbackRadioButton(randioButton,yesButton,noButton)
			
		end
		local show = g_i3k_game_context:getInviteListSettting(g_INVITE_SET_TEAM)
		if not g_i3k_ui_mgr:ShowMidCustomMessageBox2Ex("同意", "拒绝", msg,rtext, callback,callbackRadioButton, show) then
			local isAccept = i3k_sbean.team_invitedby_req.new()
			isAccept.roleId = bean.roleId
			isAccept.accept = -1
			i3k_game_send_str_cmd(isAccept, i3k_sbean.team_invitedby_res.getName())
		end
	end
end

-- 通知邀请者前面的邀请正忙
--Packet:team_invite_busy
function i3k_sbean.team_invite_busy.handler(bean)
	local name = bean.roleName
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(355, name))
end

-- 通知邀请者前面的邀请被拒绝
--Packet:team_invite_refuse
function i3k_sbean.team_invite_refuse.handler(bean)
	local roleId = bean.roleId
	local roleName = bean.roleName
	g_i3k_ui_mgr:PopupTipMessage(roleName.."拒绝了你的组队邀请")
	g_i3k_game_context:removeInviteItem(roleId, g_INVITE_TYPE_TEAM)
end

-- 转发其他玩家的组队申请
--Packet:team_apply_forward
function i3k_sbean.team_apply_forward.handler(bean)
	if  g_i3k_game_context:GetUserCfg():GetMatchTeamApplyStatus() then
		local isAccept = i3k_sbean.team_appliedby_req.new()
		isAccept.roleId = bean.role.id
		isAccept.accept = 1
		i3k_game_send_str_cmd(isAccept, i3k_sbean.team_appliedby_res.getName())
	else
		local applyer = bean.role
		local applyRoleTable = g_i3k_game_context:GetIsHaveReqForTeam()
		if applyRoleTable then
			for i,v in pairs(applyRoleTable) do
				if v.id==applyer.id then
					table.remove(applyRoleTable, i)
				end
			end
			if #applyRoleTable == 0 then
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTeam, "setTeamBtnAnis", false)
			end
		else
			applyRoleTable = {}
		end
		table.insert(applyRoleTable, applyer)
		g_i3k_game_context:SetIsHaveReqForTeam(applyRoleTable)
		local myTeamUI = g_i3k_ui_mgr:GetUI(eUIID_MyTeam)
		if myTeamUI then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_MyTeam, "setApplyRed", true)
		else
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTeam, "setTeamBtnAnis", true)
		end
	end
end

-- 通知申请者前面的申请被队长拒绝
--Packet:team_apply_refuse
function i3k_sbean.team_apply_refuse.handler(bean)
	local rId = bean.roleId
	local roleName = bean.roleName
	g_i3k_ui_mgr:PopupTipMessage(roleName.."拒绝你的入队申请")
end

-- 通知邀请者前面的邀请在指引状态
--Packet:team_invite_lead
function i3k_sbean.team_invite_lead.handler(bean)
	local rId = bean.roleId
	local roleName = bean.roleName
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(382, roleName))
end

------------跨服组队began------------
-- 登录同步跨服副本匹配信息
function i3k_sbean.role_globalmap.handler(bean)
	if bean.info then
		if bean.info.type ~= 0 then
			g_i3k_game_context:InMatchingState(0, bean.info.type, bean.info.param1)
		end
	end
end

-- 快速匹配跨服副本
-- param1参数说明: 组队本 副本ID; 正义之心	0; 守护副本	副本ID; npc副本	组ID
function i3k_sbean.globalmap_join_request(matchType, arg)
	local data = i3k_sbean.globalmap_join_req.new()
	local globalInfo = i3k_sbean.GlobalMap.new()
	globalInfo.type = matchType
	globalInfo.param1 = arg
	data.info = globalInfo
	i3k_game_send_str_cmd(data, "globalmap_join_res")
end

function i3k_sbean.globalmap_join_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:InMatchingState(i3k_game_get_time(), req.info.type, req.info.param1)
		local matchType, actType, joinTime = g_i3k_game_context:getMatchState()
		g_i3k_ui_mgr:OpenUI(eUIID_SignWait)
		g_i3k_ui_mgr:RefreshUI(eUIID_SignWait, joinTime, matchType, actType)
	elseif bean.ok == -102 then --此功能暂未开启
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1311))
	end
end

-- 取消匹配跨服副本
function i3k_sbean.globalmap_quit_request()
	local data = i3k_sbean.globalmap_quit_req.new()
	i3k_game_send_str_cmd(data, "globalmap_quit_res")
end

function i3k_sbean.globalmap_quit_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:StopMatchingState()
	end
end

-- 跨服副本匹配结果
function i3k_sbean.globalmap_match_result.handler(bean)
	if bean.result <= 0 then
		if bean.result == -1 then
			g_i3k_ui_mgr:PopupTipMessage("不在匹配时间")
		end
	end
	g_i3k_game_context:StopMatchingState()
end
------------跨服组队end------------
