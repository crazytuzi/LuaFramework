------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

---------------------------------势力战相关协议----------------------------------------------
-- 势力战界面同步信息
function i3k_sbean.sync_activities_forcewar()
	local bean = i3k_sbean.forcewar_sync_req.new()
	i3k_game_send_str_cmd(bean, "forcewar_sync_res")
end

function i3k_sbean.forcewar_sync_res.handler(res, req)--log(dayEnterTimes当天参加次数,enterTimes总参与次数,winTimes,bestRank)
	if res.log  then
		g_i3k_game_context:setForceWarLotteryNum(res.totalLotteryCnt)
		g_i3k_game_context:setTodayForceWarTimes(res.dayGainLotteryCnt)
		g_i3k_game_context:setForceWarDropOutState(res.punishEndTime ~=0)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "reloadForceWarActivity",res.log.dayEnterTimes,res.log.enterTimes,res.log.winTimes,res.log.bestRank,res.punishEndTime)
		g_i3k_game_context:LeadCheck()
	end
end

-- 势力战报名协议
function i3k_sbean.join_forcewar(fType)
	local bean = i3k_sbean.forcewar_join_req.new()
	bean.type = fType
	i3k_game_send_str_cmd(bean, "forcewar_join_res")
end

function i3k_sbean.forcewar_join_res.handler(bean, req)--ok
	if bean.ok > 0 then
		DCEvent.onEvent("势力战报名")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_War_Team_Room, "startMatching" )
	else
		g_i3k_game_context:StopMatchingState()
		g_i3k_ui_mgr:PopupTipMessage("报名失败")
	end
end

-- 势力战取消报名协议
function i3k_sbean.quit_join_forcewar()
	local bean = i3k_sbean.forcewar_quit_req.new()
	i3k_game_send_str_cmd(bean, "forcewar_quit_res")
end

function i3k_sbean.forcewar_quit_res.handler(res, req)--ok
	if res.ok==1 then
		g_i3k_game_context:StopMatchingState()
		DCEvent.onEvent("势力战取消报名")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_War_Team_Room, "stopMatching" )
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s", "取消失败，服务器返回错误"))
	end
end

-- 势力战匹配结果
function i3k_sbean.forcewar_match.handler(bean)
	g_i3k_game_context:StopMatchingState()
	if bean.ok>0 then
		g_i3k_ui_mgr:PopupTipMessage(string.format("匹配成功"))
		--jxw
		--刷新其他玩家界面展示
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_War_Team_Room, "startMatching" )
	else
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_War_Team_Room, "stopMatching")
		if g_i3k_ui_mgr:GetUI(eUIID_WaitTip) then
			if g_i3k_ui_mgr:InvokeUIFunction(eUIID_WaitTip, "getWaitType")==g_FORCE_WAR_WAIT then
				g_i3k_ui_mgr:CloseUI(eUIID_WaitTip)
			end
		end
		if bean.ok==-1 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1009))--超时
		elseif bean.ok==-2 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string("已经过了开放时间"))
		end
	end
end

-- 通知客户端势力战开始
function i3k_sbean.role_forcewarmap_start.handler(bean)
	DCEvent.onEvent("进入势力战")
	if bean.guard ~= 1 then
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_FORCE_WAR, g_SCHEDULE_COMMON_MAPID)
	end
	g_i3k_game_context:ResetForceWarData()---清除数据
end

-- 通知客户端势力战结束
--Packet:role_end_mapcopy
function i3k_sbean.role_forcewarmap_end.handler(bean)
	g_i3k_ui_mgr:PopupTipMessage("势力战结束")
	local hero = i3k_game_get_player_hero()
	hero:SetAutoFight(false)
	hero:SetForceTarget(nil)
end

