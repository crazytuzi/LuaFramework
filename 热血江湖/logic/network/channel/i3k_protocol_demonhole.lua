------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

----------------------------------------------------

-- 同步伏魔洞信息
function i3k_sbean.demonhole_sync()
	local bean = i3k_sbean.demonhole_sync_req.new()
	i3k_game_send_str_cmd(bean, "demonhole_sync_res")
end

function i3k_sbean.demonhole_sync_res.handler(bean, req)
	if bean.curFloor >= 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadDemonHole", bean.curFloor, bean.dayEnterTimes)
	end
end

-- 参加伏魔洞
function i3k_sbean.demonhole_join()
	local bean = i3k_sbean.demonhole_join_req.new()
	i3k_game_send_str_cmd(bean, "demonhole_join_res")
end

function i3k_sbean.demonhole_join_res.handler(bean)
	if bean.ok == 1 then
		
	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage("等级不足")
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage("没有次数")
	elseif bean.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage("不在开放时间")
	elseif bean.ok == -4 then
		g_i3k_ui_mgr:PopupTipMessage("服务器返回"..bean.ok)
	elseif bean.ok == -5 then
		g_i3k_ui_mgr:PopupTipMessage("层数越界")
	elseif bean.ok == -6 then
		g_i3k_ui_mgr:PopupTipMessage("转职等级不满足")
	end
end

-- 进入下一层或上一层
function i3k_sbean.demonhole_changefloor(floor, needKey)
	local bean = i3k_sbean.demonhole_changefloor_req.new()
	bean.floor = floor
	bean.needKey = needKey
	i3k_game_send_str_cmd(bean, "demonhole_changefloor_res")
end

function i3k_sbean.demonhole_changefloor_res.handler(bean, req)
	if bean.ok == 1 then
		if req.needKey then
			g_i3k_game_context:UseCommonItem(i3k_db_demonhole_base.keyId,  req.needKey, AT_UP_DEMON_FLOOR)
		end
	end
end

-- 客户端请求查看战况
function i3k_sbean.demonhole_battle()
	local bean = i3k_sbean.demonhole_battle_req.new()
	i3k_game_send_str_cmd(bean, "demonhole_battle_res")
end

function i3k_sbean.demonhole_battle_res.handler(bean)
	g_i3k_ui_mgr:OpenUI(eUIID_DemonHoleRank)
	g_i3k_ui_mgr:RefreshUI(eUIID_DemonHoleRank, bean.curFloor, bean.total, bean.addExp, 1)
end

-- 进入伏魔洞，同步信息
function i3k_sbean.role_demonholemap_sync.handler(bean)
	g_i3k_game_context:SetDemonHoleInfo(bean.curFloor, bean.grade)
	g_i3k_game_context:SetDemonHoleBossState(-1) --清除上次伏魔洞boss状态数据
	g_i3k_logic:OpenDemonHoleSummaryUI()
	local world = i3k_game_get_world()
	if world then
		world:SetStartTime(bean.startTime)
	end
end

-- 伏魔洞战报界面
function i3k_sbean.role_demonhole_result.handler(bean)
	g_i3k_ui_mgr:OpenUI(eUIID_DemonHoleRank)
	g_i3k_ui_mgr:RefreshUI(eUIID_DemonHoleRank, bean.curFloor, bean.total, bean.addExp, 2)
end

-- 通知客户端伏魔洞开始
function i3k_sbean.role_demonhole_start.handler(bean)
	g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_DEMONHOLE, g_SCHEDULE_COMMON_MAPID)
end

-- 同步伏魔洞boss的状态
function i3k_sbean.demonhole_boss_state.handler(bean)
	g_i3k_game_context:SetDemonHoleBossState(bean.state)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_DemonHolesummary, "updateBossState", bean.state)
end
