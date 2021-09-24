--desc:异星任务
--user:chenyunhe

local function api_active_alientask(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'alientask',
    }

    -- 获取任务列表
    function self.action_tasklist(request)
		local response = self.response
        local uid = request.uid
        if not uid then
            response.ret = -102
            return response
        end

    	local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if type(mUseractive.info[self.aname].task)~='table' or not next(mUseractive.info[self.aname].task) then
        	mUseractive.info[self.aname].task={}
        	for k,v in pairs(activeCfg.serverreward.taskList) do
                --index任务下标  r:-0未完成、1可领取、2已领取 p 进度 1,2,3 cur：当前值
                mUseractive.info[self.aname].task[k]={index=v[1].index,r=0,p=1,cur=0,con=v[1][1]}
        	end
        	mUseractive.info[self.aname].ea=0--可领取的任务额外奖励数
        	mUseractive.info[self.aname].er=0--已领取的个数
        end

        local extranum=mUseractive.info[self.aname].ea-mUseractive.info[self.aname].er
        if uobjs.save() then
			response.data[self.aname] =mUseractive.info[self.aname]
			response.data[self.aname].extranum=extranum--额外可领取的奖励数
	        response.ret = 0
	        response.msg = 'Success'
	    else
	    	response.ret=403
        end
        return response      
        
    end
    -- 领取任务奖励
    function self.action_taskreward(request)
		local response = self.response
        local uid = request.uid
        local taskType = request.params.type --任务类型
        local taskP=request.params.p -- 任务进度
       
        if not uid then
            response.ret = -102
            return response
        end

    	local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local taskList = activeCfg.serverreward.taskList
        local taskCfg=taskList[taskType][taskP]
        if type(taskCfg)~='table' or not next(taskCfg) then
        	response.ret=-102
        	return response
        end

        local curtask=mUseractive.info[self.aname].task[taskType]
        -- 验证任务信息
        if type(curtask)~='table' or not next(curtask) or curtask.p~=taskP then
        	response.ret=-102
        	return response
        end

        -- 判断条件
        if curtask.r~=1 then
        	response.ret=-102
        	return response
        end

        local reward={}
        for k,v in pairs(taskCfg.serverreward)  do
        	reward[v[1]]=(reward[v[1]] or 0)+v[2]
        end

        if  not takeReward(uid,reward) then
        	response.ret=-403
        	return response
        end

        if taskCfg.next then
        	mUseractive.info[self.aname].task[taskType].p=taskCfg.next
        	mUseractive.info[self.aname].task[taskType].index=taskList[taskType][taskCfg.next].index
            mUseractive.info[self.aname].task[taskType].r=0
        	mUseractive.info[self.aname].task[taskType].cur=0
        	mUseractive.info[self.aname].task[taskType].con=taskList[taskType][taskCfg.next][1]

        else
        	mUseractive.info[self.aname].task[taskType].r=2
        end

        if uobjs.save() then
			response.data.reward=formatReward(reward)
	        response.ret = 0
	        response.msg = 'Success'
	    else
	    	response.ret=403
        end
        return response

    end

    -- 领取完成每个任务链的额外奖励
    function self.action_extrareward(request)
		local response = self.response
        local uid = request.uid

        if not uid then
            response.ret = -102
            return response
        end

    	local uobjs = getUserObjs(uid)
        uobjs.load({'userinfo','useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        if mUseractive.info[self.aname].er>=mUseractive.info[self.aname].ea then
 			response.ret = -102
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local reward={}
        local result,rewardkey = getRewardByPool(activeCfg.serverreward.taskExtra)
        for k,v in pairs (result) do
            reward[k]=(reward[k] or 0)+v
        end
 
        if  not takeReward(uid,reward) then
        	response.ret=-403
        	return response
        end
    
        mUseractive.info[self.aname].er=(mUseractive.info[self.aname].er or 0)+1
        if uobjs.save() then
			response.data.reward=formatReward(reward)
	        response.ret = 0
	        response.msg = 'Success'
	    else
	    	response.ret=403
        end
        return response

    end

    return self
end

return api_active_alientask