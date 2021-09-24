function api_rewardcenter_delexpirereward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

	if not moduleIsEnabled('rewardcenter') then
		response.ret = -314
        return response
	end
	
	require "lib.rewardcenter"
	
	local ts = getClientTs()
	local rewardcenter = model_rewardcenter()

	rewardcenter.delExpireReward(86400*5)

        -- 删除军团帮助的log
    local weeTs = getWeeTs()
    weeTs=weeTs-30*86400
    local db = getDbo()
    ts=ts-600  --  十分钟的冗余
    db:query("delete from alliancehelplog where updated_at<="..weeTs)
    db:query("delete from alliancehelp where et<"..ts)

    response.ret = 0
    response.msg = 'Success'
    
    return response
end
