--
-- desc: 战舰梦工厂
-- user: chenyunhe
-- date: 2017-10-18
--
local function api_active_zjmgc(request)
	local self = {
		response = {
			ret = -1,
			msg = 'error',
			data = {}
		},
		aname = 'zjmgc',
	}

	-- 刷新
	function self.action_refresh(request)
		local uid = request.uid
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid then
            response.ret =-102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo =  uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
    
        local flag = false
        if not mUseractive.info[self.aname].times or mUseractive.info[self.aname].times==0 then
        	flag = true
        	mUseractive.info[self.aname].times = self.settimes(mUseractive)
        end

        if not mUseractive.info[self.aname].p then
        	flag = true
        	mUseractive.info[self.aname].p = 0
        end

        if flag then
        	uobjs.save()
        end

        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'success'

        return response
	end

	-- 获得每次抽奖 奖励的倍数
	function self.settimes(actobj)
		local activeCfg  = actobj.getActiveConfig(self.aname)
        local index = randVal(activeCfg.extraGet[2])
        return activeCfg.extraGet[1][index]
	end

	-- 激活船体
	function self.action_lottery(request)
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

		if  mUseractive.info[self.aname].t ~= weeTs then
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

		if not mUseractive.info[self.aname].times or mUseractive.info[self.aname].times==0 then
			response.ret = -102
			return response
        end

        local times = mUseractive.info[self.aname].times
		local reward = {}
		local report = {}
		local power = 0 -- 本次抽奖获得能量值
		local getship = false
		setRandSeed()
		for i = 1, num do
			local result,rkey = getRewardByPool(activeCfg.serverreward['pool'], 1)
			for k, v in pairs(result) do
				for rk , rv in pairs(v) do
					reward[rk]    = (reward[rk] or 0) + rv*times
				end
			end

			local eindex = rkey[1]
			local energy = activeCfg.serverreward.pool.energy[eindex]
            local rd=rand(energy[1],energy[2])
			power =  power + rd*times	
		end
		mUseractive.info[self.aname].p = mUseractive.info[self.aname].p + power  

		-- 每次抽奖都要重新设置倍数
		mUseractive.info[self.aname].times  = self.settimes(mUseractive)
		-- 判断当前能量是否已满 获取大奖
		if mUseractive.info[self.aname].p >= activeCfg.scoreNeed then
			for k,v in pairs(activeCfg.getship) do
				reward[k] = (reward[k] or 0) + v
			end

			-- 剩余的能量值 要计入下一轮
			mUseractive.info[self.aname].p = mUseractive.info[self.aname].p - activeCfg.scoreNeed
			getship = true
		end

		if not next(reward) then
			response.ret = -1
			return response
		end

		if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end

		for k, v in pairs(reward) do
			table.insert(report, formatReward({[k] = v}))	
		end

		if  not mUserinfo.useGem(gems) then
			response.ret = -109
			return response
		end

		if gems > 0 then
			regActionLogs(uid, 1, {action = 188, item = "", value = gems, params = {num = num}})
		end

		local harCReward = {}
		if  moduleIsEnabled('harmonyversion') == 1 then
		    local hReward,hClientReward = harVerGifts('active','zjmgc',num)
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
            response.data.reward = report 
            response.data.power = power 
            response.data.getship =  getship
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

	-- 舰船改造
	function self.action_shipremake(request)
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
return api_active_zjmgc
