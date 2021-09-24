--desc:超装组件
--user:liming
local function api_active_czzj(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'czzj',
    }
    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'czzj'
        formatreward[key] = {}
        if type(rewards) == 'table' then
            for k,v in pairs(rewards) do
                formatreward[key][k] = v
            end 
        end
        return formatreward
    end
    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
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
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if type(mUseractive.info[self.aname].buynum) ~= 'table' then
            mUseractive.info[self.aname].buynum = {}
            for _,v in pairs(activeCfg.serverreward.shopList) do
                table.insert(mUseractive.info[self.aname].buynum,0)
            end
        end
        if mUseractive.info[self.aname].wheel == nil then
            mUseractive.info[self.aname].wheel = 0 --轮数
        end
        if mUseractive.info[self.aname].gems == nil then
            mUseractive.info[self.aname].gems = 0 --钻石数
        end
        if type(mUseractive.info[self.aname].s) ~= 'table' then
            mUseractive.info[self.aname].s = {}
            for i=1,#activeCfg.serverreward.randomItem do
                mUseractive.info[self.aname].s[i] = 0
            end
        end
        if not uobjs.save() then
            response.ret = -106
            return response
        end
        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end
    -- 抽奖
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
             regActionLogs(uid,1,{action=225,item="",value=gems,params={num=num}})
        end
        local spprop = {}
        local reward={}
        local report={}
        local spreport = {}
        for i=1,num do
            local result,rkey= getRewardByPool(activeCfg.serverreward.pool1,1)
            local score = activeCfg.serverreward.pool1.score[rkey[1]]
            spreport[i] = {}
            for k,v in pairs(result[1]) do
                reward[k] = (reward[k] or 0) + v
                table.insert(spreport[i],formatReward({[k]=v}))
            end  
            local numNeed = {}
            for k,v in pairs(activeCfg.serverreward.numNeed) do
                if mUseractive.info[self.aname].wheel==0 then
                    numNeed[k] = math.ceil(v*activeCfg.firstDiscount)
                else
                    numNeed[k] = v+activeCfg.serverreward.numAdd[k]*mUseractive.info[self.aname].wheel
                end
            end
            -- 随机分配积分到某个部位
            local pool = {}
            for rindex,rnum in pairs(activeCfg.serverreward.randomItem) do
                -- 过滤已经集满的部位
                if mUseractive.info[self.aname].s[rindex] < numNeed[rindex]  then
                    for num=1,rnum do
                        table.insert(pool,rindex)
                    end
                end
            end
            setRandSeed()
            local pos = pool[rand(1,#pool)]
            local tmpspprop = {}
            tmpspprop[activeCfg.serverreward.itemNeed[pos]] = score
            for k,v in pairs(tmpspprop) do
                spprop[k] = (spprop[k] or 0) + v
                table.insert(spreport[i],self.formatreward({[k]=v}))
            end
            mUseractive.info[self.aname].s[pos] = (mUseractive.info[self.aname].s[pos] or 0) + score
            local count = 0
            local fin = 0
            for rindex,rnum in pairs(activeCfg.serverreward.randomItem) do
                count = count + 1
                if mUseractive.info[self.aname].s[rindex] >= numNeed[rindex] then
                    fin = fin + 1
                end
            end
            if count > 0 and fin > 0 and count == fin then
                local bigresult = getRewardByPool(activeCfg.serverreward.pool2)
                for k,v in pairs(bigresult) do
                    reward[k] = (reward[k] or 0) + v
                    table.insert(spreport[i],formatReward({[k]=v}))
                end
                for k,v in pairs(mUseractive.info[self.aname].s) do
                    mUseractive.info[self.aname].s[k] = mUseractive.info[self.aname].s[k]-numNeed[k]
                end
                mUseractive.info[self.aname].wheel = mUseractive.info[self.aname].wheel + 1
            end
        end  
        if next(reward) then
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end
            for k,v in pairs(reward) do
                table.insert(report,formatReward({[k]=v}))
            end
        end
        if next(spprop) then
            for k,v in pairs(spprop) do
                 table.insert(report,self.formatreward({[k]=v}))
            end
        end
        -- ptb:e(spreport)
        -- ptb:e(report)
        -- ptb:e(reward)
        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','czzj',num)
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
            response.data[self.aname].reward=spreport
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
    --  商店购买
    function self.action_shop(request)
         local response = self.response
         local uid=request.uid
         local item =  request.params.item
         local buyNum = request.params.num or 1
         if  not uid or not item then
            response.ret =-102
            return response
         end
         local uobjs = getUserObjs(uid)
         uobjs.load({"userinfo",'useractive'})
         local mUseractive = uobjs.getModel('useractive')
         local mUserinfo = uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local iteminfo = activeCfg.serverreward.shopList[item]
        if type(iteminfo)~='table' then
            response.ret = -102
            return response
        end
        if mUseractive.info[self.aname].gems < activeCfg.rechargeNum[item] then
            response.ret = -30002
            return response
        end
        if mUseractive.info[self.aname].buynum[item]+buyNum>iteminfo.limit then
            response.ret = -1987
            return response
        end
        local gems = iteminfo.price * buyNum
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end

        if gems>0 then
            regActionLogs(uid,1,{action = 225, item = "", value = gems, params = {}})
        end

        local reward ={}
        for k,v in pairs(iteminfo.serverreward) do
            reward[k] = v*buyNum
        end
        if not takeReward(uid,reward) then
            response.ret =-403
            return response
        end
        mUseractive.info[self.aname].buynum[item] = mUseractive.info[self.aname].buynum[item] + buyNum
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

    return self
end

return api_active_czzj