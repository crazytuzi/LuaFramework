--desc: 啤酒节
--user:chenyunhe
local function api_active_beerfestival(request)
	local self={
	    response={
	       ret=-1,
	       msg='error',
           data={},
		},
		aname="beerfestival",
    }

    -- 获取酒花和麦芽的数据（t1、t2）
    -- 每个阶段领取状态
    -- 大奖领取状态
    function self.action_cupinfo(request)
 	    local uid = request.uid
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid then
        	response.ret =-102
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

		local activeCfg = mUseractive.getActiveConfig(self.aname)
        --获取玩家贡献值
        local contribute=getFreeData(self.aname..mUseractive.info[self.aname].st)

		local t1 =  0 --酒花
        local t2 =  0 --麦芽
    	if type(contribute)=='table' then
        	 t1 = contribute.info.t1  --酒花
             t2 = contribute.info.t2  --麦芽
        end        

        local flag = false
        if type(mUseractive.info[self.aname].beer)~='table' then
        	flag = true
        	mUseractive.info[self.aname].beer={}--初始化
        	--每层领取状态 层数默认为下标
        	for i=1,#activeCfg.stages do
        		table.insert(mUseractive.info[self.aname].beer,{0,0})
        	end
        	mUseractive.info[self.aname].t1 = 0 -- 酒花
        	mUseractive.info[self.aname].t2 = 0 -- 麦芽
        	mUseractive.info[self.aname].f = 0 -- 最终大奖领取状态  0未领取 1已领取
        	mUseractive.info[self.aname].fb = 0 -- facebook分享
        end

        if flag then
			if not uobjs.save() then
				response.ret =-1
				return response
			end
        end

        response.data[self.aname] =mUseractive.info[self.aname]
        response.data[self.aname].allt1 = t1
        response.data[self.aname].allt2 = t2
        response.ret = 0
	    response.msg = 'Success'

        return response

    end

    -- 贡献材料
    function self.action_contribute(request)
    	local uid = request.uid
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()
        local item = request.params.item -- 1酒花 2麦芽
        local num = request.params.num or 0 --贡献的数量

        if not uid or not table.contains({1,2},item) or num<=0 then
        	response.ret =-102
        	return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive','accessory','bag'})
        local mUseractive = uobjs.getModel('useractive')
        local mAccessory = uobjs.getModel('accessory')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
  
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 验证
        if mUseractive.info[self.aname]['t'..item]<num then
        	response.ret = -1996
        	return response
        end

        local reward = {}
		for i=1,num do
        	local result,rewardkey
 		    result,rewardkey = getRewardByPool(activeCfg.serverreward['pool'..item],1)
			for k,v in pairs(result) do
                for rk,rv in pairs(v) do
                    reward[rk]=(reward[rk] or 0)+rv
                end
            end
        end

        local clientReward = {}
		for k,v in pairs(reward) do
        	table.insert(clientReward, formatReward({[k] = v}))	
        end

        if not takeReward(uid,reward) then
        	response.ret = -403
        	return response
        end
    
        mUseractive.info[self.aname]['t'..item] = mUseractive.info[self.aname]['t'..item]-num

        local t1 = 0
        local t2 = 0
  		local contribute=getFreeData(self.aname..mUseractive.info[self.aname].st)

		if type(contribute)=='table' then
        	t1 = tonumber(contribute.info.t1)
        	t2 = tonumber(contribute.info.t2)
        end

        if item==1 then
        	t1 = t1 + num
        else
        	t2 = t2 + num
        end

		if not setFreeData(self.aname..mUseractive.info[self.aname].st, {t1=t1,t2=t2}) then
        	 response.ret=-106
             return response
        end        

        if uobjs.save() then
        	 response.data[self.aname] = mUseractive.info[self.aname]
        	 response.data.accessory = mAccessory.toArray(true)
        	 response.data.reward = clientReward
        	 response.data[self.aname].allt1 = t1
        	 response.data[self.aname].allt2 = t2
 			 response.ret = 0
             response.msg = 'Success'        	 
        else
        	response.ret =-106
        end

        return response
    end

    -- 获取充值礼包
    function self.action_getChargeReward(request)
    	local uid = request.uid
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid then
        	response.ret =-102
        	return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        --  可领取礼包个数验证
        if not mUseractive.info[self.aname].gems then
        	response.ret = -102
        	return response
        end
        local rn = mUseractive.info[self.aname].rn or 0 --已领取的个数
        local num = math.floor((mUseractive.info[self.aname].gems-rn*activeCfg.cost)/activeCfg.cost)
        if num<=0 then
        	response.ret = -102
        	return response
        end

        local rewardCfg = activeCfg.serverreward.dayreward
        if type(rewardCfg)~='table' then
        	response.ret = -102
        	return response
        end

        local reward = {}
        local resource = {}
        local clientReward = {}
        for k,v in pairs(rewardCfg) do
        	-- 酒花和麦芽是活动道具 特殊处理
        	if table.contains({'t1','t2'},k) then
        		resource[k] = (resource[k] or 0) + v*num
        		table.insert(clientReward, self.formatreward({[k] = v*num}))	
        	else
        		reward[k] = (reward[k] or 0) + v*num
        		table.insert(clientReward, formatReward({[k] = v*num}))	
        	end
        end
     
        if not takeReward(uid,reward) then
        	response.ret = -403
        	return response
        end

        -- 记录次数和更新材料数据
        mUseractive.info[self.aname].rn = (mUseractive.info[self.aname].rn or 0) + num
        if next(resource) then
        	for k,v in pairs(resource) do
        		mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k]  or 0) + v
        	end

        end

        if uobjs.save()  then
        	 response.data[self.aname] =mUseractive.info[self.aname]
        	 response.data.reward = clientReward
        	 response.ret = 0
             response.msg = 'Success'  
        else
        	response.ret =-106
        end

        return response
    end

    function self.formatreward(rewards)
		local formatreward = {}
		local key = 'beer'
	   	formatreward[key] = {}
	    if type(rewards) == 'table' then
	        for k,v in pairs(rewards) do
	            formatreward[key][k] = v
	        end
	    end
	    return formatreward
	end    

    --领取每阶段的酒花or麦芽奖励
    function self.action_stagereward(request)
		local uid = request.uid
        local response = self.response
        local stage = request.params.stage --领取奖励的层数
        local item = request.params.item -- 1 领取的是酒花奖励 2 领取的是麦芽奖励
        local ts = getClientTs()
        local weeTs = getWeeTs()

        if not uid or not table.contains({1,2},item) or stage<=0 then
        	response.ret = -102
        	return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        if type(mUseractive.info[self.aname].beer)~='table' then
        	response.ret = -102
        	return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local contribute=getFreeData(self.aname..mUseractive.info[self.aname].st)
        if type(contribute)~='table' or stage>#activeCfg.stages then
        	response.ret = -102
        	return response
        end

        local t1 = 0
        local t2 = 0
        local contri = 0
        if item == 1 then
        	contri = contribute.info.t1
        else
        	contri = contribute.info.t2
        end
         t1 = contribute.info.t1
         t2 = contribute.info.t2

        -- 判断是否已经领取过 
        if mUseractive.info[self.aname].beer[stage][item]==1 then
        	response.ret = -1976
        	return response
        end

        -- 贡献值有没有达到
        if contri<activeCfg.stages[stage] then
        	response.ret = -1981
        	return response
        end

        local rewardCfg=activeCfg.serverreward['t'..item][stage]
        local clientReward = {}
        if not next(rewardCfg) then
        	response.ret = -102
        	return response
        else
        	for k,v in pairs(rewardCfg) do
        		table.insert(clientReward, formatReward({[k] = v}))	
        	end
        end

        if not takeReward(uid,rewardCfg) then
        	response.ret=-403
        	return response
        end
        --修改状态
        mUseractive.info[self.aname].beer[stage][item]=1
		if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data.reward = clientReward
            response.data[self.aname].allt1 = t1
        	response.data[self.aname].allt2 = t2  
            response.ret = 0
            response.msg = 'Success'

	    else
	        response.ret=-106
	    end	

	    return response
	 end

    -- 获取最终的大奖
    function self.action_finalgift(request)
		local uid = request.uid
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid then
        	response.ret = -102
        	return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 已经领取过
        if mUseractive.info[self.aname].f==1 then
        	response.ret=-1976
        	return response
        end

        local t1 = 0
        local t2 =0
        local contribute=getFreeData(self.aname..mUseractive.info[self.aname].st)
        if type(contribute)~='table'  then
        	response.ret =  -1981
        	return response
        else
			t1 = tonumber(contribute.info.t1)
        	t2 = tonumber(contribute.info.t2)        	
        end    
        --判断领取条件
        local maxindex = #activeCfg.stages
        if t1<activeCfg.stages[maxindex] or t2<activeCfg.stages[maxindex] then
        	response.ret = -1981
        	return response
        end

        local clientReward = {}
   		local reward=activeCfg.serverreward.final
        if not takeReward(uid,reward) then
        	response.ret=-403
        	return response
        end

		for k,v in pairs(reward) do
        	table.insert(clientReward, formatReward({[k] = v}))	
        end        

        -- 修改状态
        mUseractive.info[self.aname].f = 1 
		if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data.reward = clientReward
			response.data[self.aname].allt1 = t1
        	response.data[self.aname].allt2 = t2            
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    -- facebook分享奖励
    function self.action_fbreward(request)
		local uid = request.uid
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid then
        	response.ret = -102
        	return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 已经领取过
        if mUseractive.info[self.aname].fb==1 then
        	response.ret=-1976
        	return response
        end

        local rewardCfg = activeCfg.serverreward.fbreward
        

        -- 酒花和麦芽是活动道具 特殊处理
        local clientReward = {}
        local resource = {}
        local reward = {}
	for k,v in pairs(rewardCfg) do
            if table.contains({'t1','t2'},k) then
                resource[k] = (resource[k] or 0) + v
                table.insert(clientReward, self.formatreward({[k] = v}))
            else
                reward[k]=(reward[k] or 0)+v
                table.insert(clientReward, formatReward({[k] = v}))
            end
        end

        if not takeReward(uid,reward) then
        	response.ret = -403
        	return response
        end 

        if next(resource) then
            for k,v in pairs(resource) do
                mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k]  or 0) + v
            end
        end
        -- 修改状态
        mUseractive.info[self.aname].fb = 1 
		if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data.reward = clientReward
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    --facebook分享地址 https://www.facebook.com/Flotten-Kommando-Community-681743588593889
    function self.action_fbURL(request)
		local uid = request.uid
        local response = self.response
        local zoneid = request.zoneid
        local lang = request.lang
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid or not zoneid then
        	response.ret = -102
        	return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

	    local url = nil
        local urlkey = "facebookshareurl"
        local freedata = getFreeData(urlkey)
        if freedata then
            url = freedata.info[lang] or nil
        end

	    response.data.fb = mUseractive.info[self.aname].fb
	    response.data.url =  url
	    response.ret = 0
	    response.msg = 'Success'

	    return response
    end

    return self
end

return api_active_beerfestival
