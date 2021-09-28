------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")
--------------------------------------------------------
--同步帮派工资信息
function i3k_sbean.request_sect_salary_sync_req()
	local data = i3k_sbean.sect_salary_sync_req.new()
	i3k_game_send_str_cmd(data,"sect_salary_sync_res")
end

function i3k_sbean.sect_salary_sync_res.handler(bean)
	if not bean.roleData then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3212))
		return
	end
	g_i3k_ui_mgr:OpenUI(eUIID_FactionSalary)
	g_i3k_ui_mgr:RefreshUI(eUIID_FactionSalary,bean)
end

--领取基础工资
function i3k_sbean.request_sect_base_salary_take_req(callback)
	local data = i3k_sbean.sect_base_salary_take_req.new()
	data.callback = callback
	i3k_game_send_str_cmd(data,"sect_base_salary_take_res")
end

function i3k_sbean.sect_base_salary_take_res.handler(bean,req)
	if bean.ok == 1 then
		i3k_sbean.request_sect_salary_sync_req()
		req.callback()
	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3215))		
	end
end

--领取活跃工资
function i3k_sbean.request_sect_activity_salary_take_req(callback)
	local data = i3k_sbean.sect_activity_salary_take_req.new()
	data.callback = callback
	i3k_game_send_str_cmd(data,"sect_activity_salary_take_res")
end

function i3k_sbean.sect_activity_salary_take_res.handler(bean,req)
	if bean.ok == 1 then
		req.callback()
		i3k_sbean.request_sect_salary_sync_req()
	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3215))
	end
end
