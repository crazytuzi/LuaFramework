-- desc: 欢天转转乐
-- user: liming
local function api_active_happyday(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'happyday',
    }

    -- 随机奖励并获得积分
    function self.action_lottery(request)
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num)
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
        if free==1 then
             mUseractive.info[self.aname].v=1
        else
            if num ==1 then
                gems = activeCfg.cost1
            else
                num = 5
                gems = activeCfg.cost2
            end
        end
       
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        
        if gems>0 then
            regActionLogs(uid,1,{action = 198, item = "", value = gems, params = {num = num}})
        end
        local post = {}
        local reward = {}
        local report = {}
        local spprop = {}
        local rewardnum = getRewardByPool(activeCfg.serverreward.rewardPool)[1]
        -- num =2
        for i=1,num do
            local basereward = getRewardByPool(activeCfg.serverreward.basePool)
            for k,v in pairs(basereward) do
                reward[k] = (reward[k] or 0) + v
            end
        end
        -- rewardnum = 2
        if rewardnum > 0 then
            for i=1,rewardnum do
                local pk = getRewardByPool(activeCfg.serverreward.rndPool)[1]
                table.insert(post,pk)
                for i=1,num do
                    local bigreward,sk = getRewardByPool(activeCfg.serverreward['pool'..pk..'_p'])
                    for k,v in pairs(bigreward) do
                        reward[k] = (reward[k] or 0) + v
                    end
                    for idx=1,#sk do
                        local score = 0
                        local fix
                        score = activeCfg.serverreward['pool'..pk..'_p'].score[sk[idx]]
                        local x = getRewardByPool(activeCfg.serverreward['pool'..pk..'_s'])
                        for k1,v1 in pairs(x) do
                            spprop[k1] = (spprop[k1] or 0)+ v1*score
                            fix = string.sub(k1,-1,-1)
                        end
                        mUseractive.info[self.aname]['s'..fix]=(mUseractive.info[self.aname]['s'..fix] or 0)+score
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
        if next(spprop) then
            for k,v in pairs(spprop) do
                 -- mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
                 table.insert(report,self.formatreward({[k]=v}))
            end
        end
        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') == 1 then
            local hReward,hClientReward = harVerGifts('active','happyday',num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward = hClientReward
        end
        local bignum = num*rewardnum
        if uobjs.save() then
            local redis =getRedis()
            local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={} end
            table.insert(data,1,{ts,report,num,harCReward,rewardnum})
            if next(data) then
                if #data >10 then
                    for i=#data,11 do
                        table.remove(data)
                    end
                end
                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[self.aname].et+86400)
            end
            response.data[self.aname] =mUseractive.info[self.aname]
            if next(harCReward) then
                response.data[self.aname].hReward=harCReward  -- 和谐版奖励
            end
            response.data[self.aname].reward = report -- 奖励
            response.data[self.aname].bignum = bignum -- 累计大奖数量
            response.data[self.aname].post = post -- 来自哪个奖池
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

    -- 商店兑换
    function self.action_shopping(request)
        local response = self.response
        local uid=request.uid
        local itemid=request.params.item--兑换哪一个
        local num=request.params.num or 1 --兑换个数
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
        if type(mUseractive.info[self.aname].shop)~='table' then
            mUseractive.info[self.aname].shop={}
            for k,v in pairs(activeCfg.serverreward.shopList) do
                table.insert(mUseractive.info[self.aname].shop,0)
            end
        end
        local iteminfo = activeCfg.serverreward.shopList[itemid]
        if type(iteminfo)~='table' then
            response.ret = -102
            return response
        end
       
        -- 物品兑换次数不足
        if mUseractive.info[self.aname].shop[itemid] + num >iteminfo.limit then
            response.ret=-23305
            return response
        end
        --积分不足
        local s1 = iteminfo.price[1]*num
        local s2 = iteminfo.price[2]*num
        local s3 = iteminfo.price[3]*num
        
        if s1 > mUseractive.info[self.aname].s1 or s2 > mUseractive.info[self.aname].s2 or s3 > mUseractive.info[self.aname].s3 then
            response.ret = -20014
            return response
        end
        -- 增加兑换次数
        mUseractive.info[self.aname].shop[itemid]=mUseractive.info[self.aname].shop[itemid]+num
        local reward = {}
        for k,v in pairs(iteminfo.serverreward) do
             reward[k] = v*num
         end
        if not takeReward(uid,reward) then
            response.ret=-102
            return response
        end
        mUseractive.info[self.aname].s1 = mUseractive.info[self.aname].s1 - s1
        mUseractive.info[self.aname].s2 = mUseractive.info[self.aname].s2 - s2
        mUseractive.info[self.aname].s3 = mUseractive.info[self.aname].s3 - s3
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
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
        local mUserinfo = uobjs.getModel('userinfo')
        local mUseractive = uobjs.getModel('useractive')
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local flag = false
        
        --商店兑换次数
        if type(mUseractive.info[self.aname].shop)~='table' then
            flag = true
            mUseractive.info[self.aname].shop = {}
            for k,v in pairs(activeCfg.serverreward.shopList) do
                table.insert(mUseractive.info[self.aname].shop,0)
            end
        end
        --积分
        if mUseractive.info[self.aname].s1==nil  then
            flag = true
            mUseractive.info[self.aname].s1=0
        end
        if mUseractive.info[self.aname].s2==nil  then
            flag = true
            mUseractive.info[self.aname].s2=0
        end
        if mUseractive.info[self.aname].s3==nil  then
            flag = true
            mUseractive.info[self.aname].s3=0
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

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'happyday'
        formatreward[key] = {}
        if type(rewards) == 'table' then
            for k,v in pairs(rewards) do
                formatreward[key][k] = v
            end
        end
        return formatreward
    end


    return self
end

return api_active_happyday
