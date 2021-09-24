-- 开年大吉活动

function api_active_openyear(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = tonumber(request.uid)
    local action = request.params.action
     if uid == nil then
        response.ret = -102
        return response
    end

    -- 活动名称，新年除夕
    local aname = 'openyear'
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local activStatus = mUseractive.getActiveStatus(aname)
    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
    local weeTs = getWeeTs()
    local ts = getClientTs()
    local activeCfg = mUseractive.getActiveConfig(aname)
    local lastTs = mUseractive.info[aname].t or 0
    if weeTs > lastTs then
        mUseractive.info[aname].dt ={}
        mUseractive.info[aname].t=weeTs
        mUseractive.info[aname].v=0
        mUseractive.info[aname].c=0
        mUseractive.info[aname].df={}
        mUseractive.info[aname].rf={}
        mUseractive.info[aname].f=0
        mUseractive.info[aname].ff={}
    end
    setRandSeed()
    local function getBag(cfg) 
        local tal=0
        local tmp={}
        for k,v in pairs (cfg) do
            tal=tal+v
            table.insert(tmp,tal)
        end
        local seed = rand(1, tal)
        for k,v in pairs (tmp) do
            if seed<=v then
                return k
            end
        end
    end

    local redis =getRedis()
    local redkey ="zid."..getZoneId()..aname..mUseractive.info[aname].st.."uid."..uid
    local data =redis:get(redkey)
    data =json.decode(data)
    if action=="getlog" then
         if type(data)=='table' then
            response.data.log=data
         end   
         response.ret=0
         response.msg = 'Success'
         return response
    end
    if type (data)~="table" then data={}  end
    --  领取每日的礼包
    if  action=="daybag"  then
        if mUseractive.info[aname].c>=1 then
            response.ret=-102
            return response
        end
        if type(mUseractive.info[aname].p)~="table" then  mUseractive.info[aname].p={}  end
        response.data.p={}
        for i=1,activeCfg.dayGet do
             local btype=getBag(activeCfg.serverreward.typeRatio)
             mUseractive.info[aname].p["p"..btype]=(mUseractive.info[aname].p["p"..btype] or 0)+1
             response.data.p["p"..btype]=(response.data.p["p"..btype] or 0)+1
        end
        mUseractive.info[aname].c=1


    elseif action=="taskreward" then -- 每日任务奖励
        local tid=request.params.tid 
        if activeCfg.dailyTask[tid]==nil then
            response.ret=-102
            return response
        end
        local ttype=activeCfg.dailyTask[tid].key
        local num  =mUseractive.info[aname].dt[ttype] or 0
        if num<activeCfg.dailyTask[tid].needNum then
            response.ret=-1981
            return response
        end
        local flag=table.contains(mUseractive.info[aname].df, tid)
        if  flag  then
            response.ret=-1976
            return response
        end 
        local reward=activeCfg.dailyTask[tid].serverreward
        if not takeReward(uid,reward) then        
            response.ret = -403
            return response
        end
        response.data.reward=  formatReward(reward)
        response.data.p={}
        if type(mUseractive.info[aname].p)~="table" then  mUseractive.info[aname].p={}  end
        for i=1,activeCfg.dailyTask[tid].luckbag do
            local btype=getBag(activeCfg.serverreward.typeRatio)
            mUseractive.info[aname].p["p"..btype]=(mUseractive.info[aname].p["p"..btype] or 0)+1
            response.data.p["p"..btype]=(response.data.p["p"..btype] or 0)+1
        end
        table.insert(mUseractive.info[aname].df,tid)
    elseif action=="rechargereward" then -- 充值奖励
        local tid=request.params.tid 
        if activeCfg.serverreward.recharge[tid]==nil then
            response.ret=-102
            return response
        end
        if mUseractive.info[aname].v<activeCfg.needMoney[tid]  then
            response.ret=-1981
            return response
        end
        local flag=table.contains(mUseractive.info[aname].rf, tid)
        if  flag  then
            response.ret=-1976
            return response
        end 
        local reward=activeCfg.serverreward.recharge[tid][1]
        if not takeReward(uid,reward) then        
            response.ret = -403
            return response
        end
        response.data.reward=  formatReward(reward)
        response.data.p={}
        if type(mUseractive.info[aname].p)~="table" then  mUseractive.info[aname].p={}  end
        for i=1,activeCfg.serverreward.recharge[tid][2] do
            local btype=getBag(activeCfg.serverreward.typeRatio)
            mUseractive.info[aname].p["p"..btype]=(mUseractive.info[aname].p["p"..btype] or 0)+1
            response.data.p["p"..btype]=(response.data.p["p"..btype] or 0)+1
        end
        table.insert(mUseractive.info[aname].rf,tid)

    elseif action=="luckreward" then   --福气值奖励
        local tid=request.params.tid 
        if activeCfg.serverreward.luckReward[tid]==nil then
            response.ret=-102
            return response
        end
        if mUseractive.info[aname].f<activeCfg.needLuck[tid]  then
            response.ret=-1981
            return response
        end
        if type(mUseractive.info[aname].ff)~="table" then mUseractive.info[aname].ff={} end
        local flag=table.contains(mUseractive.info[aname].ff, tid)
        if  flag  then
            response.ret=-1976
            return response
        end 
        local reward=activeCfg.serverreward.luckReward[tid]
        if not takeReward(uid,reward) then        
            response.ret = -403
            return response
        end
        response.data.reward=  formatReward(reward)
        table.insert(mUseractive.info[aname].ff,tid)
    elseif action=="openbag" then  --打开福气礼包
        local tid=request.params.tid or 1
        local count=request.params.count or 1
        if mUseractive.info[aname].p["p"..tid]==nil or mUseractive.info[aname].p["p"..tid]<count then
            response.ret=-102
            return response
        end
        mUseractive.info[aname].p["p"..tid]=mUseractive.info[aname].p["p"..tid]-count
        if mUseractive.info[aname].p["p"..tid]==0 then
            mUseractive.info[aname].p["p"..tid]=nil
        end
        local reward={}
        local report={}
        for i=1,count do
            local result = getRewardByPool(activeCfg.serverreward['pool'..tid])
            for k,v in pairs (result or {}) do
                reward[k]=(reward[k] or 0)+v
            end
            
            local point =rand(activeCfg.getLuck[1],activeCfg.getLuck[2])
            mUseractive.info[aname].f=(mUseractive.info[aname].f or 0)+point
            local tmp={formatReward(result),point,tid,ts}
            table.insert(report,1,tmp)
            table.insert(data,1,tmp)
        end
        if not takeReward(uid,reward) then        
            response.ret = -403
            return response
        end
        response.data.report =report
    end

   if  uobjs.save() then        
        processEventsAfterSave()
        response.ret = 0
        if next(data) then
            if #data >10 then
                for i=#data,11 do
                    table.remove(data)
                end
            end
            data=json.encode(data)
            redis:set(redkey,data)
            redis:expireat(redkey,mUseractive.info[aname].et+86400)
        end
        response.data[aname] = mUseractive.info[aname]
        response.msg = 'Success'
    end
    
    return response



end