function i3k_sbean.role_forcewar_result.handler(bean,res)--gainFeat,curWeekFeat,winSide,killedBoss,whiteScore,blackScore,whiteSide(rid,rank,name,level,kills,bekills,killNpcs,score,gainFeat),blackSide()
	--kills					//击杀数
	--bekills			//被击杀数
	--gainFeat 获得武勋 战绩里显示
	--killedBoss 1正派水晶被杀也就是输了；2邪派水晶被杀，0是哪边积分高哪边胜利
	--winSide 0表示都输，1正派赢，2邪派赢
	--curWeekFeat
	g_i3k_game_context:setForceWarAddWeekFeats(bean.curWeekFeat)
	g_i3k_game_context:setForceWarUpdateTime(true)--为了刷新势力战的倒计时
	g_i3k_ui_mgr:OpenUI(eUIID_ForceWarResult)
	g_i3k_ui_mgr:RefreshUI(eUIID_ForceWarResult,bean.whiteSide,bean.blackSide,bean.gainFeat,bean.whiteScore,bean.blackScore,bean.killedBoss,bean.winSide)
	--local l_transformBWtype = g_i3k_game_context:GetTransformBWtype()
	local forceType = g_i3k_game_context:GetForceType()
	local mapId = bean.winSide==forceType and i3k_db_forcewar_base.otherData.goldFuben or i3k_db_forcewar_base.otherData.AgFuben
	if bean.rewardMapTimes == 1 then
		g_i3k_game_context:setDungeonDayRewardTimes(mapId)
	end
	if bean.rewardLotteryTimes == 1 then
		local num = g_i3k_game_context:getForceWarLotteryNum()
		g_i3k_game_context:setForceWarLotteryNum(num + 1)
	end
end
--------查询势力战战报的异步响应
function i3k_sbean.query_role_forcewar_result()
	local bean = i3k_sbean.query_forcewar_result.new()
	i3k_game_send_str_cmd(bean)
end

------- 的异步响应
function i3k_sbean.roles_forcewaroverview.handler(bean)
	g_i3k_ui_mgr:OpenUI(eUIID_ForceWarResult)
	g_i3k_ui_mgr:RefreshUI(eUIID_ForceWarResult,bean.white,bean.black,nil,nil,nil,nil,nil,true)
end


-- 势力战击杀加分
function i3k_sbean.role_forcewar_kill.handler(bean)
	if bean.addScore>0 then
		g_i3k_game_context:AddHonor(bean.addScore,true)
	end
end

-- 助攻加分
function i3k_sbean.role_forcewar_assist.handler(bean)
	if bean then
		g_i3k_game_context:AddHonor(bean.addScore)
	end
end

-- 势力战阵营积分更新
function i3k_sbean.nearby_forcewar_campscore.handler(bean)
	if bean then
		g_i3k_game_context:setForceWarScore(bean.whiteScore,bean.blackScore )
	end
end

-- 势力战首杀
function i3k_sbean.forcewar_first_blood.handler(bean, res)
	local killerName = bean.killer
	local deadName = bean.deader
	local hero = i3k_game_get_player_hero()
	if hero._name == killerName then
		g_i3k_ui_mgr:OpenUI(eUIID_ShouSha)
	end
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(557,killerName,deadName))
end


-- 势力战连杀、或者终结连杀
function i3k_sbean.nearby_forcewar_kill.handler(bean, res)
	local killerName = bean.killer
	local deadName = bean.deader
	local killerKills = bean.killerKills
	local deaderKills = bean.deaderKills
	---需要判断播哪条广播
	local  killStreaks = i3k_db_forcewar_base.otherData.noticeMinimumStandard
	local  finalkillStreaks = i3k_db_forcewar_base.otherData.noticeFinalMinimumStandard
	if deaderKills>=killStreaks then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(560,killerName,deadName,deaderKills))--终结连杀
	elseif killerKills>=finalkillStreaks then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(561,killerName,deadName,killerKills))--连杀
	end
end

-- 势力战雕像、水晶（进地图时同步的）
function i3k_sbean.role_forcewar_statues.handler(bean)
	-- 用id cfgID,location,curHP,maxHP   statues(base(id,cfgID,ownerID,location),curHP,maxHP ),totalNormalStatue,totalBigStatue
	local statues = bean.statues
	if bean then
		for k,v in ipairs(statues) do
			local statuesID = v.base.id;
			local cfgID = v.base.cfgID;
			local x = v.base.location.position.x;
			local y = v.base.location.position.y;
			local z = v.base.location.position.z;
			local curHP = v.curHP;
			local maxHP = v.maxHP;
			local StartPos = {x = x,y = y, z = z}
			local world = i3k_game_get_world()
			local mapId = world._cfg.id
			g_i3k_game_context:setForceWarStatuesPosition(statuesID,cfgID,StartPos,mapId)---设置势力战雕像位置
			g_i3k_game_context:setForceWarStatuesInfo(statuesID,curHP,cfgID,maxHP)---设置势力战雕像数据
		end
		g_i3k_game_context:setForceWarStatuesCount(bean.totalNormalStatue,bean.totalBigStatue)
		if g_i3k_ui_mgr:GetUI(eUIID_ForceWarMiniMap) then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_ForceWarMiniMap, "updateMapInfo")
		end
	end
