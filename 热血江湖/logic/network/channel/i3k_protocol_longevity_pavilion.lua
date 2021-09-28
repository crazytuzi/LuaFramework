------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/network/channel/i3k_channel");

-----------------------------------
--同步万寿阁信息
function i3k_sbean.role_longevity_loft.handler(bean)
	--self.dayEnterTimes:		int32
	local info = {dayEnterTimes = bean.dayEnterTimes, signTime = bean.signTime}
	g_i3k_game_context:setLongevityPavilionSignInfo(info)
	
	if bean.signTime > 0 then
		g_i3k_game_context:InMatchingState(bean.signTime, g_LONGEVITY_PAVILION_MATCH)
	end
end

--万寿阁副本开始
function i3k_sbean.longevity_loft_map_start.handler(bean)
	g_i3k_game_context:addLongevityPavilionEnterTimes(1)	
	local cfg = i3k_db_schedule.cfg
	local mapID = g_SCHEDULE_COMMON_MAPID
		
	for _, v in ipairs(cfg or {}) do
		if v.typeNum == g_SCHEDULE_TYPE_LONGEVITY_PAVILION then
			mapID = v.mapID
			break
		end
	end
		
	g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_LONGEVITY_PAVILION, mapID)
end

--万寿阁信息进入同步
function i3k_sbean.longevity_loft_map_info.handler(bean)
	--self.stage:		int32	
	--self.tasks:		map[int32, int32]	
	--self.score:		int32	
	--self.trigTeleport:		int32
	g_i3k_game_context:setLongevityPavilionBattleInfo(bean)
end

--报名协议
function i3k_sbean.longevity_loft_sign()
	local bean = i3k_sbean.longevity_loft_sign_req.new()
	i3k_game_send_str_cmd(bean, "longevity_loft_sign_res")
end

function i3k_sbean.longevity_loft_sign_res.handler(bean)
	if bean.ok > 0 then
		g_i3k_game_context:setLongevityPavilionSignUpTime(i3k_game_get_time())
		g_i3k_game_context:InMatchingState(i3k_game_get_time(), g_LONGEVITY_PAVILION_MATCH)
	end
end

--万寿阁匹配结果
function i3k_sbean.longevity_loft_match.handler(bean)
	g_i3k_game_context:StopMatchingState()
	g_i3k_game_context:setLongevityPavilionSignUpTime(0)	
end


--万寿阁取消报名  
function i3k_sbean.longevity_loft_quit()
	local bean = i3k_sbean.longevity_loft_quit_req.new()
	i3k_game_send_str_cmd(bean, "longevity_loft_quit_res")
end

function i3k_sbean.longevity_loft_quit_res.handler(bean)
	if bean.ok > 0 then
		g_i3k_game_context:setLongevityPavilionSignUpTime(0)
		g_i3k_game_context:StopMatchingState()
	end
end

--结算
function i3k_sbean.longevity_loft_map_result.handler(bean)
	--self.win:		int32	
	--self.selfRank:		int32	
	--self.ranks:		vector[RankRole]	
	--self.killBossTotal:		int32	
	g_i3k_logic:OpenLongevityPavilionResultUI(bean)
end

--同步积分
function i3k_sbean.longevity_loft_add_score.handler(bean)
	--self.add:		int32	
	g_i3k_game_context:refreshLongevityPavilionScore(bean.add)
	if not g_i3k_ui_mgr:GetUI(eUIID_PrincessMarryAddScore) then
 		g_i3k_ui_mgr:OpenUI(eUIID_PrincessMarryAddScore)
 	end
	g_i3k_ui_mgr:RefreshUI(eUIID_PrincessMarryAddScore, bean.add)
end

--同步当前阶段
function i3k_sbean.longevity_loft_sync_stage.handler(bean)
	g_i3k_game_context:setLongevityPavilionStage(bean.stage)
	g_i3k_ui_mgr:PopupTipMessage(g_i3k_db.i3k_db_get_longevity_pavilion_battle_desc(bean.stage))
end

--同步任务进度
function i3k_sbean.longevity_loft_update_task.handler(bean)
	--self.taskID:		int32	
	--self.taskValue:		int32	
	g_i3k_game_context:setLongevityPavilionTask(bean)
	local tip = g_i3k_db.i3k_db_longevity_pavilion_boss_desc_tip()
	if tip then
		g_i3k_ui_mgr:PopupTipMessage(tip)
	end
end


--通知客户端boss传送开启
function i3k_sbean.longevity_loft_open_teleport.handler(bean)
	g_i3k_logic:OpenLongevityPavilionDeliveryUI()
end

--排行榜
function i3k_sbean.longevity_loft_get_rank.handler(bean)
	--g_i3k_game_context:setMagicMachineNpcTimeAndRoute(bean)
	--g_i3k_game_context:notiFyMagicMachineNpcMove(1, bean.route)
end

function i3k_sbean.longevity_loft_boss()
	local bean = i3k_sbean.longevity_loft_boss_teleport.new()
	i3k_game_send_str_cmd(bean)
end

--复位协议
function i3k_sbean.longevity_loft_reset()
	local bean = i3k_sbean.longevity_loft_reset_pos.new()
	i3k_game_send_str_cmd(bean)
	g_i3k_game_context:setLongevityPavilionReset(i3k_game_get_time())
end
