function api_user_evaluate(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid

     if uid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})    
    local mUserinfo = uobjs.getModel('userinfo')

    --if mUserinfo.flags.evaluate then
        --return response
    --end

    mUserinfo.flags.evaluate = (mUserinfo.flags.evaluate or 0 ) + 1
    local activeCfg = getConfig("player")
    if activeCfg.evaluate then
		if tonumber( mUserinfo.flags.evaluate) > #activeCfg.evaluate then
				response.ret = -9119
				return response
		end
		local itemcfg = activeCfg.evaluate[mUserinfo.flags.evaluate]
		if mUserinfo.level < itemcfg.level then
				response.ret = -9120
				return response
		end

		if not takeReward(uid, itemcfg.r) then
				response.ret = -114	
				return response
		end

		response.data.userevaluate = {reward = formatReward(itemcfg.r)}
    end

    if uobjs.save() then          
        response.ret = 0    
        response.msg = 'Success'
    end
    
    return response
end	
