--
-- desc: 武器研发
-- user: chenyunhe
--
local function api_active_wqyf(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'wqyf',
    }

    --  随机奖励
    function self.action_lottery(request)
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num)
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
	            gems = activeCfg.cost2
	        end
        end
        -- 抽奖次数
        if not mUseractive.info[self.aname].n then
        	mUseractive.info[self.aname].n=0
        end

        local function getpool(free,activeCfg,n,cl,vip)
        	local pool = 0
        	local first =  false
        	-- 首次付费抽奖
        	if free == 0 and cl==0 then
        		local len = #activeCfg.serverreward.viplevel --这个值越大 玩家使用的奖池越low
        		local lvindex = len
        		for i=len,1,-1 do
	        		if vip>=activeCfg.serverreward.viplevel[i] then
	        			lvindex = i
	        			break
	        		end
	        	end

	        	first =  true
        		return activeCfg.serverreward.matchpool[lvindex],first
        	end

        	for i=#activeCfg.serverreward.levelPool,1,-1 do
        		if n>=activeCfg.serverreward.levelPool[i] then
        			pool = i
        			break
        		end
        	end

        	return pool,first
        end

        local reward = {}
        local report = {}
        local spreward = {}
        local clientReward = {} --里面的奖励不合并

        for i=1,num do
        	local matchpool,firstflag = getpool(free,activeCfg, mUseractive.info[self.aname].n,mUseractive.info[self.aname].cl,mUserinfo.vip)
        	local result,rewardkey = getRewardByPool(activeCfg.serverreward['pool'..matchpool],1)

			mUseractive.info[self.aname].n = mUseractive.info[self.aname].n+1
			if firstflag then
				mUseractive.info[self.aname].cl = 1
			end

            local flag = false
            for k,v in pairs(result) do
                 for rk,rv in pairs(v) do
                 	if table.contains(activeCfg.serverreward.specialItem,rk) then
                 		mUseractive.info[self.aname].n = 0
                 		mUseractive.info[self.aname].cl = 0
                 	end
                 	if string.find(rk,'wqyf') then
                 		local rkeys = rk:split('_')
                 		spreward[rkeys[2]] = (spreward[rkeys[2]] or 0) + rv
                 	    table.insert(clientReward,self.formatreward({[rkeys[2]]=rv}))
                 	else
                 		reward[rk]=(reward[rk] or 0)+rv
                 		table.insert(clientReward,formatReward({[rk]=rv}))
                 	end
                end
            end
        end


        for k,v in pairs(reward) do
            table.insert(report, formatReward({[k]=v}))
        end

        if not takeReward(uid,reward) then    
            response.ret=-403
            return response
        end

        local fixedkey = activeCfg.serverreward.extrareward[1]:split('_')
        spreward[fixedkey[2]] = (spreward[fixedkey[2]] or 0)+activeCfg.serverreward.extrareward[2]*num
        if type(spreward)=='table' and next(spreward) then
        	for k,v in pairs(spreward) do
        		table.insert(report,self.formatreward({[k]=v}))
        		mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v --增加特殊道具
        	end
        end

        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end

        if gems>0 then
            regActionLogs(uid,1,{action = 179, item = "", value = gems, params = {num = num}})
        end

        if uobjs.save() then
 			local redis =getRedis()
            local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={} end

            table.insert(data,1,{ts,report,num})
            if next(data) then
                for i=#data,11,-1 do
                    table.remove(data)
                end

                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[self.aname].et+86400)
            end
            response.data[self.aname] =mUseractive.info[self.aname]
            --response.data[self.aname].reward = report
            response.data[self.aname].reward = clientReward

            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    function self.formatreward(rewards)
		local formatreward = {}
		local key = 'wqyf'
	   	formatreward[key] = {}
	    if type(rewards) == 'table' then
	        for k,v in pairs(rewards) do
	            formatreward[key][k] = v
	        end
	    end
	    return formatreward
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

    -- 领取充值奖励
    function self.action_creward(request)
 		local uid = request.uid
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid then
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

        if mUseractive.info[self.aname].gn == nil then
        	mUseractive.info[self.aname].gn = 0
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local num = math.floor((mUseractive.info[self.aname].g-mUseractive.info[self.aname].gn*activeCfg.gems)/activeCfg.gems)
        if num<=0 then
        	response.ret = -102
        	return response
        end
       
        local reward = {} --常规奖励
        local spreward = {} -- 特定奖励
        for k,v in pairs(activeCfg.serverreward.chargereward) do
			if string.find(v[1],'wqyf') then
         		local vkeys = v[1]:split('_')
         		spreward[vkeys[2]] = (spreward[vkeys[2]] or 0) + v[2]*num
         	else
         		reward[v[1]]=(reward[v[1]] or 0)+v[2]*num
         	end
        end

        if not takeReward(uid,reward) then
        	response.ret = -403
        	return response
        end

        local report = {}
        if next(reward) then
        	for k,v in pairs(reward) do
        		table.insert(report, formatReward({[k]=v}))
        	end

        end

        if next(spreward) then
        	for k,v in pairs(spreward) do
        		table.insert(report,self.formatreward({[k]=v}))
        		mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
        	end
        end

        mUseractive.info[self.aname].gn = mUseractive.info[self.aname].gn + num
        if uobjs.save() then
        	response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report

            response.ret = 0
            response.msg = 'Success'
        else
        	response.ret = -106
        end

        return response
    end

    -- 兑换
    function self.action_exchange(request)
         local response = self.response
         local uid=request.uid
         local num=request.params.num or 1 --兑换个数

         local uobjs = getUserObjs(uid)
         uobjs.load({"userinfo",'useractive'})
         local mUseractive = uobjs.getModel('useractive')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        if  mUseractive.info[self.aname].cn ==nil then
        	mUseractive.info[self.aname].cn=0
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if mUseractive.info[self.aname].cn>=activeCfg.combinLimit then
        	response.ret = -30006 --兑换上限
        	return response
        end

        if mUseractive.info[self.aname].cn+num>activeCfg.combinLimit then
        	response.ret = -30006
        	return response
        end
        
        local nda1 = 1
        local ndb1 = 1
        for k,v in pairs(activeCfg.serverreward.combinNeed) do
        	if string.find(v[1],"wqyf_a1") then
        		nda1=v[2]
        	end
        	if string.find(v[1],"wqyf_b1") then
        		ndb1=v[2]
        	end
        end

        if mUseractive.info[self.aname].a1<num*nda1 or mUseractive.info[self.aname].b1<num*ndb1 then
        	response.ret = -1996
        	return response
        end

        local reward ={}
        reward[activeCfg.serverreward.pieces[1]] = activeCfg.serverreward.pieces[2]*num

        if not takeReward(uid,reward) then
        	response.ret =-403
        	return response
        end

        mUseractive.info[self.aname].a1 =  mUseractive.info[self.aname].a1-nda1*num
        mUseractive.info[self.aname].b1 =  mUseractive.info[self.aname].b1-ndb1*num

        mUseractive.info[self.aname].cn = mUseractive.info[self.aname].cn + num
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(reward)
            response.ret = 0
            response.msg = 'Success'
        else
          response.ret=-106
        end

        return response        
    end

    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local flag = false
        -- 物品a
        if mUseractive.info[self.aname].a1 == nil  then
            flag = true
            mUseractive.info[self.aname].a1 = 0
        end
        -- 物品b
        if mUseractive.info[self.aname].b1 == nil  then
            flag = true
            mUseractive.info[self.aname].b1 = 0
        end
        -- 抽奖次数
        if mUseractive.info[self.aname].n == nil  then
            flag = true
            mUseractive.info[self.aname].n = 0
        end
         -- 累计充值钻石
        if mUseractive.info[self.aname].g == nil  then
            flag = true
            mUseractive.info[self.aname].g = 0  --总钻石
            mUseractive.info[self.aname].gn = 0 -- 领取次数
        end

        -- 已经兑换的数量
        if mUseractive.info[self.aname].cn == nil  then
        	flag = true
        	mUseractive.info[self.aname].cn = 0  --已合成数量
        end
        -- 首次付费抽奖
        if mUseractive.info[self.aname].cl == nil  then
        	flag = true
        	mUseractive.info[self.aname].cl = 0  --已合成数量
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


    return self
end

return api_active_wqyf
