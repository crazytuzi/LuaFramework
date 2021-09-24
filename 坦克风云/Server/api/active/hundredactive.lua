function api_active_hundredactive(request)
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

    -- 活动名称 百服活动
    local aname = 'hundredactive'

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "useractive"})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')

    local activeCfg = mUseractive.getActiveConfig(aname)
    local self = {}
    local regstats = false

    --购买道具
    function self.buyItem(nIdx)
    	-- body
    	if not activeCfg.serverreward[nIdx] then
    		response.ret = -505
    		return false, response
    	end

    	local freedata = getFreeData(aname)
    	local totoalRes = 0
    	if type(freedata) == 'table' and type(freedata.info) == 'table' and 
    		freedata.info.st == mUseractive.info[aname].st then
    		totoalRes = freedata.info.res
    	end
    	-- 更新全局资源量
    	mUseractive.info[aname].v = totoalRes
    	--未解锁
    	if activeCfg.serverreward[nIdx].needRes > mUseractive.info[aname].v then
    		response.ret = -9001
    		return false, response
    	end
    	
        mUseractive.info[aname].ct = mUseractive.info[aname].ct or {}
    	if not mUseractive.info[aname].ct[nIdx] then
    		for i=1, nIdx do
    			if not mUseractive.info[aname].ct[i] then
    				mUseractive.info[aname].ct[i] = 0
    			end
    		end
    	end
    	--超过购买上限
    	if activeCfg.serverreward[nIdx].buyCnt <= mUseractive.info[aname].ct[nIdx] then
    		response.ret = -9002
    		return false, response
    	end

    	--扣钱
        if not mUserinfo.useGem(activeCfg.serverreward[nIdx].price) then
            response.ret = -109 
            return false, response
        end

    	--购买
    	local srvReward = activeCfg.serverreward[nIdx].r
        if not takeReward(uid, srvReward) then        
            response.ret = -403 
            return false, response
        end

    	--更新购买次数
    	mUseractive.info[aname].ct[nIdx] = mUseractive.info[aname].ct[nIdx] + 1
    	if mUseractive.info[aname].ct[nIdx] == 1 then
    		regstats = true	
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
        ret, reward = self.buyItem(nIdx)          
    end

    if not ret then
        return response 
    end

    processEventsBeforeSave()
    if uobjs.save() then        
        processEventsAfterSave()
        -- 统计
    	if regstats then
            mUseractive.setStats(aname, {idx=nIdx})
    	end
        response.data.useractive = { [aname]=mUseractive.info[aname] }
        if reward then 
            response.data.reward = formatReward(reward)
        end
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