end

-- 势力战
function i3k_sbean.nearby_forcewar_statues.handler(bean)
	--水晶血量变化/死亡，雕像死亡的时候才发
	if bean then--id ,curHP
		if bean.curHP>0 then--存活
			--水晶血量变化
			g_i3k_game_context:setForceWarBossHp(bean.id, bean.curHP)---保存水晶的血量
		else
			--死亡
			g_i3k_game_context:setForceWarStatuesNums(bean.id, bean.curHP)
		end
	end
end

-- 通知客户端角色武勋(累计的武勋)增加
--Packet:role_add_feat
function i3k_sbean.role_add_feat.handler(bean)
	local feat = bean.feat
	g_i3k_game_context:setForceWarAddFeat(feat)
end

----jxw----------------------------------------------------------------------
--势力战协议start

--创建势力战房间
function i3k_sbean.war_create_room(fType)
	local create = i3k_sbean.froom_create_req.new()
	create.type = fType
	i3k_game_send_str_cmd(create, "froom_create_res")
end

function i3k_sbean.froom_create_res.handler(bean)
	if bean.ok==1 then
		--g_i3k_ui_mgr:PopupTipMessage("发送成功")
	elseif bean.ok==-4 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(374))
	elseif bean.ok==-6 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3072))
	elseif bean.ok == -7 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3073))
	elseif bean.ok == -8 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3071))
	elseif bean.ok == -11 then
		g_i3k_ui_mgr:PopupTipMessage(string.format("队伍内有成员双人互动或多人坐骑中，创建房间失败"))
	end
end

--房主邀请新人加入房间（主动邀请）
function i3k_sbean.war_invite_room(roleId)
	local invite = i3k_sbean.froom_invite_req.new()
	invite.roleID = roleId
	i3k_game_send_str_cmd(invite, "froom_invite_res")
end

function i3k_sbean.froom_invite_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_ui_mgr:PopupTipMessage("发送成功")
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
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5039))
	elseif bean.ok==-7 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5040))
	elseif bean.ok == -8 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5041))
	elseif bean.ok==-9 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3078))
	elseif bean.ok==-10 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(353,"对方"))
	end
end


--查询附近的玩家的信息（符合比赛要求的人的信息）
function i3k_sbean.war_sync_near_player(fType)
	local sync = i3k_sbean.froom_mapr_req.new()
	sync.type = fType
	i3k_game_send_str_cmd(sync, "froom_mapr_res")
end

function i3k_sbean.froom_mapr_res.handler(bean)
	local roles = bean.roles
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_InviteFriends, "onShowPlayerList", roles)
end

--转发其他玩家进入房间的邀请 (房主邀请自己)
function i3k_sbean.froom_invite_forward.handler(bean)
	local roleId = bean.roleID
	local roleName = bean.roleName
	local roomId = bean.roomID
	local roomType = bean.type
	local mapName = i3k_db_forcewar[roomType] and i3k_db_forcewar[roomType].name or ""
	local desc = i3k_get_string(352, roleName, mapName)
	--local callback = function (isOk)
	--	roleID = roleId
	--	roomID = roomId
	--	local accept = 0
		--if isOk then
	--		accept = 1
		--else
		--	accept = 0
	--	end
		--i3k_sbean.war_room_inviteBy(roleId, roomId, accept)
	--end
	--g_i3k_ui_mgr:ShowCustomMessageBox2("同意", "拒绝", desc, callback)
	local rtext=string.format("%d分钟内不再接受组队邀请",i3k_db_common.RefuseTeamInvitationTime/60)
		local function callback(isOk,isRadio)
			local accept = 0
			if isOk then
				if isRadio then
					g_i3k_ui_mgr:PopupTipMessage("选择不再接受组队状态无法确认")
				else
					accept = 1
					g_i3k_ui_mgr:CloseUI(eUIID_MessageBox3)
					i3k_sbean.war_room_inviteBy(roleId, roomId, accept)
				end
				
			else
				if isRadio then
					accept = 2
				else
					accept = 0
				end
				g_i3k_ui_mgr:CloseUI(eUIID_MessageBox3)
				i3k_sbean.war_room_inviteBy(roleId, roomId, accept)
			end
			
		end
		
		local function callbackRadioButton(randioButton,yesButton,noButton)
		end
		
		g_i3k_ui_mgr:ShowMidCustomMessageBox2Ex("同意", "拒绝", desc,rtext, callback,callbackRadioButton)
