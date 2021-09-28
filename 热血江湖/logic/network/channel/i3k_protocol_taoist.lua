------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

--------------------------------------------------------

--正邪道场同步信息
function i3k_sbean.sync_taoist(callback)
	local sync = i3k_sbean.bwarena_sync_req.new()
	sync.__callback = callback
	i3k_game_send_str_cmd(sync, "bwarena_sync_res")
end

function i3k_sbean.bwarena_sync_res.handler(bean,req)
	local info = bean.info
	if info then
		g_i3k_game_context:setTaoistRank(info.rank)
		if #info.enemies~=0 then
			--g_i3k_ui_mgr:CloseUI(eUIID_Arena_Choose)
			g_i3k_ui_mgr:OpenUI(eUIID_ArenaList)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadTaoist", info)
			g_i3k_game_context:LeadCheck()
		else
			local desc = i3k_get_string(15139)
			g_i3k_ui_mgr:ShowMessageBox1(desc)
		end
		
		if req and req.__callback then
			req.__callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("正邪道场同步服务器返回失败")
	end
end





--设置参战随从	
function i3k_sbean.set_taoist_pets(pets, callback)
	local set = i3k_sbean.bwarena_setpet_req.new()
	set.pets = pets
	set.callback = callback
	i3k_game_send_str_cmd(set, "bwarena_setpet_res")
end

function i3k_sbean.bwarena_setpet_res.handler(bean, res)
	if bean.ok==1 then
		if res.callback then
			res.callback()
		end
		g_i3k_ui_mgr:CloseUI(eUIID_TaoistPets)
		
		for k,v in pairs(res.pets) do
            local map = {}
            local tag = "佣兵Id"
            DCEvent.onEvent("正邪道场出战佣兵", { tag = tostring(k)})
        end 
	else
		
	end
end





--正邪道场刷新对手
function i3k_sbean.refresh_taoist_enemy()
	local refresh = i3k_sbean.bwarena_refresh_req.new()
	i3k_game_send_str_cmd(refresh, "bwarena_refresh_res")
end

function i3k_sbean.bwarena_refresh_res.handler(bean, res)
	local enemies = bean.enemies
	if enemies and #enemies~=0 then
		g_i3k_game_context:UseDiamond(i3k_db_taoist.refreshDiamond, false,AT_BWARENA_REFRESH_ENEMY)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "addRefreshTimes")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "setEnemiesData", enemies)
	end
end





--正邪道场购买次数
function i3k_sbean.taoist_buy_times(times, callback)
	local buy = i3k_sbean.bwarena_buytimes_req.new()
	buy.times = times
	buy.callback = callback
	i3k_game_send_str_cmd(buy, "bwarena_buytimes_res")
end

function i3k_sbean.bwarena_buytimes_res.handler(bean, res)
	if bean.ok==1 then
		if res.callback then
			res.callback()
		end
	else
		
	end
end




--正邪道场开始战斗
function i3k_sbean.taoist_start_fight(targetId, petsCount)
	local start = i3k_sbean.bwarena_startattack_req.new()
	start.targetID = targetId
	start.petsCount = petsCount
	i3k_game_send_str_cmd(start, "bwarena_startattack_res")
end

function i3k_sbean.bwarena_startattack_res.handler(bean, res)
	if bean.ok==1 then
	end
end







--正邪道场领取积分奖励
function i3k_sbean.take_taoist_reward(callback)
	local take = i3k_sbean.bwarena_takescore_req.new()
	take.callback = callback
	i3k_game_send_str_cmd(take, "bwarena_takescore_res")
end

function i3k_sbean.bwarena_takescore_res.handler(bean, res)
	if bean.ok==1 then
		if res.callback then
			res.callback()
		end
	else
		
	end
end




--正邪道场战报
function i3k_sbean.sync_taoist_log()
	local sync = i3k_sbean.bwarena_log_req.new()
	i3k_game_send_str_cmd(sync, "bwarena_log_res")
end

function i3k_sbean.bwarena_log_res.handler(bean, res)
	local logs = bean.logs
	if #logs>0 then
		g_i3k_ui_mgr:OpenUI(eUIID_TaoistLogs)
		g_i3k_ui_mgr:RefreshUI(eUIID_TaoistLogs, logs)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(130))
	end
end




--正邪道场排行榜
function i3k_sbean.sync_taoist_rank(rankType, index, len, callback)
	local sync = i3k_sbean.bwarena_ranks_req.new()
	sync.bwtype = rankType
	sync.index = index
	sync.len = len>20 and 20 or len
	sync.callback = callback
	i3k_game_send_str_cmd(sync, "bwarena_ranks_res")
end

function i3k_sbean.bwarena_ranks_res.handler(bean, res)
	local ranks = bean.ranks
	if ranks and #ranks>0 then
		if g_i3k_ui_mgr:GetUI(eUIID_TaoistRank) then
			if res.callback then
				res.callback()
			end
		else
			g_i3k_ui_mgr:OpenUI(eUIID_TaoistRank)
		end
		g_i3k_ui_mgr:RefreshUI(eUIID_TaoistRank, ranks)
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("排行榜无资讯，查看失败"))
	end
end








--通知协议
function i3k_sbean.role_bwarenamap_start.handler(bean)
	g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_TAOIST, g_SCHEDULE_COMMON_MAPID)
end

function i3k_sbean.role_bwarenamap_end.handler(bean)
	
end

function i3k_sbean.role_bwarena_result.handler(bean)
	local addScore = bean.addScore
	local addExp = bean.addExp
	local ui
	if addScore>0 then
		ui = eUIID_TaoistWin
	else
		ui = eUIID_TaoistLose
	end
	g_i3k_ui_mgr:OpenUI(ui)
	g_i3k_ui_mgr:RefreshUI(ui, addExp, addScore)
end
