
------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/network/channel/i3k_channel");

-----------------------------------
--家园守卫战

--地图信息
function i3k_sbean.homeland_guard_map_info.handler(bean)

	g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
	g_i3k_ui_mgr:OpenUI(eUIID_DefendSummary)
	g_i3k_ui_mgr:RefreshUI(eUIID_DefendSummary)

	g_i3k_game_context:SetHomeLandGuardMonsterCount(bean.curSpawnCount)--第一波怪的波数在这里同步
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_DefendSummary, "UpdateMonsterCount")

	g_i3k_ui_mgr:OpenUI(eUIID_HomeLandSkill)
	local skillCanUseTimes = bean.mapSkillInfo and bean.mapSkillInfo.skillCanUseTimes or {}
	local skillCommonUseTime = bean.mapSkillInfo and bean.mapSkillInfo.skillCommonUseTime or 0
	g_i3k_ui_mgr:RefreshUI(eUIID_HomeLandSkill, skillCommonUseTime, skillCanUseTimes)

	g_i3k_ui_mgr:OpenUI(eUIID_HomeLandTreeBlood)
	g_i3k_ui_mgr:RefreshUI(eUIID_HomeLandTreeBlood, bean.goldenTreeInfos)

end

--刷新怪物波数
function i3k_sbean.homeland_guard_spawn_count.handler(bean)
	g_i3k_game_context:SetHomeLandGuardMonsterCount(bean.count)

	local msg = g_i3k_db.i3k_db_get_homeland_guard_popMsg(bean.count)
	if msg then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(msg))
	end

	g_i3k_ui_mgr:InvokeUIFunction(eUIID_DefendSummary, "UpdateMonsterCount")
end

--刷新果树血量
function i3k_sbean.homeland_guard_goldentree_info.handler(bean)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandTreeBlood, "UpdateTreeBlood", bean)
end

--副本技能
function i3k_sbean.sync_role_map_skill_info.handler(bean)
	local info = bean.info
	local skillCanUseTimes = bean.info and bean.info.skillCanUseTimes or {}
	local skillCommonUseTime = bean.info and bean.info.skillCommonUseTime or 0
	g_i3k_ui_mgr:RefreshUI(eUIID_HomeLandSkill, 0, skillCanUseTimes)
end

--果树喊话
function i3k_sbean.homeland_guard_goldentree_pop.handler(bean)
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5548,bean.percent))
end
