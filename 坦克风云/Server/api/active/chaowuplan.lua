--desc:超武捕获计划
--user:chenyunhe
local function api_active_chaowuplan(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'chaowuplan',
    }
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
        regActionLogs(uid,1,{action=165,item="",value=gems,params={num=num}})

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

    -- 超级装备分解
    function self.action_decompose(request)
 		local uid = request.uid
        local response = self.response
        -- eq={"e1","e2","e1","e3"}
        local equip = request.params.eq --要分解的装备
   		if not uid or type(equip)~='table' or not equip then
       	   response.ret=-102
       	   return response
        end
  
        local ts= getClientTs()
        local weeTs = getWeeTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mSequip = uobjs.getModel('sequip')
        local mBag = uobjs.getModel('bag')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

  		local activeCfg = mUseractive.getActiveConfig(self.aname)
  		local decompose=activeCfg.serverreward.decompose
        -- 分解数量超出上限
        if #equip>decompose.maxLimit then
           response.ret=-102
       	   return response
        end

        -- 每日限制获取高级原件的次数
        local weeTs = getWeeTs()
        if mUseractive.info[self.aname].t < weeTs then
            mUseractive.info[self.aname].hq = 0
            mUseractive.info[self.aname].t = weeTs
        end

        --执行分解
        local equipcfg = getConfig('superEquipListCfg.equipListCfg')
        local ret={}
        local score=0
        for k,v in pairs(equip) do
	        local eqcfg=equipcfg[v]
	        if not eqcfg then
	            response.ret=-17005--该武器不存在
       	    	return response
	        end

	        if eqcfg.color==1 then
				response.ret=-9018--分解品质有误
       	    	return response
	        end

			if not mSequip.consumeEquip(v, 1) then
                writeLog({'sequip decompose consumeEquip ... ', id=v,u=uid}, 'error')
	            response.ret=-1911
       	    	return response
	        end

	        local items = copyTab(eqcfg.deCompose)
	        for key, val in pairs( items ) do
	        	local num=0
	        	if table.contains(decompose.returnItem,key) then
 					setRandSeed()
                    local rate=rand(decompose.returnRate[1]*100,decompose.returnRate[2]*100)/100
                    num=math.ceil(val*rate)
                else
                	num=val
	        	end
	        	
	            ret["props_"..key] = (ret["props_"..key] or 0) + num
	            if not mBag.add(key, num) then
	                response.ret=-403
       	    		return response
	            end
	        end
            --  超级装备的分值
	        if decompose.sequipList[v] then
	        	score=score+decompose.sequipList[v]
	        end
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
            response.sequip=mSequip.toArray(true)
            response.ret = 0
            response.msg = 'Success'
            response.data.reward=clientReward
        else
            response.ret=-106
        end

        return response
    end

    return self
end

return api_active_chaowuplan