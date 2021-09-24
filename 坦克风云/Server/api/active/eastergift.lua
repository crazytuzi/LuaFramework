function api_active_eastergift(request)
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

    -- 活动名称 复活节彩蛋大搜寻
    local aname = 'eastergift'

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "useractive"})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')

    local activeCfg = mUseractive.getActiveConfig(aname)
    local self = {}

    --领取奖励
    function self.getItemAward(nIdx)
    	-- body
        local item = activeCfg.serverreward[nIdx]
        if not item then 
            response.ret = -110
            return false, response
        end

        --不能领取 0/nil  1  2
        if item.rechange==0 and (mUseractive.info[aname]["r"..nIdx] and mUseractive.info[aname]["r"..nIdx]==2) then
            response.ret = -9021
            return false, response
        elseif (mUseractive.info[aname]["r"..nIdx] and mUseractive.info[aname]["r"..nIdx]~=1) then
            response.ret = -9021
            return response
        end

        -- 领取了
        mUseractive.info[aname]["r"..nIdx] = 2
        
        --发奖励
        local srvReward = item.r
        if not takeReward(uid, srvReward) then        
            response.ret = -403 
            return false, response
        end

    	return true, srvReward
    end
 
    ----------------------main-----------------------------
    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
        
    local action = tonumber( request.params.action ) or 1
    local nIdx = tonumber(request.params.idx)   
    local ret, reward 

    if action == 1 then
        ret, reward = self.getItemAward(nIdx)          
    end

    if not ret then
        return response 
    end

    processEventsBeforeSave()
    if uobjs.save() then        
        processEventsAfterSave()

        response.data.useractive = { [aname]=mUseractive.info[aname] }
        if reward then 
            response.data.reward = formatReward(reward)
        end
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
