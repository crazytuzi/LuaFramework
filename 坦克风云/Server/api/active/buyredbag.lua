--购买红包让大家抢

function api_active_buyredbag(request)
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

    -- 活动名称，抢红包
    local acname = 'grabRed'
        
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
    local activeCfg = getConfig("active."..acname.."."..mUseractive.info[acname].cfg)
    local cutgems = mUseractive.info[acname].v

    local needgems = activeCfg.cost

    local value = activeCfg.value
    --如果有代币 先扣代币
    if cutgems>0 then

        local maxgems= needgems*value
        if cutgems>=maxgems then
            needgems=needgems-maxgems
            mUseractive.info[acname].v=mUseractive.info[acname].v-maxgems
        else
            mUseractive.info[acname].v=0
            needgems=needgems-cutgems
        end
    end

    local reward = activeCfg.serverreward[1]


    -- local id=getActiveIncrementId(acname..mUseractive.info[acname].st,mUseractive.getActiveCacheExpireTime(activeName,172800))
    --  local log ={id,mUserinfo.nickname}
    --     mUseractive.setlog(getZoneId(),log,acname,true)

    if not mUserinfo.useGem(needgems) then
        response.ret = -109 
        return response
    end
    if not takeReward(uid,reward) then
        response.ret = -403
        return response
    end

    
    --消费日志购买 红包
    regActionLogs(uid,1,{action=36,item="",value=needgems,params={reward=reward}})
    local function Log(logInfo,filename)
        local log = ""
        log = log .."uid=".. (logInfo.uid or ' ') .. "|"
        log = log .. "reward="..json.encode(logInfo.reward)

        filename = filename or 'redBag'
        writeLog(log,filename)
    end 

    if uobjs.save() then 
        Log({uid=uid,reward=reward})       
        processEventsAfterSave()

        -- 分享一下 生成一个红包id
        local id=getActiveIncrementId(acname..mUseractive.info[acname].st,mUseractive.getActiveCacheExpireTime(acname,172800))
        local log ={id,mUserinfo.nickname}
        --存储谁分享的红包
        mUseractive.setlog(getZoneId(),log,acname,true)
        response.data.redid=id
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response

end