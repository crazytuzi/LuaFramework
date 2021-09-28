------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

--------------------世界杯系统------------------------

--查询世界杯相关信息
function i3k_sbean.world_cup_inquiry()
	local bean = i3k_sbean.world_cup_sync_req.new()
	i3k_game_send_str_cmd(bean,i3k_sbean.world_cup_sync_res.getName())
end

--同步世界杯信息
function i3k_sbean.world_cup_sync_res.handler(bean)
	if bean.worldCupInfo then
		g_i3k_game_context:setWorldCup(bean.worldCupInfo)
		g_i3k_ui_mgr:OpenUI(eUIID_WorldCup)
		g_i3k_ui_mgr:RefreshUI(eUIID_WorldCup)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_db_string[1422])
	end
end

--下注 国家id 下注类型
function i3k_sbean.world_cup_bet(countryId, recordId)
	local bean = i3k_sbean.world_cup_conduct_bet_req.new()
	bean.countryId = countryId
	bean.recordId = recordId
	i3k_game_send_str_cmd(bean,i3k_sbean.world_cup_conduct_bet_res.getName())
end

--下注响应
function i3k_sbean.world_cup_conduct_bet_res.handler(bean)
	if bean.ok == 1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_db_string[1420])
		g_i3k_game_context:UseCommonItem(g_BASE_ITEM_DIAMOND,i3k_db_world_cup_other.wagerCoin,AT_WORLD_CUP_CONDUCT_ANTE)
		i3k_sbean.world_cup_inquiry()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_db_string[1421])
	end
end
