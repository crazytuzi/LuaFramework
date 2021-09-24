--
-- desc: 王牌飞行技能
-- user: chenyunhe
--
local function api_active_flyskill(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'flyskill',
    }

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'flyskill'
        formatreward[key] = {}
        if type(rewards) == 'table' then
            for k,v in pairs(rewards) do
                formatreward[key][k] = v
            end 
        end
        return formatreward
    end

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

    -- 从初始化本轮数据（点灯顺序l 点亮标识l1）
    function self.initl(num)
        local l = {}
        local l1 = {}
        local tmp = {}
        for i=1,num do
            table.insert(l1,0)
            table.insert(tmp,i)
        end

        l = table.rand(tmp)
        return l,l1
    end

    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local flag = false

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 初始化商店
        if type(mUseractive.info[self.aname].shop)~='table' then
            mUseractive.info[self.aname].shop = {}
            for k,v in pairs(activeCfg.serverreward.shopList) do
                table.insert(mUseractive.info[self.aname].shop,0)
            end
            flag = true
        end
        -- 初始化道具
        if not mUseractive.info[self.aname].flyskill_a1 then
            mUseractive.info[self.aname].flyskill_a1 = 0
            flag = true
        end
        -- 初始化 每轮数据
        if not mUseractive.info[self.aname].l or not mUseractive.info[self.aname].l1 then
            local l,l1 = self.initl(activeCfg.lightNum)
            mUseractive.info[self.aname].l = l
            mUseractive.info[self.aname].l1 = l1

            mUseractive.info[self.aname].miss = 0 --当前灯未点亮次数
            mUseractive.info[self.aname].cur = 0 -- 已经点亮几个了

            flag = true
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

    -- 抽奖
    function self.action_lottery(request)
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num) -- 1单抽 10十连抽
        local free = tonumber(request.params.free) -- 0非免费 1免费
        local ts= getClientTs()
        local weeTs = getWeeTs()
        
        if not table.contains({0,1},free) or not table.contains({1,10},num) then
           response.ret=-102
           return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive',"alienweapon"})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mAweapon = uobjs.getModel('alienweapon')

        -- 免费时 单抽
        if free ==1 and num>1 then
            response.ret = -102
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)

        if mUseractive.info[self.aname].t ~= weeTs then
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

        -- 当前要点亮灯的编号
        local nextl = (mUseractive.info[self.aname].cur or 0)+1
        -- 最终大奖没领取呢
        if nextl > activeCfg.lightNum then
            response.ret = -100
            return response
        end

        local flyskill_a1 = 0 -- 获得道具数量
        local reward={}
        local report={}
        local spprop = {}
        setRandSeed()
    
        for i=1,num do 
            -- 未全部点亮
            if mUseractive.info[self.aname].cur<activeCfg.lightNum then
                local lindex = mUseractive.info[self.aname].l[nextl]
                local rd = rand(1,100)
                local lightrate = activeCfg.serverreward.lightRate[nextl]
      
                --没点亮 会增加下次成功概率
                if mUseractive.info[self.aname].miss> 0 then
                    lightrate = lightrate + mUseractive.info[self.aname].miss*activeCfg.serverreward.rateAdd
                end
              
                -- 点亮了
                if rd<lightrate*100 then
                    mUseractive.info[self.aname].l1[lindex] = 1
                    mUseractive.info[self.aname].miss = 0
                    mUseractive.info[self.aname].cur = mUseractive.info[self.aname].cur + 1
                    nextl = nextl + 1
                else
                    -- 未点亮
                    mUseractive.info[self.aname].miss =  mUseractive.info[self.aname].miss + 1
                end
            end
            
            local result,rewardkey = getRewardByPool(activeCfg.serverreward.pool1,1)
            for k,v in pairs (result) do
                for rk,rv in pairs(v) do
                    if string.find(rk,'flyskill_a1') then
                        spprop[rk]=(spprop[rk] or 0)+rv
                        flyskill_a1 = flyskill_a1 + rv
                    else
                        reward[rk]=(reward[rk] or 0)+rv
                    end
                   
                end
            end            
        end

        if not takeReward(uid,reward) then    
            response.ret=-403
            return response
        end

        for k,v in pairs(reward) do
            table.insert(report, formatReward({[k]=v}))
        end

        if next(spprop) then
            for k,v in pairs(spprop) do
                table.insert(report,self.formatreward({[k]=v}))
            end
        end

        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        if gems>0 then
            regActionLogs(uid,1,{action=234,item="",value=gems,params={num=num}})
        end  

        local clientReport= copyTable(report)
        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','flyskill',num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward = hClientReward
        end

        mUseractive.info[self.aname].flyskill_a1 =  mUseractive.info[self.aname].flyskill_a1 + flyskill_a1
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
            --response.data[self.aname].getprop=flyskill_a1
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    -- 领取最终大奖
    function self.action_reward(request)
        local response = self.response
        local uid=request.uid
        local ts = getClientTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if mUseractive.info[self.aname].cur~=activeCfg.lightNum then
            response.ret = -102
            return response
        end
        local reward = {}
        local report = {}
        local result,rewardkey = getRewardByPool(activeCfg.serverreward.pool2,1)
        for k,v in pairs(result) do
            for rk,rv in pairs(v) do
                reward[rk]=(reward[rk] or 0)+rv
            end
        end            
        
        if not takeReward(uid,reward) then    
            response.ret=-403
            return response
        end

        for k,v in pairs(reward) do
            table.insert(report, formatReward({[k]=v}))
        end

        -- 重置
        mUseractive.info[self.aname].l, mUseractive.info[self.aname].l1 = self.initl(activeCfg.lightNum)
        mUseractive.info[self.aname].cur = 0 -- 已经点亮了几个灯
        mUseractive.info[self.aname].miss = 0 -- 下一个待点亮的灯 已经几次没点亮了
       
        if uobjs.save() then
            local redis =getRedis()
            local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={}  end
            
            table.insert(data,1,{ts,report,0,{}})
            if next(data) then
                for i=#data,11,-1 do
                    table.remove(data)
                end

                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[self.aname].et+86400*20)
            end         
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward=report
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

    -- 兑换商店
    function self.action_shopping(request)
        local response = self.response
        local uid=request.uid
        local itemid=request.params.item --购买哪一个
        local num=request.params.num or 1 --购买个数

        if not itemid or num<=0 then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local shopCfg = activeCfg.serverreward.shopList[itemid]

        if type(shopCfg) ~= 'table' then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].shop[itemid]+num > shopCfg.limit then
            response.ret = -1987
            return response
        end

        local costp = shopCfg.price *num
        if costp <=0 then
            response.ret = -120
            return response
        end

        if mUseractive.info[self.aname].flyskill_a1<costp then
            response.ret = -1996
            return response
        end

        mUseractive.info[self.aname].flyskill_a1 =mUseractive.info[self.aname].flyskill_a1 - costp
        local reward = {}
        for k,v in pairs(shopCfg.serverreward) do
            reward[k] = v * num
        end
      
        if not takeReward(uid,reward) then
            response.ret=-102
            return response
        end

        mUseractive.info[self.aname].shop[itemid] = (mUseractive.info[self.aname].shop[itemid] or 0) + num  
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

return api_active_flyskill
