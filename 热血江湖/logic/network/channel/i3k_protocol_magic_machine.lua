------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/network/channel/i3k_channel");

-----------------------------------
--同步神机藏海信息
function i3k_sbean.role_hidden_sea_info.handler(bean)
	--self.dayEnterTimes:		int32
	local info = {dayEnterTimes = bean.dayEnterTimes, signTime = bean.signTime}
	g_i3k_game_context:setMagicMachineSignInfo(info)
	
	if bean.signTime > 0 then
		g_i3k_game_context:InMatchingState(bean.signTime, g_MAGIC_MACHINE_MATCH)
	end
end

--神机藏海副本开始
function i3k_sbean.hidden_sea_map_start.handler(bean)
	g_i3k_game_context:addMagicMachineEnterTimes(1)	
	local cfg = i3k_db_schedule.cfg
	local mapID = g_SCHEDULE_COMMON_MAPID
		
	for _, v in ipairs(cfg or {}) do
		if v.typeNum == g_SCHEDULE_TYPE_MAGIC_MACHINE then
			mapID = v.mapID
			break
		end
	end
		
	g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_MAGIC_MACHINE, mapID)
end

--报名协议
function i3k_sbean.magic_machine_sign_up(id)
	local bean = i3k_sbean.hidden_sea_marry_sign_req.new()
	i3k_game_send_str_cmd(bean, "hidden_sea_sign_res")
end

function i3k_sbean.hidden_sea_sign_res.handler(bean)
	if bean.ok > 0 then
		g_i3k_game_context:setMagicMachineSignUpTime(i3k_game_get_time())
		g_i3k_game_context:InMatchingState(i3k_game_get_time(), g_MAGIC_MACHINE_MATCH)
	end
end

--神机藏海匹配结果
function i3k_sbean.hidden_sea_match_result.handler(bean)
	g_i3k_game_context:StopMatchingState()
	g_i3k_game_context:setMagicMachineSignUpTime(0)	
end


--神机藏海取消报名  
function i3k_sbean.magic_machine_quit_up()
	local bean = i3k_sbean.hidden_sea_quit_req.new()
	i3k_game_send_str_cmd(bean, "hidden_sea_quit_res")
end

function i3k_sbean.hidden_sea_quit_res.handler(bean)
	if bean.ok > 0 then
		g_i3k_game_context:setMagicMachineSignUpTime(0)
		g_i3k_game_context:StopMatchingState()
	end
end

--结算
function i3k_sbean.hidden_sea_map_result.handler(bean)
	--self.win:		int32	
	--self.selfRank:		int32	
	--self.selfScore:		int32	
	--self.hiddenBoss:		int32 1触发0未出发
	--self.useTime:		int32	 秒
	--self.ranks:		vector[RankRole]	
	g_i3k_logic:OpenMagicMachineResultUI(bean)
end

function i3k_sbean.magic_machine_lucky_teams()
	local bean = i3k_sbean.hidden_sea_lucky_team_req.new()
	i3k_game_send_str_cmd(bean, "hidden_sea_lucky_team_res")
end

--幸运团队
function i3k_sbean.hidden_sea_lucky_team_res.handler(bean)
	--self.teamInfos:		DBHiddenSeaTeams
	g_i3k_ui_mgr:OpenUI(eUIID_MMRank)
	g_i3k_ui_mgr:RefreshUI(eUIID_MMRank, bean.teamInfos)
end

--同步积分
function i3k_sbean.hidden_sea_score_info.handler(bean)
	--self.scoreInfo:		map[int32, int32]
	g_i3k_game_context:refreshMagicMachineScore(bean.scoreInfo)
end

--触发隐藏boss
function i3k_sbean.hidden_sea_trig_hidden_boss.handler(bean)
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18145))
end

--通知客户端npc开始行动
function i3k_sbean.hidden_sea_start_timing.handler(bean)
	g_i3k_game_context:setMagicMachineNpcTimeAndRoute(bean)
	g_i3k_game_context:notiFyMagicMachineNpcMove(1, bean.route)
end

-- 同步地图信息
function i3k_sbean.hidden_sea_map_info.handler(bean)
	--self.scoreInfo:		map[int32, int32]	
	--self.npcDistance:		int32
	--self.npcRoute:		int32	
	--self.npcStartTime:		int32	
	local info = {scoreInfo = bean.scoreInfo, npcDistance = bean.npcDistance, route = bean.npcRoute, npcStartTime = bean.npcStartTime}
	g_i3k_game_context:setMagicMachineBattleInfo(info)
	g_i3k_ui_mgr:RefreshUI(eUIID_MagicMachineBattle)
	
	if bean.npcRoute ~= 0 then
		local points = i3k_db_move_road_points[bean.npcRoute].points
		local clientIndex = bean.npcDistance
		
		if clientIndex < #points then
			g_i3k_game_context:creatMagicMachineNpcAndMove(clientIndex, bean.npcRoute)
		else
			g_i3k_game_context:loadMagicMachinePahts(points, #points + 1)
		end		
	end
end

--复位协议
function i3k_sbean.magic_machine_reverse_pos()
	local bean = i3k_sbean.hidden_sea_reset_position.new()
	i3k_game_send_str_cmd(bean)
end
