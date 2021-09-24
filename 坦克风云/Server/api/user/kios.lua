function api_user_kios(request)
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

    if moduleIsEnabled('vMig')== 0 then
      response.ret = -303
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","bag"})
    local mUserinfo = uobjs.getModel('userinfo')

    if tonumber(mUserinfo.flags.kios) == 1 then
        local cfg = getConfig('player.back')
        if not takeReward(uid, cfg.backReward.serverReward) then
            response.ret = -403
            return response
        end
        mUserinfo.flags.kios = 2 --已经领标记

        response.data.reward = formatReward( cfg.backReward.serverReward )
    else
        response.ret = -4033
        return response
    end

    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
