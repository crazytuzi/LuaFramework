------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

function i3k_sbean.syncSchedule()
	local data = i3k_sbean.schedule_sync_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.schedule_sync_res.getName())
end
--  日程表同步
function i3k_sbean.schedule_sync_res.handler(bean,req)
	g_i3k_ui_mgr:OpenUI(eUIID_Schedule)
	g_i3k_ui_mgr:RefreshUI(eUIID_Schedule,bean.msgs)
end

--  领取奖励
function i3k_sbean.schedule_mapreward_res.handler(bean,req)
	if bean.ok > 0 then 
		local rewardsTab = {}
		for k,v in pairs(bean.rewards) do
		local t = {id = k,count = v}
			table.insert( rewardsTab, t )
		end
		g_i3k_ui_mgr:ShowGainItemInfo(rewardsTab)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Schedule, "setSchedule", req.sid)
		g_i3k_game_context:SetScheduleRewards(req.sid)
	elseif bean.ok == 0 then 
		g_i3k_ui_mgr:PopupTipMessage("系统错误,领取失败")
	elseif bean.ok == -1 then 
		g_i3k_ui_mgr:PopupTipMessage("领取条件未达到")
	elseif bean.ok == -2 then 
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足,活跃奖励领取失败")
	end
end

function i3k_sbean.role_schedule_info.handler(bean)
	g_i3k_game_context:SetScheduleInfo( bean.schedule )
end
