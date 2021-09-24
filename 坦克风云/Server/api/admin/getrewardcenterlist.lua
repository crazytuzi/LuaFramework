function api_admin_getrewardcenterlist(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

	local ts = getClientTs()
    local uid = request.uid
    local page = tonumber(request.params.page) or 1
	local limit = tonumber(request.params.limit) or 50
	local start = (page - 1) * limit

    if uid == nil then -- 参数不正确
        response.ret = -102
        return response
    end
	
	if not moduleIsEnabled('rewardcenter') then -- 功能未开放
		response.ret = -314
        return response
	end

	require "lib.rewardcenter"
	
	local rewardcenter = model_rewardcenter()
	response.data.page = page
	response.data.rewardcenter = {}
    response.data.rewardcenter.total,response.data.rewardcenter.list = rewardcenter.getRewardListAllInfo(uid,start,limit)
	
	response.ret = 0        
	response.msg = 'Success'

    return response
end
