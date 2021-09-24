-- 奥运活动

function api_active_olympic(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local uid    = request.uid
    local action = tonumber(request.params.action) or 1
    local aname  = request.params.aname or 'olympic'
    local ts     = getClientTs()
    local weeTs  = getWeeTs()
    
    if not uid or not action then
        response.ret = -102
        return response
    end    

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo",'useractive','bag','troops','accessory','hero'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops = uobjs.getModel('troops')
    local mAccessory = uobjs.getModel('accessory')
    local mBag = uobjs.getModel("bag")
    local mHero = uobjs.getModel('hero')
    local activStatus = mUseractive.getActiveStatus(aname)

    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
    local activeCfg = mUseractive.getActiveConfig(aname)
    local lastTs = mUseractive.info[aname].t or 0
    if weeTs > lastTs then
        mUseractive.info[aname].v = 0
        mUseractive.info[aname].t =weeTs
    end
    local redis =getRedis()
    local redkey ="zid."..getZoneId()..aname..mUseractive.info[aname].st.."uid."..uid
    if action==4 then
        local data =redis:get(redkey)
        data =json.decode(data)
        if type(data)=='table' then
            response.data.log=data
         end   
         response.ret=0
         response.msg = 'Success'
         return response
    end

    -- 免费的
    local num=0
    local gems=0
    if action==1 then
        if mUseractive.info[aname].v>0 then
            response.ret = -102
            return response
        end
        mUseractive.info[aname].v = 1
        num=1
    -- 一次收费    
    elseif action==2 then
        gems=activeCfg.cost
        num=1
    --  10次收费
    elseif action==3 then
        gems=math.ceil(activeCfg.cost*10*activeCfg.value)
        num=10
    end

    if gems>0 then
         if not mUserinfo.useGem(gems) then
            response.ret = -109 
            return response
        end
        regActionLogs(uid,1,{action=133,item="",value=gems,params={buyNum=num}})  
    end
    local pool=copyTab(activeCfg.serverreward.pool)
    local point=0
    local report={}
    for i=1,5 do
        local reward=getRewardByPool(pool)
        for k,v in pairs (reward) do
            table.insert(report,k)
            for pk,pv in pairs (pool[3]) do
                if pv[1]==k then
                    table.remove(pool[3],pk)
                    table.remove(pool[2],pk)
                end
            end
        end
    end

    for k,v in pairs (report) do
        local rank=3
        if table.contains(activeCfg.line, v) then
            rank=2
            if activeCfg.line[k]==v then
                rank=1
            end
        end
        point=point+activeCfg.point[rank] or 0
    end
    local reward=getRewardByPool(activeCfg.serverreward["pool"..point])
    if num>1 then
        for k,v in pairs (reward) do
            reward[k]=v*num
        end
    end    
    if not takeReward(uid,reward) then        
        response.ret = -403 
        return response
    end
    if uobjs.save() then 

        local data =redis:get(redkey)
        data =json.decode(data)
        response.data.reward={formatReward(reward)}
        if type (data)~="table" then data={}  end
        local lnum=nil
        if num>1 then
            lnum=num
        end
        table.insert(data,{response.data.reward,ts,lnum})       
        if next(data) then
            if #data >10 then
                for i=1,#data-10 do
                    table.remove(data,1)
                end
            end
            data=json.encode(data)
            redis:set(redkey,data)
            redis:expireat(redkey,mUseractive.info[aname].et+86400)
        end
        response.data[aname] =mUseractive.info[aname]
        response.data.report = report
        
        processEventsAfterSave()

        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
    
end