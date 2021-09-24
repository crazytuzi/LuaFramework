-- 火线名将


function api_active_huoxianmingjiang(request)
    local aname = 'huoxianmingjiang'

    local response = {
        ret=-1,
        msg='error',
        data = {
        },
    }

    local uid = request.uid
    local method = tonumber(request.params.method) or 0
    

    if uid == nil or  method==nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","hero",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mHero = uobjs.getModel('hero')

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local activeCfg = getConfig("active."..aname.."."..mUseractive.info[aname].cfg)

    local weeTs = getWeeTs()
    local lastTs = mUseractive.info[aname].t or 0
    if weeTs > lastTs then
        mUseractive.info[aname].c = 0
        mUseractive.info[aname].v = 0
    end

    if type(mUseractive.info[aname].s)~='table' then mUseractive.info[aname].s={0,0,0,0} end
    
    local gems=activeCfg.cost
    local mustGetHero=activeCfg.mustGetHero

    local redis =getRedis()
    local redkey ="zid."..getZoneId().."huoxianmingjiang."..mUseractive.info[aname].st.."uid."..uid
    local data =redis:get(redkey)
    data =json.decode(data)
    if type (data)~="table" then data={}  end
    local ts = getClientTs()

    local function search(cfg,num,reward,currN,report,heros,star)

        report = report or {}
        heros  = heros  or {}
        star   = star   or {}
        currN = (currN or 0) + 1
        local result,rewardKey =nil
        local must =true
        for k,v in pairs (mUseractive.info[aname].s) do
            if v==0 then
                must=false
            end
        end


       
        if must==true then

            result = mustGetHero
            mUseractive.info[aname].s={0,0,0,0}
        else
            result = getRewardByPool(cfg.pool)
        end
        local tmpdata={result,ts}
        table.insert(data,tmpdata)
        reward = reward or {}

        
        for k, v in pairs(result or {}) do
            local award = k:split('_')

            if award[1]=='hero' then
                table.insert(heros,{award[2],v})
            else
                reward[k] = (reward[k] or 0) + v 
            end  
            
        end
        setRandSeed()
        
        for k1,v1 in pairs(cfg.starRate) do
            local randnum = rand(1,1000)

            if (v1*1000) >= randnum then
                mUseractive.info[aname].s[k1]=1
            end    
            
        end
        local tmpstar =copyTab(mUseractive.info[aname].s)
        table.insert(star,tmpstar)
  
        table.insert(report,{formatReward(result)})

        if currN >= num then
            return reward,report,heros,star
        else
            return search(cfg,num,reward,currN,report,heros,star)
        end        
    end

    -- ==0 是抽一次如果有免费用免费的
    local num=0
    if method==0 then
        if mUseractive.info[aname].c==0  then
            gems=0
            mUseractive.info[aname].c=1
        end
        
        num=1

    else

        gems=math.floor(gems*10*activeCfg.value)
        num=10
    end


    if gems >0 then
        if not mUserinfo.useGem(gems) then
            response.ret = -109 
            return response
        end
    end

    local reward,report,heros,stars = search(activeCfg.serverreward,num)
    if reward  and next(reward) then
        if not takeReward(uid,reward) then
            return response
        end
    end

    if next(heros) then
        for k,v in pairs(heros) do
            local flag =mHero.addHeroResource(v[1],v[2])
            if not flag then
                return response
            end
        end
        
    end
    mUseractive.info[aname].t=ts
    regActionLogs(uid,1,{action=59,item="",value=gems,params={buyNum=num}})
    processEventsBeforeSave()
    regEventBeforeSave(uid,'e1')

    -- 和谐版活动
    local harReward={}
    if moduleIsEnabled('harmonyversion') ==1 then
        local hReward,hClientReward = harVerGifts('active','huoxianmingjiang',num)
        if not takeReward(uid,hReward) then
            response.ret = -403
            return response
        end
        harReward = hClientReward

        local tmpdata={hReward,ts}
        table.insert(data,#data-num+1,tmpdata) 
    end

    if uobjs.save() then
        if next(data) then
            if #data >30 then
                for i=1,#data-30 do
                    table.remove(data,1)
                end
            end
            data=json.encode(data)
            redis:set(redkey,data)
            redis:expireat(redkey,mUseractive.info[aname].et+86400)
        end
        response.data[aname] =mUseractive.info[aname]
        if next(harReward) then
           response.data[aname].hReward=harReward
        end
        response.data.hero =mHero.toArray(true)
        response.data.hero.report = report
        response.data.star =stars
        processEventsAfterSave()

        response.ret = 0
        response.msg = 'Success'
    end
    
    return response

    -- body
end