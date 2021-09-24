--有鬼获取信息
function api_active_doorget(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid

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
    --刷新面板
    if weeTs > lastTs then
       mUseractive.doorGhostRef()
       mUseractive.info[aname].l=0 
       mUseractive.info[aname].lf=0
    end
    
    mUseractive.info[aname].t = weeTs

    if  uobjs.save() then        
        processEventsAfterSave()
        response.data[aname]=mUseractive.info[aname]
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end