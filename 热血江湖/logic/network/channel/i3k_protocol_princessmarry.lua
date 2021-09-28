------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

--进入地图同步协议
function i3k_sbean.princess_marry_map_info.handler(bean)
	--<field name="eventID" type="int32"/>
	--<field name="taskValue" type="int32"/>
	--<field name="score" type="int32"/>
	--<field name="princessCurHP" type="int64"/>
	--<field name="princessMaxHP" type="int64"/>
	g_i3k_game_context:setPrincessMarryInfo(bean)
	g_i3k_ui_mgr:RefreshUI(eUIID_PrincessMarryBattle)
end

--公主出嫁副本开始
function i3k_sbean.princess_marry_map_start.handler(bean)
	--活跃度和次数
	g_i3k_game_context:addPrincessMarryEnterTimes(1)	
	local cfg = i3k_db_schedule.cfg
	local mapID = g_SCHEDULE_COMMON_MAPID
		
	for _, v in ipairs(cfg or {}) do
		if v.typeNum == g_SCHEDULE_TYPE_PRINCESSMARRY then
			mapID = v.mapID
			break
		end
	end
		
	g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_PRINCESSMARRY, mapID)
end

--报名协议
function i3k_sbean.princess_marry_sign_up(id)
	local bean = i3k_sbean.princess_marry_sign_req.new()
	i3k_game_send_str_cmd(bean, "princess_marry_sign_res")
end

function i3k_sbean.princess_marry_sign_res.handler(bean)
	--<field name="ok" type="int32"/>
	if bean.ok > 0 then
		g_i3k_game_context:setPrincessMarrySignUpTime(i3k_game_get_time())
		g_i3k_game_context:InMatchingState(i3k_game_get_time(), g_PRINCESS_MARRY_MATCH)
	end
end

--登录同步公主出嫁信息
function i3k_sbean.role_princess_marry.handler(bean)
	--self.signTime:		int32	报名时间
	--self.dayEnterTimes:		int32	
	local info = {signTime = bean.signTime, dayEnterTimes = bean.dayEnterTimes}
	g_i3k_game_context:setPrincessMarrySignUpTimeInfo(info)
	
	if bean.signTime > 0 then
		g_i3k_game_context:InMatchingState(bean.signTime, g_PRINCESS_MARRY_MATCH)
	end
end

--公主出嫁匹配结果
function i3k_sbean.princess_marry_match.handler(bean)
	--self.result:		int32	1:成功 -1:超时
	g_i3k_game_context:StopMatchingState()
	g_i3k_game_context:setPrincessMarrySignUpTime(0)
end


--公主出嫁取消报名  
function i3k_sbean.princess_marry_quit_up()
	local bean = i3k_sbean.princess_marry_quit_req.new()
	i3k_game_send_str_cmd(bean, "princess_marry_quit_res")
end

function i3k_sbean.princess_marry_quit_res.handler(bean)
	if bean.ok > 0 then
		g_i3k_game_context:setPrincessMarrySignUpTime(0)
		g_i3k_game_context:StopMatchingState()
	end
end

--同步积分
function i3k_sbean.princess_marry_add_score.handler(bean)
	g_i3k_game_context:addPrincessMarryScore(bean.add)
	--<field name="add" type="int32"/>
end

--同步任务
function i3k_sbean.princess_marry_update_task.handler(bean)
	--<field name="taskValue" type="int32"/>
	g_i3k_game_context:synPrincessTaskValue(bean.taskValue)
end

--同步当前事件一定发
function i3k_sbean.princess_marry_sync_event.handler(bean) 
	--self.eventID:		int32
	g_i3k_game_context:refreshPrincessMarryStage(bean.eventID)
	g_i3k_game_context:synPrincessTaskValue(0)
end

--通知事件有客户端表现才发
function i3k_sbean.princess_marry_trig_event.handler(bean) 
	--<field name="eventID" type="int32"/>
	g_i3k_game_context:invokePrincessMarryEvent()
end

--公主位置请求
function i3k_sbean.princess_marry_require_pos(miniMap, mapId)
	local bean = i3k_sbean.princess_marry_get_pos.new()
	i3k_game_send_str_cmd(bean)
end

--通知公主位置和血量
function i3k_sbean.princess_marry_sync_pos.handler(bean)
	--<field name="pos" type="Vector3"/>
	g_i3k_game_context:refreshPrincessMarryPosAndRotation(bean.pos)	
	g_i3k_game_context:setPrincessBlood(bean.curHP, bean.maxHP)
end

--排行榜
function i3k_sbean.princess_marry_require_rank()
	local bean = i3k_sbean.princess_marry_get_rank.new()
	i3k_game_send_str_cmd(bean)
end

function i3k_sbean.princess_marry_sync_rank.handler(bean)
	if bean.ranks then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PrincessMarryBattle, "refreshRankLayer", bean.ranks)
	end
end

function i3k_sbean.princess_marry_map_result.handler(bean)
	--self.win:		int32	 1 是胜利 0 是失败
	--self.selfRank:		int32	
	--self.ranks:		vector[RankRole]	
	local info = {win = bean.win, selfRank = bean.selfRank, ranks = bean.ranks}
	g_i3k_logic:OpenPrincessMarryResult(info)
end