end

--接收到其他玩家邀请入房间后玩家选择是否同意操作(-1是忙，0是拒绝，1是同意)
function i3k_sbean.war_room_inviteBy(roleId, roomId, isAccept)
	local response = i3k_sbean.froom_invitedby_req.new()
	response.roleID = roleId
	response.roomID = roomId
	response.accept = isAccept
	i3k_game_send_str_cmd(response, "froom_invitedby_res")
end

function i3k_sbean.froom_invitedby_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_ui_mgr:PopupTipMessage("发送成功")
	elseif bean.ok==-2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(391))
	elseif bean.ok==-3 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(373))
	end
end

--通知邀请者之前的邀请被拒绝
function i3k_sbean.froom_invite_refuse.handler(bean)
	local roleId = bean.roleID
	local roleName = bean.roleName
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(353, roleName))
end

--通知邀请者被邀请的人正忙
function i3k_sbean.froom_invite_busy.handler(bean)
	local roleId = bean.roleID
	local roleName = bean.roleName
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(354, roleName))
end

--离开房间
function i3k_sbean.war_quit_room()
	local quit = i3k_sbean.froom_leave_req.new()
	i3k_game_send_str_cmd(quit, "froom_leave_res")
end

function i3k_sbean.froom_leave_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_game_context:quitForceWarRoom()
		--将势力战组队报名标记清空
	else
		g_i3k_ui_mgr:PopupTipMessage("离开房间失败")
	end
end

--通知其他成员有成员离开房间
function i3k_sbean.froom_leave.handler(bean)
	local roleId = bean.roleID
	local roleName = bean.roleName
	local myId = g_i3k_game_context:GetRoleId()
	if roleId~=myId then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(366, roleName))
		g_i3k_game_context:memberLeaveForceWarRoom(roleId)
		--jxw
	else
		g_i3k_game_context:quitForceWarRoom()
	end
end

--势力战更换房主
function i3k_sbean.war_change_leader(roleId)
	local change = i3k_sbean.froom_change_leader_req.new()
	change.roleID = roleId
	i3k_game_send_str_cmd(change, "froom_change_leader_res")
end

function i3k_sbean.froom_change_leader_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_game_context:changeForceWarRoomLeader(res.roleID)
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("更换房主失败"))
	end
end

--通知成员换房主
function i3k_sbean.froom_change_leader.handler(bean)
	local roleId = bean.roleID
	local roleName = bean.roleName
	g_i3k_game_context:changeForceWarRoomLeader(roleId)
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(368, roleName))
end

--势力战踢出成员
function i3k_sbean.war_kick_room_member(roleId)
	local kick = i3k_sbean.froom_kick_req.new()
	kick.roleID = roleId
	i3k_game_send_str_cmd(kick, "froom_kick_res")
end

function i3k_sbean.froom_kick_res.handler(bean, res) --（同时收到房间成员信息变化？）
	if bean.ok==1 then
		g_i3k_ui_mgr:PopupTipMessage(string.format("势力战踢出成员成功"))
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("势力战踢出成员失败"))
	end
end

--通知其他成员有成员被踢出房间
function i3k_sbean.froom_kick.handler(bean)
	local roleId = bean.roleID
	local roleName = bean.roleName
	if roleId~=g_i3k_game_context:GetRoleId() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(367, roleName))
		g_i3k_game_context:memberLeaveForceWarRoom(roleId)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(367, "您"))
		g_i3k_game_context:quitForceWarRoom()
	end
end

--势力战查询房间人物详细信息
function i3k_sbean.war_sync_members_profile(roleId)
	local sync = i3k_sbean.froom_query_member.new()
	sync.roleID = roleId
	i3k_game_send_str_cmd(sync)
end

function i3k_sbean.froom_member_overview.handler(bean)
	local member = bean.member
	local state = bean.state
	g_i3k_game_context:syncWarMembersProfile(member, state)
	--jxw 返回全部的成员信息
end

