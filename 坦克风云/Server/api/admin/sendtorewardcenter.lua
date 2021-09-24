function api_admin_sendtorewardcenter(request)
    local response = {data={}}
	local db = getDbo()
	local URL = require "lib.url"
	
	local uid = request.params.uid or 0
	local title = URL:url_unescape(request.params.title or '') or '' -- 奖励标题
	local rtime = tonumber(request.params.rtime) or 0 -- 奖励领取开始时间
	local expire = tonumber(request.params.expire) or 0 -- 奖励存活秒数 
	local info = {desc=URL:url_unescape(request.params.info or '')} -- 奖励描述
	local reward = request.params.reward or {} -- 后端标准奖励格式 例: {userinfo_gems=100,props_p20=1}
	
	-- print('reward',reward)
	-- ptb:p(reward)
	-- local uid = 1000002
	-- local title = 'ceshi.'..getClientTs()
	-- local rtime = getClientTs()
	-- local expire = 3600
	-- local info = {desc='ceshiinfo'}
	-- local reward = {userinfo_gems=1,userinfo_r1=10000,userinfo_r2=10000,userinfo_r3=10000,userinfo_r4=10000,props_p20=1}

	expire = 86400 * 15 
	
	for i,v in pairs(reward) do
		if v <= 0 then
			response.ret = -102
			return response
		end
	end

    local ret = sendToRewardCenter(uid,'gm',title,rtime,expire,info,reward)
	
    if ret then
        response.ret = 0
        response.msg = 'send rewardtask sucess'
	else
		response.ret = -1
		response.msg = 'send rewardtask fail'
    end

    return response
end
