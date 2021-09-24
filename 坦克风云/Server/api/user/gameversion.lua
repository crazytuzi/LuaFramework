-- 后台记录version版本
-- User: liming
function api_user_gameversion(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local uid = tonumber(request.uid) or 0
    if uid == 0 then
        response.ret = -102
        return response
    end
    local version = tonumber(request.params.version) or 0
    if version == 0 then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
    local giftcfg =getConfig('player.mandatoryUpdate')
    local level = giftcfg.level
    local reward = giftcfg.backReward.serverReward
    local report = {}
    for k,v in pairs(reward) do
        table.insert(report, formatReward({[k]=v}))
    end
    local ulevel = mUserinfo.level
    local strongVersions = getConfig('base.GAME_STRONG_VERSION')
    local cfgstrongversion = strongVersions and strongVersions[tostring(request.appid)] or 0
    local strongversion = mUserinfo.flags.strongversion or 0
    if moduleIsEnabled('gameversion') == 0 then
        response.ret = -180
        return response
    end
    
    local gameMaxVersion = getConfig('base.GAME_MAX_VERSION')
    if not gameMaxVersion then
        response.ret = -102 
        return response
    end

    -- 客户端版本号不能高于配置的最大版本
    if version > gameMaxVersion then
        response.ret = -102
        return response
    end

    if ulevel <= level then
        response.ret = -301
        return response
    end
    if version < cfgstrongversion then
        response.ret = -102
        return response
    end
    if version == strongversion then
        response.ret = -136
        return response
    end
    if version <= strongversion then
        response.ret = -129
        return response
    end
    if not takeReward(uid,reward) then
        response.ret=-102
        return response
    end
    mUserinfo.flags.strongversion = gameMaxVersion
    if uobjs.save() then
        response.ret = 0
        response.data.reward = report
        response.msg = "Success"
    end

    return response
end

