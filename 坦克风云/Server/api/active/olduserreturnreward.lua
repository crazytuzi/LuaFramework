function api_active_olduserreturnreward(request)
    local response = {
        ret=-1,
        msg='error',
        data={},

    }

    local uid = request.uid
    local tid = tonumber(request.params.tid)
    if uid==nil then
        response.ret=-102    
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","useractive" ,"props","bag","skills","buildings","dailytask","task"})

    local aname    ="oldUserReturn"
    local mUserinfo =  uobjs.getModel("userinfo")
    local mUseractive =uobjs.getModel("useractive")

    local activStatus = mUseractive.getActiveStatus(aname)

    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
    if  not mUseractive.info.oldUserReturn.n then
        response.ret = -1981
        return response
    end
    local activeCfg = getConfig("active")
    local rewards = true
    local params = {}
    if tid==1 then
        if mUseractive.info.oldUserReturn.c==1 then
        --已经领过了
            response.ret = -1976 
            return response
        end
        if mUseractive.info.oldUserReturn.n==1 then
            local alevel = mUseractive.info.oldUserReturn.l
            --[[
			for k,v in pairs (activeCfg.oldUserReturn.serverreward.returnLevel) do
				if v[1]>=alevel and v[2]<=alevel then
					index = k
					break
				end
			end--]]
            rewards = activeCfg.oldUserReturn.serverreward.box[alevel-(activeCfg.oldUserReturn.serverreward.minlevel-1)]
            if not rewards then
                rewards = activeCfg.oldUserReturn.serverreward.box[1]
            end
        else
            rewards = activeCfg.oldUserReturn.serverreward.staybehindreward[1]    
        end
        mUseractive.info.oldUserReturn.c = 1;
    else
        local hnum    = mUseractive.info.oldUserReturn.v or 0
        local tnum  = mUseractive.getoldUserReturnTnum()
        local num     = math.floor(tnum/activeCfg.oldUserReturn.serverreward.need)-hnum
        if num<=0 then
        --数量不够 不能领取
            response.ret = -1981
            return response
        end
        rewards = copyTab(activeCfg.oldUserReturn.serverreward.totalreward[1])
        for k,v in pairs (rewards) do
            rewards[k] = num*v
            if rewards[k] > 50 then
                rewards[k] = 50
            end
        end
        mUseractive.info.oldUserReturn.v =  num+hnum 
    end

    if not takeReward(uid,rewards) then        
        response.ret = -403 
        return response
    end

    local log = {cmd=request,r=rewards}
    writeLog(log,"oldUserReturnRewardReport")

    if uobjs.save() then
        
        response.ret =  0        
        response.msg = 'Success'
        return response
    end

    return response
    
end