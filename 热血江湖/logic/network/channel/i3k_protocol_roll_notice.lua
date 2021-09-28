------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

---------------------------------系统同步滚动通知消息----------------------------------------------



function i3k_sbean.rollnotice_sync.handler(bean)
	g_i3k_game_context:SyncRollNotice(bean.rollnotices)
end


--------rollnotice_detail的异步响应
function i3k_sbean.query_roll_notice(noticeId)
	local bean = i3k_sbean.rollnotice_query.new()
	bean.noticeId = noticeId
	
	i3k_game_send_str_cmd(bean)
end


------- rollnotice_query的异步响应 
function i3k_sbean.rollnotice_detail.handler(bean)
	--notice(id,sendTime,freq,liftTime,content)
	if bean.notice then
		g_i3k_game_context:onSyncBroadcast(bean.notice)
	else
		
	end
end
