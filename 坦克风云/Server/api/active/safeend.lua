--desc:平稳降落
--user:liming
local function api_active_safeend(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'safeend',
    }
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

        if curtask.r~=1 then
            response.ret=-102
            return response
        end

        local reward={}
        for k,v in pairs(taskCfg.serverreward)  do
            reward[k]=(reward[k] or 0)+v
        end

        if  not takeReward(uid,reward) then
            response.ret=-403
            return response
        end
        if taskCfg.next then
            mUseractive.info[self.aname].task[taskType].p=taskCfg.next
            mUseractive.info[self.aname].task[taskType].index=taskList[taskType][taskCfg.next].index
            mUseractive.info[self.aname].task[taskType].r=0
            mUseractive.info[self.aname].task[taskType].con=taskList[taskType][taskCfg.next][1]

        else
            mUseractive.info[self.aname].task[taskType].r=2
        end
        for k,v in pairs(mUseractive.info[self.aname].task) do
            local info=taskList[k][v.p]
            if v.r==0 then
                mUseractive.info[self.aname].task[k].con=info[1]
                if mUseractive.info[self.aname].task[k].cur>=info[1] then
                    mUseractive.info[self.aname].task[k].r=1
                end
            end
        end
        if uobjs.save() then
            response.data.reward=formatReward(reward)
            response.data.task=mUseractive.info[self.aname].task
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=403
        end
        return response

    end

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
                mUseractive.info[self.aname].task[k]={}
                mUseractive.info[self.aname].task[k].index=v[1].index
                mUseractive.info[self.aname].task[k].r=0 --0未完成、1可领取、2已领取
                mUseractive.info[self.aname].task[k].p=1 --进度 1,2,3
                mUseractive.info[self.aname].task[k].cur=0 --当前数量
            end
        end
        -- mUseractive.info[self.aname].task.m1.cur=5
        local taskCfg=activeCfg.serverreward.taskList
        for k,v in pairs(mUseractive.info[self.aname].task) do
            local info=taskCfg[k][v.p]
            if v.r==0 then
                mUseractive.info[self.aname].task[k].con=info[1]
                if mUseractive.info[self.aname].task[k].cur>=info[1] then
                    mUseractive.info[self.aname].task[k].r=1
                end
            end
        end
        -- ptb:e(mUseractive.info[self.aname].task) 
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=403
        end
        return response      
    end
    -- 抓取奖励
    function self.action_lottery(request)
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num) -- 抓取选项
        local free = tonumber(request.params.free) -- 0非免费 1免费
        local ts= getClientTs()
        local weeTs = getWeeTs()
        if not table.contains({0,1},free) or not table.contains({1,10},num) or not uid then
       	   response.ret=-102
       	   return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

		-- 免费时 单抽
        if free ==1 and num>1 then
            response.ret = -102
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
		if mUseractive.info[self.aname].t < weeTs then
            mUseractive.info[self.aname].v = 0
            mUseractive.info[self.aname].t = weeTs
        end

        if mUseractive.info[self.aname].v==1 and free==1 then
            response.ret = -102
            return response
        end

        -- 判断是否有免费次数
        if mUseractive.info[self.aname].v == 0 and free ~=1 then
            response.ret = -102
            return response
        end

        -- 消耗钻石
        local gems = 0
        if free==1 then
        	 mUseractive.info[self.aname].v=1
        else
	 		if num ==1 then
	            gems = activeCfg.cost1
	        else
	            num = 10
	            gems = activeCfg.cost2
	        end
        end
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end

        if gems>0 then
             regActionLogs(uid,1,{action=219,item="",value=gems,params={num=num}})
        end
        local reward={}
        local report={}
        local tmpreward = {}
        for i=1,num do
            local result = getRewardByPool(activeCfg.serverreward['pool'])
            table.insert(tmpreward,result)
            for k,v in pairs(result) do
                reward[k] = (reward[k] or 0) + v
            end
        end
        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end
        for k,v in pairs(tmpreward) do
            for k1,v1 in pairs(v) do
                table.insert(report, formatReward({[k1]=v1}))
            end
        end
        activity_setopt(uid,'safeend',{act='m1',num=num})
        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','safeend',num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward = hClientReward
        end

        if uobjs.save() then
 			local redis =getRedis()
            local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={} end
            table.insert(data,1,{ts,report,num,harCReward})
            if next(data) then
                for i=#data,11,-1 do
                    table.remove(data)
                end
                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[self.aname].et+86400)
            end        	
            response.data[self.aname] =mUseractive.info[self.aname]
            if next(harCReward) then
                response.data[self.aname].hReward=harCReward
            end
            response.data[self.aname].reward=report
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end
	-- 获取记录
    function self.action_getReportLog(request)
        local response = self.response
        local uid = request.uid
        if not uid then
            response.ret = -102
            return response
        end
        --test
        -- activity_setopt(uid,'safeend',{act='m2',num=15})
        local uobjs = getUserObjs(uid)
        uobjs.load({"useractive"})
        local mUseractive = uobjs.getModel('useractive')
        local redis =getRedis()
        local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
        local data =redis:get(redkey)
        data =json.decode(data)
        if type(data) ~= 'table' then data = {} end
        response.ret = 0
        response.msg = 'Success'
        response.data.report=data
        return response
    end
    

    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local weeTs = getWeeTs()
        if not uid then
            response.ret = -102
            return response
        end

        local ts= getClientTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        -- 初始化签到
        local flag = false

        if not mUseractive.info[self.aname].task then 
            flag = true
            mUseractive.info[self.aname].task = {}
            for k,v in pairs(activeCfg.serverreward.taskList) do
                table.insert(mUseractive.info[self.aname].task,0)
            end 
            mUseractive.info[self.aname].s1=0--射击次数
            mUseractive.info[self.aname].s2=0--击沉绿色数量
            mUseractive.info[self.aname].s3=0--击沉蓝色数量
            mUseractive.info[self.aname].s4=0--击沉紫色数量
            mUseractive.info[self.aname].s5=0
        end
        if type(mUseractive.info[self.aname].task) ~= 'table' then
            mUseractive.info[self.aname].task = {}--任务
            for k,v in pairs(activeCfg.serverreward.taskList) do
                local id =math.ceil((mUserinfo.level-activeCfg.levelLimit+1)/10)
                local tmpid = #v
                if id > tmpid then
                    id = tmpid
                end
                mUseractive.info[self.aname].task[k] = {}
                mUseractive.info[self.aname].task[k].index = id--任务下标
                mUseractive.info[self.aname].task[k].cur = 0 --当前数量
                mUseractive.info[self.aname].task[k].cron = v[id][1] --完成条件
                mUseractive.info[self.aname].task[k].r = 0 --是否领奖
            end
            mUseractive.info[self.aname].levelopen_a1 = 0 --福利劵
            mUseractive.info[self.aname].welnum = 0 --福利领取次数
            mUseractive.info[self.aname].levelopen_a2 = 0 --积分
            mUseractive.info[self.aname].r = 0 --排行榜奖励
        end
        if flag then
            if not uobjs.save() then
                response.ret = -102
                return response
            end
        end        
        
        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end
    


    return self
end

return api_active_safeend