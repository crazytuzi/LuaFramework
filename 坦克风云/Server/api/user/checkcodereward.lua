function api_user_checkcodereward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    if uid == nil  then
        response.ret = -102
        return response
    end
	
	if not moduleIsEnabled('checkcode') then
		response.ret = -102
        return response
	end
	
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
	
    local mUserinfo = uobjs.getModel('userinfo')
	local redis = getRedis()
	local redisKey = 'z'..getZoneId()..'.checkcode.'..uid..'.'..getWeeTs()
	local count = redis:get(redisKey) or 0
	
	if tonumber(count) < 5 then
		local reward = {userinfo_r4=math.pow(mUserinfo.level,2)*1000}
		local ret = takeReward(uid,reward)
		if ret then
			count = count + 1
			local save = redis:set(redisKey,count)
			redis:expire(redisKey,86400)

			if save then
				processEventsBeforeSave()
				if uobjs.save() then        
					processEventsAfterSave()
					response.data.userinfo = mUserinfo.toArray(true)
					response.ret = 0
					response.data.reward = formatReward(reward)
					response.msg = 'Success'
				end
			end
		end
	else
		response.ret = -6010
        return response
	end

    return response
end
