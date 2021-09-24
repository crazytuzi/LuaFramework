-- 两将活动(名将搜寻)
function api_active_twohero(request)
    local aname = 'twohero'

    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = tonumber(request.uid)
    local method = tonumber(request.params.method) or 0
    local action = request.params.action
    

    if uid == nil or  action == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","hero",'useractive',"alien"})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mHero = uobjs.getModel('hero')

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
    local ts = getClientTs()
    local weeTs = getWeeTs()
    local lastTs = mUseractive.info[aname].t or 0
    if weeTs > lastTs then
        mUseractive.info[aname].c = 0
    end
    local activeCfg = getConfig("active."..aname.."."..mUseractive.info[aname].cfg)
    local acet = mUseractive.getAcet(aname,true)
    local ratearr={}
    local function search(cfg,num,rate,reward,currN,report,heros,star)
            report = report or {}
            heros  = heros  or {}
            star   = star   or 0
            currN = (currN or 0) + 1

            local result = getRewardByPool(cfg.pool)
            reward = reward or {}
            local tmpScore = 0
            local tmpResult = {}
            for k, v in pairs(result or {}) do
                local award = k:split('_')
                tmpScore = rand(activeCfg.serverreward.scorelist[v.index][1], activeCfg.serverreward.scorelist[v.index][2]) + tmpScore
                tmpScore=tmpScore*rate
                --英雄的品阶特殊处理
                if award[1]=='hero' then
                    table.insert(heros,{award[2],v.num})
                else
                    reward[k] = (reward[k] or 0) + v.num
                end
                tmpResult[k] = v.num
                ratearr[v.index]=(ratearr[v.index]  or 0) +1
            end
            table.insert(report,{formatReward(tmpResult), tmpScore})
            star = star + tmpScore
            if currN >= num then
                return reward,report,heros,star
            else
                return search(cfg,num,rate,reward,currN,report,heros,star)
            end
            
    end

    if action == "rand" then
        --  免费
        local num=0
        local gems=0
        if method==1 then
            if mUseractive.info[aname].c ==1 then
                response.ret=-2032
                return response
            end
            mUseractive.info[aname].t=ts
            mUseractive.info[aname].c=1
            num=1
        -- 一次    
        elseif method==2 then
            gems=activeCfg.cost
            num=1
        elseif method==3 then
            gems=activeCfg.mulCost
            num=10
        end

        if num==0 or ts>=acet then
            response.ret=-102
            return response
        end
        if gems>0 then
            if not mUserinfo.useGem(gems) then
                response.ret = -109
                return response
            end

        end
        local reward,report,heros,score = search(activeCfg.serverreward,num,1)
        mUseractive.info[aname].v = mUseractive.info[aname].v + score
        
        local lotterylog = {r={},hr={}}
        if type(reward)=='table'  and next(reward) then
            if not takeReward(uid,reward) then
                response.ret=-403
                return response
            end
            lotterylog.r=reward
        end
        if type(heros)=='table'  and next(heros) then
            for k,v in pairs(heros) do
                local flag =mHero.addHeroResource(v[1],v[2])
                if not flag then
                    return response
                end

                if string.find(v[1],'h') then
                    lotterylog.r['hero_'..v[1]] = (lotterylog.r['hero_'..v[1]] or 0) + 1-- 加将领 第二个值是品质不是数量
                else
                    lotterylog.r['hero_'..v[1]] = (lotterylog.r['hero_'..v[1]] or 0) + v[2]
                end
            end
        end
        regActionLogs(uid,1,{action=82,item="",value=gems,params={reward=reward,hero=heros}})
        
        -- 和谐版活动
        local harReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','twohero',num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harReward = hClientReward
            lotterylog.hr = harReward
        end
          

        if uobjs.save() then
            if mUseractive.info[aname].v>=activeCfg.rankpoint  then
                if not setActiveRanking(uid,mUseractive.info[aname].v,aname,20,mUseractive.info[aname].st,mUseractive.info[aname].et) then
                    setActiveRanking(uid,mUseractive.info[aname].v,aname,20,mUseractive.info[aname].st,mUseractive.info[aname].et)
                end
            end 
            response.data[aname] =mUseractive.info[aname]
        
            if next(harReward) then
               response.data[aname].hReward=harReward
            end 

            local rewardlog = {}
            if next(lotterylog.r) then
                for k,v in pairs(lotterylog.r) do
                    table.insert(rewardlog,formatReward({[k]=v}))
                end
            end

            local redis =getRedis()
            local redkey ="zid."..getZoneId()..aname..mUseractive.info[aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={} end   
            table.insert(data,1,{ts,1,rewardlog,lotterylog.hr,num})
            if next(data) then
                for i=#data,11,-1 do
                    table.remove(data)
                end

                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[aname].et+86400)
            end      
                      
            response.data.hero =mHero.toArray(true)
            response.data.report = report
            processEventsAfterSave()
            response.ret = 0
            response.msg = 'Success'
        end

    elseif action=="ranklist" then

        local ranklist = getActiveRanking(aname,mUseractive.info[aname].st)
        --regKfkLogs(uid,'action',{
                        --sub_type='succ',
                        --addition={
                            --old={},
                          --  new={},
                        --    value={},
                      --  }
                    --}
                    --)
        local list={}
        if type(ranklist)=='table' and next(ranklist) then
            for k,v in pairs(ranklist) do
                local mid= tonumber(v[1])
                local muobjs = getUserObjs(mid,true)
                muobjs.load({"userinfo", "techs", "troops", "props","bag","skills","hero",'useractive',"alien"})
                local tmUserinfo = muobjs.getModel('userinfo')
                table.insert(list,{mid,tmUserinfo.nickname,v[2]})
            end
        end

        response.ret = 0
        response.msg = 'Success'
        response.ranklist=list
    elseif action=="rankreward" then
        local r=mUseractive.info[aname].r or 0
        if r==1 then
            response.ret=-1976
            return response
        end
        if ts<= acet then
            response.ret=-1978    
            return response
        end
        local rank=request.params.rank or 0
        local myrank=0
        local ranklist = getActiveRanking(aname,mUseractive.info[aname].st)
        if type(ranklist)=='table' and next(ranklist) then
            for k,v in pairs(ranklist) do
                local mid= tonumber(v[1])
                if mid==uid then
                    myrank=k
                end
            end
        end   
        if myrank~=rank then
            response.ret=-1975
            return response
        end
        if myrank<=0 then
            response.ret=-1980
            return response
        end
        --ptb:e(activeCfg.serverreward.rankReward)
        local rankreward={}
        for k,v in pairs(activeCfg.serverreward.rankReward) do
            if    myrank<=v.range[2] then
                rankreward=v.serverReward
                break
            end
        end
        mUseractive.info[aname].r =1
        if not takeReward(uid,rankreward) then
            response.ret=-403
            return response
        end
        if uobjs.save() then
            response.data[aname] =mUseractive.info[aname]
            processEventsAfterSave()
            response.data.hero =mHero.toArray(true)
            response.ret = 0
            response.msg = 'Success'
            response.data.reward=formatReward(rankreward)
        end
    elseif action=='log' then
        local redis =getRedis()
        local redkey ="zid."..getZoneId()..aname..mUseractive.info[aname].st.."uid."..uid
        local data =redis:get(redkey)
        data =json.decode(data)

        if type(data) ~= 'table' then data = {} end
        response.ret = 0
        response.msg = 'Success'
        response.data.report=data
        return response
    end    


    return response


end