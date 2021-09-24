--
-- desc: 按部就班
-- user: chenyunhe
--
local function api_active_abjb(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'abjb',
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

    -- 抽奖
    function self.action_lottery(request)
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num)
        local free = tonumber(request.params.free) -- 0非免费 1免费
        local item = request.params.item or 1 -- 选择的船 1,2,3
        local ts= getClientTs()
        local weeTs = getWeeTs()
        if not item then
            response.ret = -102
            return response
        end
       
        if not table.contains({0,1},free) or not table.contains({1,10},num) or not uid then
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
             num = 1
        else
	 		if num ==1 then
	            gems = activeCfg.cost1[item]
	        else
	            num = 10
	            gems = activeCfg.cost2[item]
	        end
        end

        -- 每种船没有抽中次数，并提升抽中概率，抽中后清零
        for i=1,3 do
            if not mUseractive.info[self.aname]['s'..i] then
                mUseractive.info[self.aname]['s'..i] = 0 -- 每种船抽取次数
            end
        end

        setRandSeed()
        local rateCfg = copyTable(activeCfg['judgeRate'..item])-- 通过概率
        local addrate = activeCfg.addRate[item]
        local flag = false
        -- 通过随机逻辑  
        local function tongguo()
            local success = {}
            local fail = mUseractive.info[self.aname]['s'..item] 
            for n=1,4 do
                -- 如果本次没通过 则跳出 并结算奖
                local rd = rand(1,100)
                if rd<=(rateCfg[n] + fail*addrate)*100 then
                    table.insert(success,n)
                else
                    break
                end
            end

            
            if #success<4 then
                mUseractive.info[self.aname]['s'..item] = mUseractive.info[self.aname]['s'..item] + 1
            else
                mUseractive.info[self.aname]['s'..item] = 0
                flag = true
            end

            return success,flag
        end
        
        local sflag = 0 -- 是否全部通过
        local prize = activeCfg.serverreward.prize[item]
        local exlog = {}
        local reward = {}
        local report = {}
        for i=1,num do
            local suc,flag = tongguo()
    	    table.insert(exlog,suc)
            if next(suc) then
                for k,v in pairs(suc) do
                    for rk,rv in pairs(prize[k].serverreward) do
                        reward[rk] = (reward[rk] or 0) + rv
                    end
                end
            end

            for k,v in pairs(activeCfg.serverreward.failItem[item]) do
                reward[k] = (reward[k] or 0) + v
            end
            if flag then
                sflag = 1
            end
        end

        if not next(reward) then
            response.ret = -102
            return response
        end
     
        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end
    
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end

        if gems>0 then
            regActionLogs(uid,1,{action = 240, item = "", value = gems, params = {num = num}})
        end

        for k,v in pairs(reward) do
            table.insert(report, formatReward({[k]=v}))
        end

        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') == 1 then
            local hReward,hClientReward = harVerGifts('active','abjb',num)
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
            
            table.insert(data,1,{ts,report,num,harCReward,sflag})
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
                response.data[self.aname].hReward=harCReward  -- 和谐版奖励
            end
            response.data[self.aname].allreward = report -- 奖励
            response.data[self.aname].exlog = exlog -- 执行结果
            
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
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
     

        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    --舰船改造
    function self.action_shipupgrade(request)
        local response = self.response
        local uid = request.uid
        local num = request.params.num
        local item = request.params.item -- 用的第几个改造
        
        if not uid or not num or not table.contains({1,2,3},item) then
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
        local consumecfg = activeCfg['consume'..item]
        local aid = 0
        for k,v in pairs(consumecfg) do
            aid = k
        end
        local cfg = consumecfg[aid]
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

    return self
end

return api_active_abjb
