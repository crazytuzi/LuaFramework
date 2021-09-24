function api_user_sign(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = tonumber(request.uid)
    local addSign =  request.params.addSign

    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('sign') == 0 then
      response.ret = -303
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","bookmark","challenge","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')

    -- 连续签道的天数,
    -- 最后一天签到的时间,
    -- 当前领到的奖励（0-3档）
    -- 全部签到累积的天数
	-- 当前配置
    if type(mUserinfo.flags.sign) ~= 'table' then
        mUserinfo.flags.sign = {0,0,0,0,1}
    end
    if not mUserinfo.flags.sign[5] then
        mUserinfo.flags.sign[5] = 1
    end
    local cfgVersion = mUserinfo.flags.sign[5]
    if moduleIsEnabled('signupcfg') == 0 then
        cfgVersion = 1
    end

    -- local ts = getClientTs() + (request.params.d) * 86400
    local ts = getClientTs()
    local weets = getWeeTs()
    local signCfg = getConfig("signcfg")
    local dailySignCfg = copyTable(signCfg[cfgVersion].dailySign)

    local noSignDays =math.floor((ts - (mUserinfo.flags.sign[2] or 0) ) / 86400)
    local addSignDays = noSignDays - 1

    if mUserinfo.flags.sign[2] and mUserinfo.flags.sign[2] > 0 and noSignDays <= 0 then
        response.ret = -302
        return response
    end

    if addSignDays > 4 and addSign == 1 then
        response.ret = -302
        return response
    end

    local totalSignIncrD = 1
    if addSignDays == 0 then
        mUserinfo.flags.sign[1] =  (mUserinfo.flags.sign[1] or 0) + 1
    elseif addSignDays > 0 and addSign == 1 then
        local consumeGems = signCfg.AddSign[addSignDays]
        if consumeGems and mUserinfo.useGem(consumeGems) then
            mUserinfo.flags.sign[1] = noSignDays + mUserinfo.flags.sign[1]
            totalSignIncrD = noSignDays
            regActionLogs(uid,1,{action=16,item="sign",value=consumeGems,params={buyNum=addSignDays}})
        end
    else
        mUserinfo.flags.sign[1] = 1
    end

    mUserinfo.flags.sign[4] = ((mUserinfo.flags.sign[4] or 0) >= 30 and 30) or ((mUserinfo.flags.sign[4] or 0) + totalSignIncrD)  
    mUserinfo.flags.sign[2] = weets
     
    local ret,reward,awardN = true 

    local cfg = getConfig('player.daily_honor')
    local rankLevel = arrayGet(mUserinfo,'rank',1)
    local honor = cfg[rankLevel]

    if mUserinfo.flags.sign[1] == 1 then
        reward = dailySignCfg[mUserinfo.flags.sign[1]]
        reward.userinfo_honors = honor
        ret = takeReward(uid,reward)
    else
        for i=0,addSignDays do
            awardN = mUserinfo.flags.sign[1]-i
            if awardN >= 5 then
                reward = dailySignCfg[5]
            else
                reward = dailySignCfg[awardN]
            end

            if ret then
                reward.userinfo_honors = honor
                ret = takeReward(uid,reward)
            end
        end
    end

    processEventsBeforeSave()

    if ret and uobjs.save() then        
        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
