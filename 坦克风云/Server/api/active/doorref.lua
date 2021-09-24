-- 门后有鬼刷新
function api_active_doorref(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local method= tonumber(request.params.method) or 1

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
    local refcount  = tonumber (mUseractive.info[aname].l) or 0
    local refcount  = refcount+1
    local reflfcount= tonumber (mUseractive.info[aname].lf) or 0
    local vip       = mUserinfo.vip
    local vipLv     = 0
    if vip>0 then
        vipLv =activeCfg.vipLv
    end
    
    --免费的
    if method==1 then
        if reflfcount>= vipLv then
            response.ret=-1981
            return response
        end
        mUseractive.info[aname].lf=reflfcount+1
    else

        mUseractive.info[aname].l=refcount

        local gemCost = 0
        if activeCfg.refreshCost[refcount]~=nil  then
            gemCost =tonumber(activeCfg.refreshCost[refcount])
            if not mUserinfo.useGem(gemCost) then
                response.ret = -109 
                return response
            end
        else   
            local refcount =#activeCfg.refreshCost 
            gemCost=tonumber(activeCfg.refreshCost[refcount])
            if not mUserinfo.useGem(gemCost) then
                response.ret = -109 
                return response
            end
        end

        -- 41 刷新门后有鬼消耗的金币
        regActionLogs(uid,1,{action=41,item="",value=gemCost,params={buyNum=refcount}})
    end

    
    mUseractive.doorGhostRef()
    --ptb:e(mUseractive.info[aname])
    if  uobjs.save() then        
        processEventsAfterSave()
        response.data[aname]=mUseractive.info[aname]
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end