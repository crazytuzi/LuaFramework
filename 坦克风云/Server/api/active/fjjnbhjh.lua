--desc:飞机技能捕获计划
--user:chenyunhe

local function api_active_fjjnbhjh(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'fjjnbhjh',
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
    -- 抓取奖励
    function self.action_getreward(request)
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num) -- 抓取选项
        local free = tonumber(request.params.free) -- 0非免费 1免费
        local ts= getClientTs()
        local weeTs = getWeeTs()
        
        if not table.contains({0,1},free) or not table.contains({1,5},num) or not uid then
       	   response.ret=-102
       	   return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

		-- 免费时 单抽
        if free ==1 and num>1 then
            response.ret = -102
            return response
        end
       
        local activeCfg = mUseractive.getActiveConfig(self.aname)
		if mUseractive.info[self.aname].t ~= weeTs then
            mUseractive.info[self.aname].v = 0
            mUseractive.info[self.aname].t = weeTs
            mUseractive.info[self.aname].hq = 0
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
        local pool =1 --使用的奖池
        if free==1 then
        	 mUseractive.info[self.aname].v=1
        else
	 		if num ==1 then
	            gems = activeCfg.cost1
	        else
	            num = 5
	            gems = activeCfg.cost2
	            pool=2
	        end
        end

        if not mUseractive.info[self.aname].l then
        	mUseractive.info[self.aname].l=0
        end

        local reward={}
        local report={}
        for i=1,num do
        	local result,rewardkey
        	-- 幸运值达到指定值 需要重置 且使用新的奖池
        	if mUseractive.info[self.aname].l>=activeCfg.luckyNeed then
        		mUseractive.info[self.aname].l=0
        		result,rewardkey = getRewardByPool(activeCfg.serverreward['luckyPool'],1)
        	else
	 		    result,rewardkey = getRewardByPool(activeCfg.serverreward['pool'..pool],1)
	            
	 			for idx=1,#rewardkey do
	            	local luck=0
	                luck = activeCfg.serverreward['pool'..pool].lucky[rewardkey[idx]]
	                if luck==0 then
	                	mUseractive.info[self.aname].l=0
	                else
	                	mUseractive.info[self.aname].l=(mUseractive.info[self.aname].l or 0)+luck
	                end
	               
	            end	            
        	end
            for k,v in pairs (result) do
                for rk,rv in pairs(v) do
                    reward[rk]=(reward[rk] or 0)+rv
                end
            end            
        end

        if not takeReward(uid,reward) then    
            response.ret=-403
            return response
        end


        -- 相同的奖励在记录时需要合并
        for k,v in pairs(reward) do
            table.insert(report, formatReward({[k]=v}))
        end

        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end

        if gems>0 then
            regActionLogs(uid,1,{action=247,item="",value=gems,params={num=num}})
        end   

        local clientReport= copyTable(report)

        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','chaowuplan',num)
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
            if type (data)~="table" then data={}  end
            
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
            response.data[self.aname].reward=clientReport
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

    -- 飞机技能分解  品质,1.白 2.绿 3.蓝 4.紫 5.橙
    -- 积分按品质还是 按配置
    -- 功能分解  活动分解 返还是否同时生效
    function self.action_decompose(request)
 		local uid = request.uid
        local response = self.response
        --skills={"s1","s2"}
        local skills = request.params.s --要分解的技能
   		if type(skills)~='table' or not next(skills) then
       	   response.ret=-102
       	   return response
        end
  
        local ts= getClientTs()
        local weeTs = getWeeTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive','plane'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mBag = uobjs.getModel('bag')
        local mPlane = uobjs.getModel('plane')

  		local activeCfg = mUseractive.getActiveConfig(self.aname)
  		local decompose=activeCfg.serverreward.decompose
        local num = #skills
        
        -- 分解数量限制
        if num>decompose.maxLimit or num==0 then
           response.ret=-102
       	   return response
        end

        -- 每日限制获取高级原件的次数
        local weeTs = getWeeTs()
        if mUseractive.info[self.aname].t ~= weeTs then
            mUseractive.info[self.aname].hq = 0
            mUseractive.info[self.aname].t = weeTs
            mUseractive.info[self.aname].v = 0
        end

        --执行分解
        local ret={}
        local score=0
        for k,v in pairs(skills) do
            local sid = v
            local n = 1
            local scfg = getConfig('planeGrowCfg.grow.'.. sid)
            if not scfg then
                return false, -102
            end
            -- 白色的不能分解
            if scfg.color==1 then
                response.ret = -102
                return response
            end


            if not mPlane.consumeSkill(sid, n) then
                return false, -12103
            end

            local items = copyTab(scfg.deCompose)
	        for key, val in pairs( items ) do
	        	local pn=0
	        	if table.contains(decompose.returnItem,key) then
 					setRandSeed()
                    local rate=rand(decompose.returnRate[1]*100,decompose.returnRate[2]*100)/100
                    pn=math.ceil(val*rate)
                else
                	pn=val
	        	end
	        	
	            ret["props_"..key] = (ret["props_"..key] or 0) + pn
	            if not mBag.add(key, pn) then
	                response.ret=-403
       	    		return response
	            end
	        end
        
            --  技能分解评分
	        if decompose.sequipList[v] then
	        	score=score+decompose.sequipList[v]
	        end
            activity_setopt(uid,'fjjnbhjh',{act='dec',color=scfg.color,num=n})
        end

        local extraReward={}
        --超级装备分值（计算公式：(总分值/(总分值+2400))^2）
        if type(decompose.extraItem)=='table' and next(decompose.extraItem) then
	        if (mUseractive.info[self.aname].hq or 0)<decompose.getLimit then
	        	local hqrate=(math.pow(score/(score+2400),2))*100
	        	setRandSeed()
	        	local rdrate=rand(1,100)
                
	        	if rdrate<=hqrate then
					if not takeReward(uid,decompose.extraItem) then
						response.ret=-403
			            return response
			        end
			        mUseractive.info[self.aname].hq=(mUseractive.info[self.aname].hq or 0)+1
			        response.data.extraReward=formatReward(decompose.extraItem)
	        	end
	        end
        end

        -- 客户端
        local clientReward={}
		for k,v in pairs(ret) do
	        table.insert(clientReward, formatReward({[k]=v}))
	    end

	    if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.plane  = mPlane.toArray(true)
            response.ret = 0
            response.msg = 'Success'
            response.data.reward=clientReward
        else
            response.ret=-106
        end

        return response
    end

     -- 刷新 初始化
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        local flag = false
        -- 可领取次数和已领取次数记录
        if type(mUseractive.info[self.aname].task) ~='table' then
            flag = true
            mUseractive.info[self.aname].task = {}        
            for k,v in pairs(activeCfg.serverreward.taskList) do
                table.insert(mUseractive.info[self.aname].task,{0,0})--当前完成数量  领取次数
            end
        end
    
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

    -- 领取任务奖励
    function self.action_treward(request)
        local response=self.response
        local uid=request.uid
        local tid=request.params.tid

        if not tid or not uid then
            response.ret=-102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local taskCfg = copyTable(activeCfg.serverreward.taskList[tid])
        if type(taskCfg)~='table' then
            response.ret = -102
            return response
        end

        -- 未完成
        if mUseractive.info[self.aname].task[tid][1]<taskCfg.num then
            response.ret=-1981
            return response
        end
        -- 已领取
        if mUseractive.info[self.aname].task[tid][2]>0 then
            response.ret=-1976
            return response
        end
      
        --配置判断
        if type(taskCfg.serverreward)~='table' or not next(taskCfg.serverreward) then
            response.ret=-102
            return response
        end 

        if not takeReward(uid,taskCfg.serverreward) then
            response.ret=-403
            return response
        end

        mUseractive.info[self.aname].task[tid][2] = 1
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward=formatReward(taskCfg.serverreward)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    return self
end

return api_active_fjjnbhjh


