function api_user_signaward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = tonumber(request.uid)

    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('sign')== 0 then
      response.ret = -303
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","bookmark","challenge","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')

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

    local totalSignDays = {}

    local signCfg = getConfig("signcfg")
    local awardN = mUserinfo.flags.sign[3] + 1
    local awardNkey = signCfg.totalSignDays[awardN] and 'd' .. signCfg.totalSignDays[awardN] or 0
    local award = signCfg[cfgVersion].totalSign[awardNkey]
    
    if mUserinfo.flags.sign[4] >= signCfg.totalSignDays[awardN] and type(award) == 'table' then
        if takeReward(uid,award) then
            if awardN == 3 then
                mUserinfo.flags.sign[3] = 0 
                mUserinfo.flags.sign[4] = 0
            else
                mUserinfo.flags.sign[3] = awardN
            end
        end
    else
        return response
    end

    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
