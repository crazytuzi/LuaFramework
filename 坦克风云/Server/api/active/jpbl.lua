--
-- desc: 击破壁垒
-- user: chenyunhe
--
local function api_active_jpbl(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'jpbl',
    }

	
    -- 购买抽奖道具
    function self.action_buy(request)
 		local uid = request.uid
        local response = self.response
        local num =  request.params.num or 1
 
        if not uid or num<=0 then
       	   response.ret=-102
       	   return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mBag = uobjs.getModel('bag')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local prop = activeCfg.serverreward.exchangeItem[1]

        local propkeys = prop:split('_')
        local gems = num*activeCfg.cost
 
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end

        if not mBag.add(propkeys[2],num) then
            response.ret = -106
            return response
        end

        if gems>0 then
           regActionLogs(uid, 1, {action = 186, item = "", value = gems, params = {num = num}})
        end
 
        processEventsBeforeSave()
        if uobjs.save() then
            processEventsAfterSave()       
            response.data.bag = mBag.toArray(true)
            response.data[self.aname] = mUseractive.info[self.aname]
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106  
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

        -- 已抽取的次数
        if type(mUseractive.info[self.aname].l) ~= 'table' or not next(mUseractive.info[self.aname].l) then
            mUseractive.info[self.aname].l = {}  
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if table.length(mUseractive.info[self.aname].l)>= activeCfg.cellNum then
            mUseractive.info[self.aname].l = {}
        end

        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 抽奖
    function self.action_lottery(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive','bag'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mBag = uobjs.getModel('bag')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        if type(mUseractive.info[self.aname].l) ~= 'table' or not next(mUseractive.info[self.aname].l) then
            mUseractive.info[self.aname].l = {}
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if table.length(mUseractive.info[self.aname].l)>= activeCfg.cellNum then
            mUseractive.info[self.aname].l = {}
        end

        -- 判断道具数量
        local prop = activeCfg.serverreward.exchangeItem[1]
        local propkeys = prop:split('_')
        
        local num = #mUseractive.info[self.aname].l
        local curn = num + 1

        -- 本次需要消耗的道具数量
        local neednum = activeCfg.itemNeed[curn]
 
        local mBag = uobjs.getModel('bag')
        local propNums = mBag.getPropNums(propkeys[2])
        local gems = 0
        local buyn = neednum - propNums

        local usenum = neednum
     
        if buyn > 0 then
            local 
            gems = buyn*activeCfg.cost

            if not mUserinfo.useGem(gems) then
                response.ret = -109
                return response
            end
            regActionLogs(uid, 1, {action = 186, item = "", value = gems, params = {num = buyn}})
            usenum = propNums
        end

        if usenum > 0 then
            if not mBag.use(propkeys[2],usenum) then
                response.ret = -106
                return response
            end
        end

        -- 重置随机奖池
        local pool = copyTable(activeCfg.serverreward.pool)
        for k,v in pairs(mUseractive.info[self.aname].l) do
            pool[2][v] = 0
        end

        if not table.contains(mUseractive.info[self.aname].l,1) then
            local ln = #mUseractive.info[self.aname].l
            if ln < activeCfg.limitNum then
                pool[2][1] = activeCfg.preWeight
            end
        end
        
        local reward = {}
        local result,rewardkey = getRewardByPool(pool)
        for k,v in pairs (result) do
            reward[k]=(reward[k] or 0)+v
        end
 
        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end

        local clientReward = {}
        for k,v in pairs(reward) do
            table.insert(clientReward, formatReward({[k] = v})) 
        end

        table.insert(mUseractive.info[self.aname].l,rewardkey[1])

        if table.length(mUseractive.info[self.aname].l)>= activeCfg.cellNum then
            mUseractive.info[self.aname].l = {}
        end
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = clientReward
            response.data[self.aname].item =  rewardkey[1]
            response.data.bag = mBag.toArray(true)
            response.ret = 0
            response.msg = 'Success'

        else
            response.ret = -106
        end
        return response
    end


    return self
end

return api_active_jpbl
