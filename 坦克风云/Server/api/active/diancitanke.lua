-- 电磁坦克活动
-- action 1 抽奖 ， 2 改造

function api_active_diancitanke(request)
    local aname = 'diancitanke'

    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid
    local action = request.params.action or 0
    local tid = request.params.tid or 1
    local mul = request.params.mul or false
    local free = request.params.free or false

    if uid == nil or action == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","troops","bag",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local activeCfg = getConfig("active."..aname.."."..mUseractive.info[aname].cfg)
    local harCReward={}--和谐版返回奖励
    if action == 1 then
		local weelTs = getWeeTs()
		local costGems = nil -- 消费金币
		local valRange = 0 -- 分值范围索引

		if free then
			if (mUseractive.info[aname].t < weelTs and mul) then
				response.ret = -102
				return response
			end
			
			if mUseractive.info[aname].t < weelTs then
				mUseractive.info[aname].t = weelTs
			else
				response.ret = -2032
				response.data[aname] = mUseractive.info[aname]
				return response
			end
			
			valRange = 1
			costGems = 0
		elseif tid >= 1 and tid <= 3 then
			valRange = tid
			costGems = activeCfg.cost[tid] 
			if mul then
				costGems = costGems * activeCfg.mulc
			end
		else
			response.ret = -102
			return response
		end
		
		-- 扣钱
		if not costGems then
			response.ret = -102
			return response
		end
		
		if not free and costGems <= 0 then
			response.ret = -102
			return response
		end
		
		if not mUserinfo.useGem(costGems) then
			response.ret = -109
			return response
		end
		
		setRandSeed()
        local addVal = rand(activeCfg.addval[valRange][1],activeCfg.addval[valRange][2])
		
		if not mUseractive.info[aname].n or type(mUseractive.info[aname].n) ~= 'number' then
			mUseractive.info[aname].n = 0
		end
		
        -- 超过最大能量， 衰减优化
        if mUseractive.info[aname].n >= activeCfg.maxval then
            local rate = rand(1, 1000)
            if rate > (activeCfg.rate * 1000) then
                addVal = rand(mUseractive.info[aname].n/2, activeCfg.maxval)
            else
                addVal = rand(1, mUseractive.info[aname].n/2)
            end

            addVal = math.ceil(addVal)
        end

        mUseractive.info[aname].n = math.ceil(mUseractive.info[aname].n * activeCfg.decay[tid]) + addVal

		if mUseractive.info[aname].n < 0 then
			mUseractive.info[aname].n = 0
		end
		
		local rewardIndex = 0
		local maxIndex = #activeCfg.range or 0
		for i=1,maxIndex do
			if mUseractive.info[aname].n >= activeCfg.range[i] then
				rewardIndex = i
			end
		end
		
		if rewardIndex == 0 then
			response.ret = -102
			return response
		end
		
		local reward = {}
		for i,v in pairs(activeCfg.serverreward[rewardIndex]) do
			reward[i] = v
			if mul then
				reward[i] = reward[i] * activeCfg.mul
			end
		end
		
		-- mUseractive.info[aname].nlog = json.encode(reward)
		if not takeReward(uid,reward) then
			return response
		end
        
		regActionLogs(uid,1,{action=81,item="",value=costGems,params={tid=tid,mul=mul,free=free,n=mUseractive.info[aname].n,rewardIndex=rewardIndex}})
        -- 和谐版活动
        if moduleIsEnabled('harmonyversion') ==1 then
            local rewnum=tid
            if mul then
                rewnum=rewnum*20
            end
            local hReward,hClientReward = harVerGifts('active','diancitanke', rewnum)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward=hClientReward
        end        
		
    elseif action == 2 then
        local aid = request.params.aid
        local nums = tonumber(request.params.num) or 0
        local cfg = activeCfg.consume[aid]
        if nums <= 0 or not cfg then
            response.ret = -102
            return response
        end

        -- 刷新队列
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
        if cfg.upgradeMetalConsume~=nil then
            bRes.r1 = nums * cfg.upgradeMetalConsume
        end
        if cfg.upgradeOilConsume~=nil then
            bRes.r2 = nums * cfg.upgradeOilConsume
        end
        if cfg.upgradeSiliconConsume~=nil then
            bRes.r3 = nums * cfg.upgradeSiliconConsume
        end
        if cfg.upgradeUraniumConsume~=nil then
            bRes.r4 = nums * cfg.upgradeUraniumConsume
        end
        if cfg.upgradeMoneyConsume~=nil then
            bRes.gold = nums * cfg.upgradeMoneyConsume
        end
        
        if cfg.upgradeGemConsume~=nil then
            local costGems = nums * cfg.upgradeGemConsume
            if  not mUserinfo.useGem(costGems) then
                response.ret = -109
                return response
            end
            regActionLogs(uid,1,{action=81,item="",value=costGems,params={buyNum=aid,hasNum=nums}})
        end

        if not mUserinfo.useResource(bRes) then
            response.ret = -107
            return response
        end
		
        local TransShipConsume = cfg.TransShipConsume
        local addaid = TransShipConsume[1]
        local addnums = TransShipConsume[2]*nums
        local ret=mTroop.incrTanks(addaid,addnums)
        if not ret then
            return response
        end
		
		response.data.userinfo = mUserinfo.toArray(true)
		response.data.troops = mTroop.toArray(true)
        
    end

	processEventsBeforeSave()

	if uobjs.save() then
		processEventsAfterSave()

		response.data[aname] = mUseractive.info[aname]
        if next(harCReward) then
            response.data[aname].hReward=harCReward
        end
		response.ret = 0
		response.msg = 'Success'
	else
		response.ret = -1
		response.msg = 'save failed'
	end
		
    return response
end