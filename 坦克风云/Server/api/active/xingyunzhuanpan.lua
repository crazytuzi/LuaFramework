-- 5.1幸运转盘

function api_active_xingyunzhuanpan(request)
    local response = {    
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local method = tonumber(request.params.method) or 1 -- 1 一个剪头
    local rate   = tonumber(request.params.rate) or 1 -- 1 是一倍  2=10倍 
    if uid == nil then
        response.ret = -102
        return response
    end

    -- 活动名称，幸运转盘
    local acname = 'xingyunzhuanpan'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')

    local activStatus = mUseractive.getActiveStatus(acname)
    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local ts = getClientTs()
    local weeTs = getWeeTs()
    local activeCfg = getConfig("active." .. acname.."."..mUseractive.info[acname].cfg)
    local reward=getRewardByPool(activeCfg.serverreward.pool)
    local  gemCost=activeCfg.cost
    local  oneindex=0
    local  count=1
    local index=0
    local report={}
    local lastTs = mUseractive.info[acname].t or 0
    if weeTs > lastTs then
       gemCost=0
    end
    for k,v in pairs(activeCfg.serverreward.pool[3]) do
        for ak,ad in pairs(reward) do
            if ak==v[1] and  ad==v[2]  then
                index=v[3]
                oneindex=k
            end
        end
    end

    report["p"..oneindex]=copyTab(reward)
    if method==2 and gemCost~=0 then
        gemCost=activeCfg.doubleCost
        reward[activeCfg.serverreward.pool[3][index][1]]=activeCfg.serverreward.pool[3][index][2]
        report["p"..index]={[activeCfg.serverreward.pool[3][index][1]]=activeCfg.serverreward.pool[3][index][2]}
    end

    if rate==2  and gemCost ~=0 then
        gemCost=math.ceil(gemCost*10*activeCfg.value)
        for add,addcount in pairs(reward) do
            reward[add]=addcount*activeCfg.mul
        end
        
        count=9
    end

    if gemCost< 0 and weeTs < lastTs  then
        response.ret = -102
        return response
    end
    if gemCost >0 then
        if  not mUserinfo.useGem(gemCost) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action=70,item="",value=gemCost,params={method=method,rate=rate}})
    end
    for addkey,addcount in pairs(reward) do
        if addkey ~= 'mm_m1' then
            if not takeReward(uid, {[addkey]=addcount}) then
                response.ret = -403
                return response
            end
        else
            mUseractive.info[acname].v= mUseractive.info[acname].v + addcount
        end
    end
    local weets = getWeeTs()
    for pk,pv in pairs(report) do
        for pvk,pvv in pairs(pv) do
            if rate==2 then
                pvv=pvv*activeCfg.mul
            end
            if pvk~="mm_m1" then

                report[pk]=formatReward({[pvk]=pvv})
            else
                report[pk][pvk]=pvv
            end
            
        end
    end
    
    mUseractive.info[acname].t=ts

    -- 和谐版
    if moduleIsEnabled('harmonyversion') ==1 then
        local rewnum=0
        if rate==1 then
            rewnum=1
        elseif rate==2 then
            rewnum=10
        end

        if method==2 then 
            rewnum=rewnum*2
        end

        local hReward,hClientReward = harVerGifts('active','xingyunzhuanpan',rewnum)
        if not takeReward(uid,hReward) then
            response.ret = -403
            return response
        end
        if type(response.data[acname])~='table' then
            response.data[acname]={}
        end
        response.data[acname].hReward = hClientReward
    end  
    if uobjs.save() then 
            -- 统计
        local statskey="z."..getZoneId().."xingyunzhuanpan."..method.."ts"..weets
        local redis = getRedis()
        redis:incrby(statskey,count)
        redis:expire(statskey,30*24*3600)
        response.data.report = report
        response.data.userinfo = mUserinfo.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
    end
    return response
    
end