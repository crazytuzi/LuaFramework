--船坞监工
--date 2017-8-3
local function api_active_docksupervisor(request)
	local self = {
		response = {
			ret = -1,
			msg = 'error',
			data = {}
		},
		aname = 'docksupervisor',
		formatreward = function (rewards)
			local formatreward = {}
		   	local key = 'dsv'
		   	formatreward[key] = {}
		    if type(rewards) == 'table' then
		        for reward,num in pairs(rewards) do
		            formatreward[key][reward] = num
		        end
		    end
		    return formatreward
		end
	}

	--抽奖
	function self.action_drawreward(request)
		local response = self.response

		local uid   = tonumber(request.uid) or 0
		local num   = tonumber(request.params.num)
		local free  = tonumber(request.params.free)
		if not table.contains({0, 1}, free) or not table.contains({1, 10}, num) then
			response.ret = -102
			return response
		end

		local ts    = getClientTs()
		local weeTs = getWeeTs()

		local uobjs = getUserObjs(uid)
		uobjs.load({"userinfo", "useractive"})
		local mUseractive    = uobjs.getModel('useractive')
		local mUserinfo      = uobjs.getModel('userinfo')

		local activeStatus = mUseractive.getActiveStatus(self.aname)
		if  activeStatus ~= 1 then
			response.ret = -1977
			return response
		end

		if  free == 1 and num > 1 then
			response.ret = -102
			return response
		end

		if  mUseractive.info[self.aname].t < weeTs then
			mUseractive.info[self.aname].v = 0
			mUseractive.info[self.aname].t = weeTs
		end

        if mUseractive.info[self.aname].v == 1 and free == 1 then
            response.ret = -102
            return response
        end

		if  mUseractive.info[self.aname].v == 0 and free ~= 1 then
			response.ret = -102
			return response
		end

		local activeCfg  = mUseractive.getActiveConfig(self.aname)
		local gems = 0

		if free == 1 then
			mUseractive.info[self.aname].v = 1
		else
			if  num  == 1 then
				gems = activeCfg.cost1
			else 
				gems = activeCfg.cost2
			end
		end

		if not mUseractive.info[self.aname].r then
			mUseractive.info[self.aname].r = {}
		end

		local reward    = {}
		local report    = {}
		local allreward = {}

		for i = 1, num do
			local result
			result = getRewardByPool(activeCfg.serverreward['pool'], 1)

			for k, v in pairs(result) do
				for rk , rv in pairs(v) do
					reward[rk]    = (reward[rk] or 0) + rv
				end
			end
		end

		--todo 将奖励放到活动数据中
		for k, v in pairs(reward) do
			if string.find(k, 't_t') then
				mUseractive.info[self.aname].r[k] = (mUseractive.info[self.aname].r[k] or 0) + v
				table.insert(report, self.formatreward({[k] = v}))
				table.insert(allreward, self.formatreward({[k] = v}))
			else
				local rw = {}
				rw[k] = v
				if not takeReward(uid, rw) then
                                     response.ret = -403
                                     return response
                                end
				table.insert(report, formatReward({[k] = v}))
				table.insert(allreward, formatReward({[k] = v}))	
			end
		end

		if  not mUserinfo.useGem(gems) then
			response.ret = -109
			return response
		end

		if gems > 0 then
			regActionLogs(uid, 1, {action = 174, item = "", value = gems, params = {num = num}})
		end

		local harCReward = {}
		if  moduleIsEnabled('harmonyversion') == 1 then
		    local hReward,hClientReward = harVerGifts('active','docksupervisor',num)
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
            response.data.reward=allreward --reward
            --response.data[self.aname].combinItem = activeCfg.combinItem
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
	end

	--购买碎片
	function self.action_buyfragment(request)
		local response = self.response

	 	local uid        = tonumber(request.uid)
	 	local fragmentid = request.params.fragmentid
	 	local num        = tonumber(request.params.num) 
	 	if not uid or not fragmentid or not num then
	 		response.ret = -102
	 		return response
	 	end

		local ts    = getClientTs()
	 	local uobjs = getUserObjs(uid)
		uobjs.load({"userinfo", "useractive"})
		local mUseractive    = uobjs.getModel('useractive')
		local mUserinfo      = uobjs.getModel('userinfo')

		local activeStatus = mUseractive.getActiveStatus(self.aname)
		if  activeStatus ~= 1 then
			response.ret = -1977
			return response
		end
	
		local index = string.sub(fragmentid, string.len(fragmentid), -1)
		local activeCfg  = mUseractive.getActiveConfig(self.aname)
		local serverreward = activeCfg.combinItem.serverreward
		local bFlag = false
		for k,v in pairs(serverreward) do
			if fragmentid == v[1] then
				bFlag = true
				break
			end
		end

		if not bFlag then
			response.ret = -102
			return response
		end
		
		if not mUseractive.info[self.aname].r then
			mUseractive.info[self.aname].r = {}
		end

		local price = activeCfg.combinItem.cost[tonumber(index)]
		local gems = num * price

		if  not mUserinfo.useGem(gems) then
			response.ret = -109
			return response
		else
			mUseractive.info[self.aname].r[fragmentid] = (mUseractive.info[self.aname].r[fragmentid] or 0) + num
		end

		regActionLogs(uid, 1, {action = 175, item = "", value = gems, params = {num = num}})

		local report = {}
		table.insert(report, self.formatreward({[fragmentid] = num}))
		local buyInfo = report

	    if uobjs.save() then
	        response.data[self.aname] =mUseractive.info[self.aname]
	        response.data.buyinfo = buyInfo
	        response.ret = 0
	        response.msg = 'Success'
	    else
	        response.ret=-106
	    end

        return response
	end

	--获取抽奖记录
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

		local activeStatus = mUseractive.getActiveStatus(self.aname)
		if  activeStatus ~= 1 then
			response.ret = -1977
			return response
		end

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

	--合成舰船
	function self.action_composeship(request)
        local response = self.response
        local uid = request.uid
        if not uid then
		    response.ret = -102
		    return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"useractive"})
        local mUseractive = uobjs.getModel('useractive')

        local activeStatus = mUseractive.getActiveStatus(self.aname)
		if  activeStatus ~= 1 then
			response.ret = -1977
			return response
		end

        local activeCfg  = mUseractive.getActiveConfig(self.aname)
        local exchangeCfg = activeCfg.combinItem.serverreward
        local minCnt = 0
        for k, v in pairs(exchangeCfg) do
        	local cnt = (mUseractive.info[self.aname].r[v[1]] or 0) / v[2] 
    		if minCnt == 0 then
    			minCnt = cnt
    		else
    			if cnt < minCnt then
    				minCnt = cnt
    			end
    		end
        end 
        if minCnt <= 0 then
        	response.ret = -102
        	return response
        end

        for k, v in pairs(exchangeCfg) do
			mUseractive.info[self.aname].r[v[1]] = mUseractive.info[self.aname].r[v[1]] - (v[2] * minCnt)
        end
        
        local getShip = {}
        for k, v in pairs(activeCfg.getship) do
        	getShip[k] = v * minCnt
        end

        if not takeReward(uid, getShip) then
            response.ret = -102
            return response
        end

        local reward = {}
        table.insert(reward, formatReward(getShip))

        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = reward
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
	end

	--舰船改造
	function self.action_shipupgrade(request)
		local response = self.response
	    local uid = request.uid
	    local aid = request.params.aid
	    local num = request.params.num
        
        if not uid or not aid or not num then
		    response.ret = -102
		    return response
        end

	    local uobjs = getUserObjs(uid)
	    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
	    local mUseractive = uobjs.getModel('useractive')
	    local mUserinfo = uobjs.getModel('userinfo')
	    local mTroop = uobjs.getModel('troops')

	    local activeCfg  = mUseractive.getActiveConfig(self.aname)
        local nums = tonumber(num)
        local cfg = activeCfg.consume[aid]
        if nums <= 0 or not cfg then
            response.ret = -102
            return response
        end

        --刷新队列
        mTroop.upgradeupdate()

        local bTankConsume = cfg.upgradeShipConsume
        if next(bTankConsume) then
            -- 升级需要消耗的坦克数
            local iTanks = bTankConsume[2] * nums
            if not mTroop.troops[bTankConsume[1]]
            or iTanks > mTroop.troops[bTankConsume[1]]
            or not mTroop.consumeTanks(bTankConsume[1],iTanks) then
                response.ret = -115
                return response
            end
        end

        -- 改装需要的道具
        local bPropConsume = cfg.upgradePropConsume
        if type(bPropConsume) == 'table' and next(bPropConsume) then
            local mBag = uobjs.getModel('bag')

            for _,v in ipairs(bPropConsume) do
                local tmpNum = v[2] * nums
                if not mBag.use(v[1],tmpNum) then
                    response.ret = -1996
                    return response
                end
            end
            response.data.bag = mBag.toArray(true)
        end

        local bRes = {}
        bRes.r1 = nums * cfg.upgradeMetalConsume
        bRes.r2 = nums * cfg.upgradeOilConsume
        bRes.r3 = nums * cfg.upgradeSiliconConsume
        bRes.r4 = nums * cfg.upgradeUraniumConsume
        bRes.gold = nums * cfg.upgradeMoneyConsume

        if not mUserinfo.useResource(bRes) then
            response.ret = -107
            return response
        end

        mTroop.incrTanks(aid,nums)

        processEventsBeforeSave()

        if uobjs.save() then
            processEventsAfterSave()
            response.data.userinfo = mUserinfo.toArray(true)
            response.data.troops = mTroop.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -1
            response.msg = 'save failed'
        end

        return response
	end	

	------------------------------
	return self
end

-----------------------------------------------
return api_active_docksupervisor
