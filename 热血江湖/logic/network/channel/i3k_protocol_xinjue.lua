------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

--------------------心决系统------------------------

--登录同步心决信息
function i3k_sbean.role_soulspell_sync.handler(bean)
	g_i3k_game_context:setRoleXinjueInfo(bean.info)
end

--解锁心决
function i3k_sbean.soulspell_unlock()
	local bean = i3k_sbean.soulspell_unlock_req.new()
	i3k_game_send_str_cmd(bean, "soulspell_unlock_res")
end

--心决解锁回调
function i3k_sbean.soulspell_unlock_res.handler(bean)
	if bean.ok == 1 then
		g_i3k_game_context:addXinjueGrade()
		g_i3k_logic:OpenXinJueUI()
	else
		g_i3k_ui_mgr:PopupTipMessage('解锁失败')
	end
end

--心决修心
function i3k_sbean.soulspell_props()
	local bean = i3k_sbean.soulspell_props_req.new()
	i3k_game_send_str_cmd(bean, "soulspell_props_res")
end

--心决修心回调
function i3k_sbean.soulspell_props_res.handler(res)
	if res.props then
		g_i3k_game_context:setXinjueProps(res.props)
		g_i3k_game_context:consumeXinjueFix()
		g_i3k_ui_mgr:RefreshUI(eUIID_XinJue)
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:RefreshXiuxinProps()
		g_i3k_game_context:ShowPowerChange()
	else
		g_i3k_ui_mgr:PopupTipMessage('修心失败')
	end
end

--心决突破
function i3k_sbean.soulspell_break()
	local bean = i3k_sbean.soulspell_break_req.new()
	i3k_game_send_str_cmd(bean, "soulspell_break_res")
end

--心决突破
function i3k_sbean.soulspell_break_res.handler(res)
	if res.ok == 1 then
		g_i3k_game_context:consumeXinjueBreak()
		if res.success == 1 then
			g_i3k_game_context:clearXinjueBreakTimes()
			g_i3k_game_context:addXinjueGrade()
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1439))
			g_i3k_ui_mgr:RefreshUI(eUIID_XinJue)
			g_i3k_ui_mgr:OpenUI(eUIID_XinJueBreakSuccess)
		else
			g_i3k_game_context:addXinjueBreakTimes()
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1440))
		end
		g_i3k_ui_mgr:RefreshUI(eUIID_XinJue)
	else
		g_i3k_ui_mgr:PopupTipMessage('突破请求失败')
	end

end