--势力战通知新成员加入房间同步当前房间信息
function i3k_sbean.froom_sync.handler(bean)
	local room = bean.room
	g_i3k_game_context:syncForceWarRoom(room.id, room.leader,room.members, room.type)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateRoomData")
end

--通知其他成员有新成员加入房间
function i3k_sbean.froom_join.handler(bean)
	local member = bean.member
	g_i3k_game_context:syncWarMembersProfile(member, 10)
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(365, member.name))
end

--势力战房间成员连线状态变化
--通知客户端房间成员的连接状态变化,state大于1是连接状态，为0是断线
function i3k_sbean.froom_member_connection.handler(bean, res)
	g_i3k_game_context:changeForceWarRoomMemberState(bean.roleID, bean.state)
end

--势力战其他玩家离开
function i3k_sbean.forcewar_other_quit.handler(bean)
	local roleID = bean.roleID
	local roleName = bean.roleName
	g_i3k_ui_mgr:PopupTipMessage(roleName.."取消匹配")
	g_i3k_game_context:StopMatchingState()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_War_Team_Room,"stopMatching")
end

--通知其他玩家开始匹配
function i3k_sbean.forcewar_startmatch.handler(bean)
	local fRoomType = g_i3k_game_context:getForceWarRoomType()
	g_i3k_game_context:InMatchingState(i3k_game_get_time(), g_FORCE_WAR_MATCH, fRoomType)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_War_Team_Room, "startMatching" )
end

-- 势力战队友位置广播请求
function i3k_sbean.notice_forcewar_teammate_pos()
	local bean = i3k_sbean.query_forcewar_members_pos.new()
	i3k_game_send_str_cmd(bean)
end

function i3k_sbean.forcewar_members_position.handler(bean)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_ForceWarMap, "updateTeammatePos", bean.members)
end

-- 同步势力类型
function i3k_sbean.sync_role_forcetype.handler(bean)
	local hero = i3k_game_get_player_hero()
	if hero then
		hero:SetForceType(bean.forceType);
	end
end

--role_sachess_arm
--map 同步楚汉之争
function i3k_sbean.role_sachess_arm.handler(bean)
	local hero = i3k_game_get_player_hero()
	if hero then
		hero:SetForceArm(bean.arm);
	end
end
-- 同步对战列表
function i3k_sbean.forcewar_mapbrief(fType)
	local data = i3k_sbean.forcewar_mapbrief_req.new()
	data.forceType = fType
	i3k_game_send_str_cmd(data, "forcewar_mapbrief_res")
end

function i3k_sbean.forcewar_mapbrief_res.handler(bean, req)
	local briefs = bean.briefs
	if briefs then
		if #briefs > 0 then
			g_i3k_ui_mgr:OpenUI(eUIID_CombatTeamList)
			g_i3k_ui_mgr:RefreshUI(eUIID_CombatTeamList, bean.briefs)
		else
			g_i3k_ui_mgr:PopupTipMessage("没有团队进行对战")
		end
	end
end

-- 进入观战
function i3k_sbean.forcewar_guard(mapID, mapInstance)
	local data = i3k_sbean.forcewar_guard_req.new()
	data.mapID = mapID
	data.mapInstance = mapInstance
	i3k_game_send_str_cmd(data, "forcewar_guard_res")
end

function i3k_sbean.forcewar_guard_req.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_ui_mgr:PopupTipMessage("成功进入观战")
	elseif bean.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage("比赛已结束")
	elseif bean.ok == -4 then
		g_i3k_ui_mgr:PopupTipMessage("观战人数已满")
	end
end

-- 观战状态
function i3k_sbean.role_guard.handler(bean)
	local hero = i3k_game_get_player_hero()
	if hero then
		hero:SetGuardSatate(true)
		hero:UpdateProperty(ePropID_speed, 1, i3k_db_forcewar_base.channelData.guardSpeed, true, false, true);
		if i3k_game_get_map_type() == g_BUDO then
			hero:ChangeModelFacade(i3k_db_fightTeam_base.display.guardModelID)
		end
	end
end

function i3k_sbean.forceWarLottery(index)
	local data = i3k_sbean.forcewar_lottery_req.new()
	data.index = index
	i3k_game_send_str_cmd(data, "forcewar_lottery_res")
end
function i3k_sbean.forcewar_lottery_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ForceWarLottery, "openBoxCallback", res.rewards, req.index)
	end
end
--势力战协议end
----jxw-----------------------------------------------------------------------
