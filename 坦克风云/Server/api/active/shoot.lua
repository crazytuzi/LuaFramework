--desc:射击表演
--user:liming
local function api_active_shoot(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'shoot',
    }

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
             regActionLogs(uid,1,{action=210,item="",value=gems,params={num=num}})
        end
        --目标个数
        local targetNum=activeCfg.targetNum 
        local critRate=activeCfg.critRate*100
        local critnum = 0
        local poolkeys = {}
        local reward={}
        local report={}
        local tmpreward = {}
        for i=1,targetNum do
            local poolkey = getRewardByPool(activeCfg.serverreward['colorPool'])
            table.insert(poolkeys,poolkey[1])
            local result = {}
            if i<=num then
               result = getRewardByPool(activeCfg.serverreward['pool'..poolkey[1]])
               local s = 's'..(poolkey[1]+1)
               mUseractive.info[self.aname][s] = mUseractive.info[self.aname][s] + 1
               local rd = rand(1,100)
               if rd <= critRate then
                   for k,v in pairs(result) do
                       result[k] = v*2
                   end
                   critnum = critnum + 1
               end
               for k,v in pairs(result) do
                   reward[k] = (reward[k] or 0) + v
               end
               table.insert(tmpreward,result)
            end
            
        end
        mUseractive.info[self.aname].s1=mUseractive.info[self.aname].s1 + num
        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end
        for k,v in pairs(tmpreward) do
            for k1,v1 in pairs(v) do
                table.insert(report, formatReward({[k1]=v1}))
            end
        end
       
        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','shoot',num)
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
            table.insert(data,1,{ts,report,num,critnum,harCReward})
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
            response.data[self.aname].target=poolkeys
            response.data[self.aname].critnum=critnum
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
    
    --任务奖励
    function self.action_taskgift(request)
        local response = self.response
        local uid = tonumber(request.uid) or 0
        local index = tonumber(request.params.index)
        local ts = getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive','accessory','hero','equip'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeStatus = mUseractive.getActiveStatus(self.aname)
        if  activeStatus ~= 1 then
            response.ret = -1977
            return response
        end
        local report = {}
        local reward = {}
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local taskList = activeCfg.serverreward.taskList[index]
        if type(taskList) ~= 'table' then
            response.ret = -102
            return response
        end
        local taskid = taskList.type
        local tasknum = taskList.num
        local rewardCfg = taskList.serverreward
        for k,v in pairs(rewardCfg) do
            reward[k] = (reward[k] or 0) + v
        end
        if mUseractive.info[self.aname].task[index] == 1 then
            response.ret = -1976
            return response
        end
        if mUseractive.info[self.aname][taskid] < tasknum then
            response.ret = -1987
            return response
        end
        if next(reward) then
            for k,v in pairs(reward) do
                table.insert(report, formatReward({[k]=v}))
            end
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end
            mUseractive.info[self.aname].task[index] = 1
        end
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end
        return response        
    end

    return self
end

return api_active_shoot