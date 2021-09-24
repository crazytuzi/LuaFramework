--
-- desc: 宝石迷阵
-- user: yunhe
-- 
local function api_active_bsmz(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'bsmz',
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
        local response = self.response
        local uid = request.uid
        local num = tonumber(request.params.num)
        local free = tonumber(request.params.free) -- 0非免费 1免费
        local ts= getClientTs()
        local weeTs = getWeeTs()
       
        if not table.contains({0,1},free) or not table.contains({1,10},num) then
           response.ret=-102
           return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
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
             num = 1
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
            regActionLogs(uid,1,{action = 241, item = "", value = gems, params = {num = num}})
        end
        local result = {} -- 随机抽奖结果  {{几个连线,{color1,color2}},{}} 每局几个连线 连线的颜色
        local reward = {} -- 获得奖励
        local report = {} -- 奖励记录
        local binggo = 0  -- 本次抽奖共几条连线
        local getscore = 0 -- 本次获得积分
        for i=1,num do
            -- 确定本次抽奖 出现连线数量
            local  color = {}
            local  rewardnum = getRewardByPool(activeCfg.serverreward.rewardPool)[1]
            if rewardnum==0 then
                local basereward = getRewardByPool(activeCfg.serverreward.basePool)
                for k,v in pairs(basereward) do
                    reward[k] = (reward[k] or 0) + v
                end
            else
                for r=1,rewardnum do
                    -- 随机颜色
                    local pk = getRewardByPool(activeCfg.serverreward.rndPool)[1]
                    local bigreward,sk = getRewardByPool(activeCfg.serverreward['pool'..pk..'_p'])
                    for k,v in pairs(bigreward) do
                        reward[k] = (reward[k] or 0) + v
                    end

                    for idx=1,#sk do
                        local score = 0
                        score = activeCfg.serverreward['pool'..pk..'_p'].score[sk[idx]]           
                        mUseractive.info[self.aname].score=(mUseractive.info[self.aname].score or 0)+score
                        getscore = getscore + score
                    end  
                    table.insert(color,pk)
                end  
            end 
            table.insert(result,{rewardnum,color})
            binggo = binggo + rewardnum
        end
        

        for k,v in pairs(reward) do
            table.insert(report, formatReward({[k]=v}))
        end
        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end
     
        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') == 1 then
            local hReward,hClientReward = harVerGifts('active','bsmz',num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward = hClientReward
        end
    
        if uobjs.save() then
            -- 更新个人积分
            self.addscore(mUseractive,uid,mUserinfo.nickname,getscore)
            local redis =getRedis()
            local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={} end
            table.insert(data,1,{ts,report,num,harCReward,binggo})
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
            response.data[self.aname].result = result -- 抽奖结果
            response.data[self.aname].getscore = getscore -- 本次获得积分
            response.data.alienjewel = mAweapon.formjeweldata()-- 宝石
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

    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
       
        --积分
        if not mUseractive.info[self.aname].score then
            mUseractive.info[self.aname].score=0
        end
        -- 有没有领取排行榜奖励
        if not mUseractive.info[self.aname].r  then
            mUseractive.info[self.aname].r=0 --0未领取 1已领取
        end

        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 加积分(活动的最后一天是不能加积分的，最后天用来排行榜领奖励)
    function self.addscore(mUseractive,uid,name,score)
        local ts= getClientTs()     
        if ts < tonumber(mUseractive.getAcet(self.aname, true)) then 
            local redis = getRedis()
            local scorekey = "zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st..'score'
            local scorelist = json.decode(redis:get(scorekey))

            if type(scorelist)~='table' or not next(scorelist) then
                scorelist = {}
                local list = readRankfile(self.aname,mUseractive.info[self.aname].st)
                if type(list) == 'table' then
                    redis:set(scorekey,json.encode(list))
                    redis:expireat(scorekey,mUseractive.info[self.aname].et+86400)
                    scorelist = list
                end
            end

            local uexit = false
            for k,v in pairs(scorelist) do
                if tonumber(v[1]) == uid then
                    v[2] = name
                    v[3] = v[3] + score

                    uexit = true
                    break
                end
            end

            if not uexit then
                table.insert(scorelist,{uid,name,score,ts})
            end

            redis:set(scorekey,json.encode(scorelist))
            redis:expireat(scorekey,mUseractive.info[self.aname].et+86400)     
        end
    end

    -- 积分排行榜(拉取排行榜 有人数和积分限制)
    function self.urank(st,et,limitscore)
        local redkey = "zid."..getZoneId().."."..self.aname.."ts"..st..'score'
        local redis = getRedis()
        local scorelist = json.decode(redis:get(redkey))
       
        if type(scorelist)~='table' or not next(scorelist) then
            scorelist = {}
            local list = readRankfile(self.aname,st)
            if type(list) == 'table' then
                redis:set(redkey,json.encode(list))
                redis:expireat(redkey,et+86400)
                scorelist = list
            end
        else
            -- 排序
            table.sort( scorelist,function ( a,b )  
                -- body  
                if a[3]==b[3] then  
                    return a[4] < b [4]
                end 
        
                return a[3] > b[3]  
            end ) 

            local ranklist = json.encode(scorelist)
            writeActiveRankLog(ranklist,self.aname,st) -- 排行榜记录日志
        end

        local list = {}
        local num = 0 -- 显示前10条
        for k,v in pairs(scorelist) do
            if num>=10 then
                break
            end

            if v[3]>=limitscore then
                 table.insert(list,v)
            end 
            num = num + 1 
        end

        return list
    end

       -- 获取排行榜数据
    function self.action_rankList(request)
        local uid = request.uid
        local response = self.response
 
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo =  uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local ranklist = {}
        local currank = -1

        ranklist = self.urank(mUseractive.info[self.aname].st,mUseractive.info[self.aname].et,activeCfg.rLimit)
        for k,v in pairs(ranklist) do
            if v[1] == uid then
                currank = k
                break
            end
        end
   
        response.ret = 0
        response.msg = 'success'
        response.data[self.aname] = mUseractive.info[self.aname]
        response.data[self.aname].list = ranklist
        response.data[self.aname].currank = currank
       

        return response
    end

     -- 领取排行榜奖励
    function self.action_rankReward(request)
        local uid = request.uid
        local response = self.response
        local rank = request.params.rank
        local ts = getClientTs()
 
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo =  uobjs.getModel('userinfo')
        local mAweapon = uobjs.getModel('alienweapon')

        local lt = tonumber(mUseractive.getAcet(self.aname, true))
        -- 时间还没到
        if ts < lt then
            response.ret =-1978
            return response
        end

        -- 已经领取奖励
        if (mUseractive.info[self.aname].r or 0) == 1 then
            response.ret = -1976
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        
        -- 获取排名
        local myrank = -1
        local ranklist = self.urank(mUseractive.info[self.aname].st,mUseractive.info[self.aname].et,activeCfg.rLimit)
        if type(ranklist)=='table' and next(ranklist) then
            for k,v in pairs(ranklist) do
                if tonumber(v[1]) == uid then
                    myrank = k
                    break
                end
            end
        else
            response.ret = -1975
            return response
        end 

        if myrank ~= rank then
            response.ret = -102
            return response
        end

        -- 判断排名获得奖励下标
        local matchgift = 0
        for k,v in pairs(activeCfg.section) do
            if myrank>=v[1] and myrank<=v[2] then
                matchgift = k
                break
            end
        end

        if matchgift == 0 then
            response.ret = -102
            return response
        end

        local reward = copyTable(activeCfg.serverreward['rank'..matchgift])
        if type(reward)~='table' then
            response.ret = -102
            return response
        end
        -- 额外奖励
        if rank>=1 and rank<=3 and mUseractive.info[self.aname].score>=activeCfg.extraLimit then
            for k,v in pairs(activeCfg.serverreward['exRank'..rank]) do
                reward[k] = (reward[k] or 0) + v
            end
        end      
    
        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end

        mUseractive.info[self.aname].r = 1
        processEventsBeforeSave()
        if uobjs.save() then
            processEventsAfterSave()
            response.ret = 0
            response.msg = 'success'
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(reward)
            response.data.alienjewel = mAweapon.formjeweldata()-- 宝石
        else
            response.ret = -106
        end

        return response
    end

    return self
end

return api_active_bsmz
