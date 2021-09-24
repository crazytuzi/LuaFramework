--
-- desc: 擦拭铜镜
-- user: chenyunhe
--
local function api_active_cleanmirror(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'cleanmirror',
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
        local mHero = uobjs.getModel('hero')
        local flag = false
        local weeTs = getWeeTs()

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 兑换次数
        if not mUseractive.info[self.aname].ex then
            flag = true
            mUseractive.info[self.aname].ex = 0
            mUseractive.info[self.aname].rt = 0
        end

        if mUseractive.info[self.aname].rt ~= weeTs then
            flag = true
            mUseractive.info[self.aname].ex = 0
            mUseractive.info[self.aname].rt = weeTs
        end

        -- 初始化 每轮数据
        if not mUseractive.info[self.aname].l or not mUseractive.info[self.aname].l1 then
            local l,l1 = self.initl(activeCfg.lightNum)
            mUseractive.info[self.aname].l = l
            mUseractive.info[self.aname].l1 = l1

            mUseractive.info[self.aname].miss = 0 --当前未擦掉的次数
            mUseractive.info[self.aname].cur = 0 -- 已经擦掉几个
            flag = true
        end

        if flag then
            if not uobjs.save() then
                response.ret = -106
                return response
            end
        end

        response.data[self.aname] = mUseractive.info[self.aname]
        response.data.hero = mHero.toArray(true)
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 抽奖
    function self.action_lottery(request)
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num) -- 1单抽 5连抽
        local free = tonumber(request.params.free) -- 0非免费 1免费
        local ts= getClientTs()
        local weeTs = getWeeTs()
        
        if not table.contains({0,1},free) or not table.contains({1,5},num) then
           response.ret=-102
           return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive','hero','bag'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mHero = uobjs.getModel('hero')
        local mBag = uobjs.getModel('bag')

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
             num = 1
             mUseractive.info[self.aname].v=1
        else
            if num ==1 then
                gems = activeCfg.cost1
            else
                num = 5
                gems = activeCfg.cost2
            end
        end

        -- 当前要擦拭杂物的编号
        local reward={}
        local report={}
        setRandSeed()
    
        for i=1,num do 
            local nextl = mUseractive.info[self.aname].cur + 1
            local lindex = mUseractive.info[self.aname].l[nextl]
            local rd = rand(1,100)
            local lightrate = activeCfg.serverreward.lightRate[nextl]
  
            --没有清除 会增加下次成功概率
            if mUseractive.info[self.aname].miss> 0 then
                lightrate = lightrate + mUseractive.info[self.aname].miss*activeCfg.serverreward.rateAdd
            end
          
            -- 清除了一个
            if rd<lightrate*100 then
                ptb:p('清除了一个')
                mUseractive.info[self.aname].l1[lindex] = 1
                mUseractive.info[self.aname].miss = 0
                mUseractive.info[self.aname].cur = mUseractive.info[self.aname].cur + 1
            else
                -- 未点亮
                mUseractive.info[self.aname].miss =  mUseractive.info[self.aname].miss + 1
            end

            -- 全部清除 需要重新初始化下一轮数据
            if mUseractive.info[self.aname].cur == activeCfg.lightNum then
                local l,l1 = self.initl(activeCfg.lightNum)
                mUseractive.info[self.aname].l = l
                mUseractive.info[self.aname].l1 = l1

                mUseractive.info[self.aname].miss = 0 --当前未擦掉的次数
                mUseractive.info[self.aname].cur = 0 -- 已经擦掉几个

                -- 给大奖
                local bigreward,bigkey = getRewardByPool(activeCfg.serverreward.pool2,1)
                for k,v in pairs (bigreward) do
                    for rk,rv in pairs(v) do   
                        reward[rk]=(reward[rk] or 0)+rv           
                    end
                end         
            end
       
            local normal,normalkey = getRewardByPool(activeCfg.serverreward.pool1,1)
            for k,v in pairs (normal) do
                for rk,rv in pairs(v) do   
                    reward[rk]=(reward[rk] or 0)+rv           
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

        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        if gems>0 then
            regActionLogs(uid,1,{action=245,item="",value=gems,params={num=num}})
        end  

        local clientReport= copyTable(report)
        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','cleanmirror',num)
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
            response.data.bag = mBag.toArray(true)
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
    function self.action_exchange(request)
        local response = self.response
        local uid=request.uid
        local ex = request.params.ex  -- 1 A组兑换B组 2 B组兑换A组 
        local id=request.params.id    
        local act = request.params.act -- 1单次 2快速兑换
        local weeTs = getWeeTs()

        if not table.contains({1,2},ex) or id<=0 or not table.contains({1,2},act) then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive','hero'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mHero = uobjs.getModel('hero')
        local mBag = uobjs.getModel('bag')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
       
        if not mUseractive.info[self.aname].ex then
            mUseractive.info[self.aname].ex = 0
            mUseractive.info[self.aname].rt = 0
        end

        if mUseractive.info[self.aname].rt ~= weeTs then
            mUseractive.info[self.aname].ex = 0
            mUseractive.info[self.aname].rt = weeTs
        end

        if mUseractive.info[self.aname].ex>=activeCfg.exLimit then
            response.ret = -1973
            return response
        end

        local limit = activeCfg.exLimit - mUseractive.info[self.aname].ex
        local num = 0 -- 兑换的次数
        local gems = 0 -- 消耗的钻石数    
        local reward = {} 
        if ex ==1 then
            local s1key = activeCfg.heroA[id]:split('_')
            local s2key = activeCfg.heroB[1]:split('_')
            s1 = s1key[2]
            s2 = s2key[2]
            local cur = mHero.soul[s1]
            if not cur then
                response.ret = -1996
                return response
            end
            local usoul = 0 -- 消耗的魂
            local addsoul = 0 -- 增加的魂
            -- 单次兑换
            if act == 1 then
                usoul = activeCfg.exchangeNum1[id]
                if not cur or cur<usoul then
                    response.ret = -1996
                    return response
                end
                addsoul = 1
                num = 1
                gems = activeCfg['exCost1']
             
                if mUserinfo.gems<gems then
                    response.ret = -109
                    return response
                end
            else -- 多次兑换
                -- 此处需要计算出能够兑换的次数
                local n1 = math.floor(cur/activeCfg.exchangeNum1[id])
                local needgems = 0
                local n2 = 0

                for i=1,n1 do
                    if mUserinfo.gems >= needgems+i*activeCfg['exCost1'] then
                        n2 = i
                    end
                end
        
                if n1==0 or n2==0 then
                    response.ret = -102
                    return response
                end

                if n2>=n1 then
                    num = n1
                else
                    num = n2
                end

                if num> limit then
                    num = limit
                end
               
                addsoul = num
                usoul = activeCfg.exchangeNum1[id] * num
                gems = activeCfg['exCost1'] * num           
            end

            if num==0 then
                response.ret = -102 
                return response
            end

            reward[activeCfg.heroB[1]] = addsoul
           
            local aret = mHero.addsoul(s2,addsoul)
            local uret = mHero.usesoul(s1,usoul)
            if not aret or not uret then
                response.ret = -406
                return response
            end          
        else
            local s1key = activeCfg.heroB[1]:split('_')
            local s2key = activeCfg.heroA[id]:split('_')
            s1 = s1key[2]
            s2 = s2key[2]
            local cur = mHero.soul[s1]
            if not cur then
                response.ret = -1996
                return response
            end
            local usoul = 0 -- 消耗的魂
            local addsoul = 0 -- 增加的魂
            -- 单次兑换
            if act == 1 then
                usoul = 1
                if not cur or cur<usoul then
                    response.ret = -1996
                    return response
                end
                addsoul = activeCfg.exchangeNum2[id]
                num = 1
                gems = activeCfg['exCost2']
            else -- 多次兑换
                -- 此处需要计算出能够兑换的次数
                local n1 = cur
                local needgems = 0
                local n2 = 0
                for i=1,n1 do
                    if mUserinfo.gems >= needgems+i*activeCfg['exCost2'] then
                        n2 = i
                    end
                end

                if n1==0 or n2==0 then
                    response.ret = -102
                    return response
                end

                if n2>=n1 then
                    num = n1
                else
                    num = n2
                end

                if num>limit then
                    num = limit
                end
                addsoul = activeCfg.exchangeNum2[id] * num
                usoul = num
                gems = activeCfg['exCost2'] * num
            end

            if num==0 then
                response.ret = -102 
                return response
            end

            reward[activeCfg.heroA[id]] = addsoul
           
            local aret = mHero.addsoul(s2,addsoul)
            local uret = mHero.usesoul(s1,usoul)
            if not aret or not uret then
                response.ret = -406
                return response
            end          
        end
        
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        if gems>0 then
            regActionLogs(uid,1,{action=246,item="",value=gems,params={num=num}})
        end  
 
        mUseractive.info[self.aname].ex = mUseractive.info[self.aname].ex + num  
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(reward)
            response.data.hero = mHero.toArray(true)
            response.data.bag = mBag.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        else
          response.ret=-106
        end

        return response        
    end
   
    return self
end

return api_active_cleanmirror
