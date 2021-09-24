--
--desc: 红包回馈
--user: chenyunhe
--
local function api_active_redbagback(reuest)
	local self = {
	 	response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'redbagback',
    }

    function self.before(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive'})
        local mUseractive = uobjs.getModel('useractive')

        if not uid then
            response.ret = -102
            return response
        end

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

    end

    -- 刷新
    function self.action_refresh(request)
    	local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local flag = mUseractive.initAct(self.aname)
        if flag then
            if not uobjs.save() then
                response.ret = -106
                return response
            end
        end

        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 领取充值奖励
    function self.action_reward(request)
    	local response = self.response
        local uid=request.uid
        local item = request.params.item --(1累计充值2累计充值再充值)
        local id = request.params.id -- 第几个

        if not item or not id then
        	response.ret = -102
        	return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        mUseractive.initAct(self.aname)-- 刷新数据，如果客户端界面没切换过 实际服务器数据已经刷新了
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local redbagcfg = copyTable(activeCfg.serverreward.redbag[item][id])
        if type(redbagcfg)~='table' then
        	response.ret = -102
        	return response
        end

        local gem = mUseractive.info[self.aname].gem
        local num = mUseractive.info[self.aname]['gem'..item][id] or 0--已经领取的次数
        local ablenum = 0-- 今日可领取次数
        if item ==1 then
        	-- 超过当日领取上限
        	if redbagcfg[2]>0 then
        		if num >= redbagcfg[2] then
	        		response.ret = -1993
	        		return response
	        	end
        	end
        	
        	local cangetnum = math.floor((gem-redbagcfg[1]*num)/redbagcfg[1])
        	if redbagcfg[2]>0 then
        		local leftnum = redbagcfg[2]-num
	        	if cangetnum<=leftnum then
	        		ablenum = cangetnum
	        	else
	        		ablenum = leftnum
	        	end
	        else
	        	ablenum = cangetnum
        	end
        else
        	if redbagcfg[2]> 0 then
        		if num >= redbagcfg[2] then
	        		response.ret = -1993
	        		return response
	        	end
        	end
        	local extra = gem-activeCfg.preGems-- 额外累计充值的钻石
        	cangetnum = math.floor((extra-num*redbagcfg[1])/redbagcfg[1])
        	if redbagcfg[2]>0 then
        		local leftnum = redbagcfg[2]-num
	        	if cangetnum<=leftnum then
	        		ablenum = cangetnum
	        	else
	        		ablenum = leftnum
	        	end
	        else
	        	ablenum = cangetnum
        	end
        end

    	if ablenum<=0 then
    		response.ret = -102
    		return response
    	end

    	local reward ={}
    	for k,v in pairs(redbagcfg[3]) do
    		reward[k] = (reward[k] or 0) + v*ablenum
    	end

    	if not takeReward(uid,reward) then
    		response.ret = -106
    		return response
    	end

    	mUseractive.info[self.aname]['gem'..item][id] = mUseractive.info[self.aname]['gem'..item][id] + ablenum
    	if not uobjs.save() then
	       response.ret = -106
	       return response
    	end

    	response.data[self.aname] = mUseractive.info[self.aname]
    	response.data[self.aname].reward = formatReward(reward)
        response.ret = 0
        response.msg = 'Success'

        return response

    end

    return self
end

return api_active_redbagback