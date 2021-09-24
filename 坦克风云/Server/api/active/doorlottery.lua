function api_active_doorlottery(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local door= tonumber(request.params.door) or 1
    if uid == nil then
        response.ret = -102
        return response
    end

    -- 活动名称，门后有鬼
    local aname = 'doorGhost'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops,reward



    local activStatus = mUseractive.getActiveStatus(aname)
    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local ts = getClientTs()
    local weeTs = getWeeTs()
    local lastTs = mUseractive.info[aname].t or 0

    if type (mUseractive.info[aname].r)~='table' then mUseractive.info[aname].r={}  end

    local activeCfg = getConfig("active.doorGhost."..mUseractive.info[aname].cfg)
    local fcount = table.length(mUseractive.info[aname].r)
    local count  = activeCfg.time

    if fcount>=count then
        response.ret=-1981
        return response
    end

    local flag=table.contains(mUseractive.info[aname].r, door)
    if (flag)then
        response.ret=-1976
        return response
    end

    if type (mUseractive.info[aname].info.h[door])~='table' then
        response.ret=-1981
        return response
    end

    local reward =mUseractive.info[aname].info.h[door]
    for k,v in pairs(reward)  do
        if(k=='gt_g1') then
            mUseractive.info[aname].v=mUseractive.info[aname].v+v 
            if mUseractive.info[aname].v>activeCfg.maxghost then
                mUseractive.info[aname].v=activeCfg.maxghost
            end
        else
            local ret = takeReward(uid,reward)
            if not ret then
                response.ret = -403
                return response
            end
         
        end
    end

   
    table.insert(mUseractive.info[aname].r,door)

    if  uobjs.save() then        
        processEventsAfterSave()
        response.data[aname]=mUseractive.info[aname]
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response

end